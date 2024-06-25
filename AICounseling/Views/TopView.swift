import SwiftUI
import AVFoundation
import Speech

struct TopView: View {
    @State private var currentMessageIndex = 0
    private let messages = [
        "こんにちは！どうぞよろしくお願いします。",
        "今日はどんなことを話したいですか？",
        "何でも相談してくださいね。",
        "まずはストレス診断を行なってみてください。"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ProfileImageView(imageName: "alloy.png", messages: messages, currentMessageIndex: $currentMessageIndex)
                        .padding(.top, 20)
                    
                    Spacer()
                    
//                    VStack {
//                        Text("John Doe") // ユーザー名
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                            .padding(.top, 20)
//                        
//                        ProgressBar(progress: 0.5) // 進捗バー、0.5で50%の進捗を示す
//                            .frame(height: 10)
//                            .padding(.top, 10)
//                    }
//                    .padding(20)
//                    .background(Color.white)
//                    .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TalkDialogView(
                            iconName: "person.fill",
                            title: "カウンセリング",
                            description: "相談を開始する"
                        )
                        MoveView(iconName: "mic.fill", title: "声で話す", description: "カウンセラーと音声通話", destination: CounselorListView(counselors: sampleCounselors))
                        MoveView(iconName: "person.crop.circle.badge.exclamationmark", title: "ストレス度合いを確認する", description: "あなたのストレス状態を可視化します", destination: StressView())
                        MoveView(iconName: "heart.circle.fill", title: "ストレス診断", description: "設問に回答してストレス度を診断する", destination: DepressionJudgmentView())
                        MoveView(iconName: "face.smiling", title: "表情認識", description: "自分の表情から感情を読み取ってみる", destination: PyFeatView())
//                        ProfileInfoView(title: "年齢", value: "30") // 年齢
                        ProfileInfoView(title: "メアド", value: UserDefaults.standard.string(forKey: "user_email") ?? "”") // メールアドレス
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
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
                TalkSelectionView { systemContent in
                    if systemContent != "" {
                        selectedSystemContent = systemContent
                    }
                    showModal = false
                }
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
    var iconName: String
    var title: String
    var description: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
        ) {
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
