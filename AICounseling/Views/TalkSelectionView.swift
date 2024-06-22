import SwiftUI

struct TalkSelectionView: View {
    @State private var appear = false
    
    var dismissAction: (String) -> Void
    
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
        switch index {
        case 1:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.freeTalkSystemContent)
            dismissAction(SystemContent.freeTalkSystemContent)
        case 2:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.adviceTalkSystemContent)
            dismissAction(SystemContent.adviceTalkSystemContent)
        case 3:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.knowDistortionSystemContent)
            dismissAction(SystemContent.knowDistortionSystemContent)
        case 4:
            ChatGPTService.resetSharedInstance(systemContent: SystemContent.stressResistanceSystemContent)
            dismissAction(SystemContent.stressResistanceSystemContent)
        default:
            break
        }
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
        TalkSelectionView { _ in }
    }
}
