import SwiftUI
import Supabase

struct TalkSelectionView: View {
    @State private var appear = false
    
    var dismissAction: (String) -> Void
    var isVoiceChat: Bool
    var voiceCharacter: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("今日はどんな気分ですか？")
                .font(.title)
                .padding(.bottom, 40)
                .opacity(appear ? 1 : 0)
                .animation(.easeIn(duration: 1.0).delay(0.1))
            
            ForEach(0..<2) { row in
                HStack(spacing: 20) {
                    ForEach(1..<3) { column in
                        let index = row * 2 + column
                        Button(action: {
                            handleButtonTap(for: index)
                        }) {
                            HStack {
                                Text(buttonLabel(for: index))
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            .padding(30)
                            .background(.gray)
                            .cornerRadius(100)
                            .shadow(radius: 10)
                            .opacity(appear ? 1 : 0)
                            .scaleEffect(appear ? 1 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .delay(0.1 * Double(index))
                            )
                        }
                    }
                }
            }
            
            HStack {
                Button(action: {
                    dismissAction("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .cornerRadius(10)
            .shadow(radius: 10)
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.5)
            .animation(
                .easeInOut(duration: 0.8)
            )
        }
        .padding()
        .onAppear {
            appear = true
        }
    }
    
    private func handleButtonTap(for index: Int) {
        FCMManager.shared.registerFCMTokenIfNeeded()
        switch index {
        case 1:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.freeTalkSystemContent)
            dismissAction(SystemContent.freeTalkSystemContent)
            registerActionCount(talkType: "free_talk")
        case 2:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.adviceTalkSystemContent)
            dismissAction(SystemContent.adviceTalkSystemContent)
            registerActionCount(talkType: "advice_talk")
        case 3:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.knowDistortionSystemContent)
            dismissAction(SystemContent.knowDistortionSystemContent)
            registerActionCount(talkType: "know_distortion")
        case 4:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.stressResistanceSystemContent)
            dismissAction(SystemContent.stressResistanceSystemContent)
            registerActionCount(talkType: "stress_resistance")
        default:
            break
        }
    }
    
    private func registerActionCount(talkType: String) {
        Task {
            do {
                if isVoiceChat {
                    try await insertVoiceActionNum(character: voiceCharacter ?? "", type: talkType)
                } else {
                    try await insertActionNum(selectColumn: talkType)
                }
            } catch {
                print("Error inserting data: \(error)")
            }
        }
    }
    
    func insertActionNum(selectColumn: String) async throws {
        struct FreetalkNum: Decodable {
            var free_talk: Int
            var advice_talk: Int
            var know_distortion: Int
            var stress_resistance: Int
        }


        let response:[FreetalkNum] = try await supabaseClient
            .from("action_num")
            .select("free_talk,advice_talk,know_distortion,stress_resistance")
            .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
            .execute()
            .value

        
        
        // 現在の値を確認
        guard let currentValue = response.first else {
            print("No matching record found")
            return
        }

        // 更新する値を決定
        let newValue: Int
        switch selectColumn {
        case "free_talk":
            newValue = currentValue.free_talk + 1
        case "advice_talk":
            newValue = currentValue.advice_talk + 1
        case "know_distortion":
            newValue = currentValue.know_distortion + 1
        case "stress_resistance":
            newValue = currentValue.stress_resistance + 1
        default:
            print("Unknown column: \(selectColumn)")
            return
        }
        
        // 値を更新する
        try await supabaseClient
            .from("action_num")
            .update([selectColumn: newValue])
            .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
            .execute()
    }
    
    func insertVoiceActionNum(character: String, type: String) async throws {
        struct VoiceStats: Codable {
            var voice_stats: [String: [String: Int]]
        }
        let response: [VoiceStats] = try await supabaseClient
            .from("action_num")
            .select("voice_stats")
            .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
            .execute()
            .value
        guard var currentStats = response.first?.voice_stats else {
            print("No matching record found")
            return
        }

        if currentStats[character] == nil {
            currentStats[character] = [:]
        }
        if currentStats[character]?[type] == nil {
            currentStats[character]?[type] = 0
        }
        let currentValue = currentStats[character]?[type] ?? 0
        currentStats[character]?[type] = currentValue + 1
        
        try await supabaseClient
            .from("action_num")
            .update(["voice_stats": currentStats])
            .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
            .execute()
    }

    
    private func buttonLabel(for index: Int) -> String {
        switch index {
        case 1:
            return "とにかく話したい"
        case 2:
            return "アドバイスがほしい"
        case 3:
            return "考え方の歪みを知りたい"
        case 4:
            return "ストレスに強くなりたい"
        default:
            return "選択肢 \(index)"
        }
    }
}

struct TextChatWrapper: View {
    var systemContent: String?
    
    var body: some View {
        if let systemContent = systemContent {
            TextChat(systemContent: systemContent)
        } else {
            EmptyView()
        }
    }
}

struct VoiceChatWrapper: View {
    var voice: String
    var systemContent: String?
    
    var body: some View {
        if let systemContent = systemContent {
            VoiceChat(voice: voice, systemContent: systemContent)
        } else {
            EmptyView()
        }
    }
}

struct TalkSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TalkSelectionView(dismissAction: { content in
            // dismissAction の処理
        }, isVoiceChat: false, voiceCharacter: nil)    }
}
