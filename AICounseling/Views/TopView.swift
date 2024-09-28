import SwiftUI
import AVFoundation
import Speech

struct TopView: View {
    @State private var currentMessageIndex = 0
    private let messages = [
        "こんにちは！",
        "好きなAIを選んでね"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ProfileImageView(imageName: "kiriko.png", messages: messages, currentMessageIndex: $currentMessageIndex)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        MoveView(imageName: "kiriko.png", title: "キリコ", description: "エネルギッシュな女性", destination: VoiceChatWrapper(voice: "8EkOjt4xTPGMclNlh1pk", systemContent: SystemContent.freeTalkSystemContent))
                        MoveView(imageName: "hanzou.png", title: "ハンゾウ", description: "知的な男性", destination: VoiceChatWrapper(voice: "GKDaBI8TKSBJVhsCLD6n", systemContent: SystemContent.hanzouSystemContent))
                        MoveView(imageName: "hanzou.png", title: "オセロ", description: "知的な男性", destination: OthelloView())
//                        ProfileInfoView(title: "メールアドレス", value: UserDefaults.standard.string(forKey: "user_email") ?? "")

                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
//            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
            .background(Color(red: 0.96, green: 0.98, blue: 0.92))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            requestPermissions()
            startMessageTimer()
        }
    }
    
    private func startMessageTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
            }
        }
    }
}

private func requestPermissions() {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        if granted {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    // 許可が与えられた場合の処理
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    // 許可が拒否された場合の処理
                    print("Speech recognition not authorized")
                @unknown default:
                    fatalError("Unexpected SFSpeechRecognizer authorization status")
                }
            }
        } else {
            // マイクの使用許可が拒否された場合の処理
            print("Microphone access not authorized")
        }
    }
}

struct TalkDialogView: View {
    var iconName: String
    var title: String
    var description: String
    
    @State private var showModal = false
    @State private var selectedSystemContent: String?
    
    var body: some View {
        VStack {
            Button(action: {
                showModal = true
            }) {
                HStack {
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 20)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
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
                    isVoiceChat: false,  // テキストチャットの場合はfalse
                    voiceCharacter: nil  // テキストチャットの場合はnil
                )
            }
            
            NavigationLink(destination: TextChatWrapper(systemContent: selectedSystemContent), isActive: Binding<Bool>(
                get: { selectedSystemContent != nil },
                set: { if !$0 { selectedSystemContent = nil } }
            )) {
                EmptyView()
            }
        }
    }
}

struct MoveView<Destination: View>: View {
    var imageName: String
    var title: String
    var description: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
        ) {
            HStack {
                Image(uiImage: UIImage(named: imageName) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 10)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileInfoView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(20)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(20)
        }
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: 10)
                    
                    Rectangle()
                        .foregroundColor(Color.blue)
                        .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: 10)
                }
                .cornerRadius(5)
            }
            Text("30分")
                .foregroundColor(.gray)
        }
    }
}

struct ProfileImageView: View {
    var imageName: String
    var messages: [String]
    @Binding var currentMessageIndex: Int
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: imageName) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4)
                )
                .shadow(radius: 10)
            
            Text(messages[currentMessageIndex])
                .font(.caption)
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top, 10)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
