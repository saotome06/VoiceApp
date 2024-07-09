import SwiftUI

let sampleCounselors = [
//    Counselor(name: "alloy", voice: "alloy", profileIcon: "alloy.png"),
//    Counselor(name: "echo", voice: "echo", profileIcon: "echo.png"),
    Counselor(name: "fable", voice: "fable", profileIcon: "fable.png"),
    Counselor(name: "onyx", voice: "onyx", profileIcon: "onyx.png"),
    Counselor(name: "nova", voice: "nova", profileIcon: "nova.png"),
    Counselor(name: "shimmer", voice: "shimmer", profileIcon: "shimmer.png")
]

struct CounselorListView: View {
    var counselors: [Counselor]
    
    var body: some View {
        NavigationView {
            List(counselors) { counselor in
                VoiceTalkDialogView(
                    iconName: "person.fill",
                    title: counselor.name,
                    description: counselor.voice,
                    counselor: counselor
                )
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(leading: EmptyView())
            .background(Color(red: 0.96, green: 0.98, blue: 0.92)) // 背景色を設定
        }
    }
}

struct VoiceTalkDialogView: View {
    var iconName: String
    var title: String
    var description: String
    var counselor: Counselor
    
    @State public var showModal = false
    @State private var selectedSystemContent: String?
    
    var body: some View {
        VStack {
            Button(action: {
                showModal = true
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                        
                        Image(uiImage: UIImage(named: counselor.profileIcon) ?? UIImage())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(counselor.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(getVoiceDescription(for: counselor.voice))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 150, alignment: .leading) // 幅を固定
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    NavigationLink(destination: VoiceChatWrapper(voice: counselor.voice, systemContent: selectedSystemContent), isActive: Binding<Bool>(
                        get: { selectedSystemContent != nil },
                        set: { if !$0 { selectedSystemContent = nil } }
                    )) {
                        EmptyView()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showModal) {
                TalkSelectionView(
                    dismissAction: { systemContent in
                        if systemContent != "" {
                            selectedSystemContent = systemContent
                        }
                        showModal = false
                    },
                    isVoiceChat: true,
                    voiceCharacter: counselor.name
                )
            }
        }
        .padding(.vertical, 10)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    func getVoiceDescription(for voice: String) -> String {
        switch voice {
        case "fable":
            return "感情のこもった抑揚のある声"
        case "nova":
            return "明るくクリアで柔らかい声"
        case "onyx":
            return "信頼感を与えるような力強く深い声"
        case "shimmer":
            return "ゆっくりと落ち着いた声"
        default:
            return "標準的な声"
        }
    }
}

struct CounselorListView_Previews: PreviewProvider {
    static var previews: some View {
        CounselorListView(counselors: sampleCounselors)
    }
}
