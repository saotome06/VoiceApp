import SwiftUI
import Combine
import Speech
import OpenAISwift
import AVFoundation
import Foundation
import Supabase
import SwiftOpenAI

private var enctyptKey: String { // ここから（2）
    if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_KEY") as? String {
        return gptApiKey
    } else {
        return "not found"
    }
}

private var enctyptIV: String { // ここから（2）
    if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_IV") as? String {
        return gptApiKey
    } else {
        return "not found"
    }
}

struct VoiceChat: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var voiceText: String = ""
    @State private var isRecording: Bool = false
    @ObservedObject private var speechRecorder = SpeechRecorder()
    @State private var showingAlert = false
    @ObservedObject private var viewModel = CreateAudioViewModel2()
    @ObservedObject private var interjectionModel = InterjectionVoice()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var isMenuOpen = false
    @State private var messagesCountPublisher: AnyPublisher<Int, Never> = Just(0).eraseToAnyPublisher()
    
    private let voice: String
    
    private let systemContent: String
    
    init(voice: String, systemContent: String) {  // 初期化メソッドを追加
        self.voice = voice
        self.systemContent = systemContent
    }
    
    let interjections = ["うーん", "あーー", "うんうん", "えーーと", "おっと、", "ん〜〜と", "おお！", "うーん、うん"]
    
    var body: some View {
        let imageName = "\(self.voice).png"
        VStack {
            VStack {
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            MessageView(message: Message(text: "今日はどうなさいましたか？", isReceived: true))
                            LazyVStack {
                                ForEach(messages, id: \.self) { message in
                                    MessageView(message: message)
                                }
                            }
//                            ios17以上でないと対応していない
//                            .onChange(of: messages.count) {
//                                scrollToBottom(proxy: proxy)
//                            }
                            .onReceive(messagesCountPublisher) { _ in
                                scrollToBottom(proxy: proxy)
                            }
                        }
                    }
                    Spacer()
                    Image(uiImage: UIImage(named: imageName) ?? UIImage())
                        .resizable()
                        .frame(width: (0.1 + CGFloat(viewModel.audioLevel)) * 300, height: (0.1 + CGFloat(viewModel.audioLevel)) * 300)
                        .clipShape(Circle()) // 画像を円形に切り抜く
                        .shadow(color: Color.purple.opacity(0.7), radius: 10, x: 0, y: 10)
                        .animation(.easeOut(duration: 0.2), value: viewModel.audioLevel)
                    
                    Spacer()
                }
                
                if viewModel.isLoadingTextToSpeechAudio == .finishedPlaying {
                    Text("話しかけてください")
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    Text("AIが話しています")
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Text(self.speechRecorder.audioText)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.vertical)
        }
        .onAppear {
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized &&
                SFSpeechRecognizer.authorizationStatus() == .authorized {
                self.showingAlert = false
                self.speechRecorder.toggleRecording()
            } else {
                self.showingAlert = true
            }
//            fetchLogData()
        }
        .onChange(of: self.speechRecorder.audioRunning) { newValue in
            if !newValue {
                if !self.speechRecorder.audioText.isEmpty {
                    voiceText = self.speechRecorder.audioText
                    sendMessage()
                    print(voiceText)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    }
                    audioRecorder.stopRecording()
                }
            }
        }
        .onChange(of: viewModel.isLoadingTextToSpeechAudio) { newValue in
            print(viewModel.isLoadingTextToSpeechAudio)
            if newValue == .finishedPlaying {
                self.showingAlert = false
                self.speechRecorder.toggleRecording()
            }
        }
//        .onChange(of: self.speechRecorder.audioText) { newValue in
//            if self.speechRecorder.audioText.count == 3 {
//                audioRecorder.startRecording()
//            }
////            if self.speechRecorder.audioText.count == 30 {
////                audioRecorder.stopRecording()
////                let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav").path
////                print("sddsfdsdfdd")
//////                analyzeWav(apiKey: apiKey, wavFilePath: wavFilePath)
////            }
//        }
        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
    }
    
    private func fetchLogData(){
        // conversationHistoryが何もない = アプリが落とされたか、一度も会話をしていないか
        // 以下は、アプリが落とされた場合にDBから引っ張ってくる処理
        // 将来はUserDefaultにconversationHistoryを突っ込んでやればAPI使用をさらに減らせるかも
        if ChatGPTService.shared(systemContent: self.systemContent).getConversationHistory().isEmpty {
            guard let email = UserDefaults.standard.string(forKey: "user_email") else { return }
            Task {
                do {
                    var selectField = "log_data"
                    if self.systemContent == SystemContent.knowDistortionSystemContent || self.systemContent == SystemContent.stressResistanceSystemContent {
                        selectField = "know_log_data"
                    }
                    let response = try await supabaseClient.from("users")
                        .select(selectField)
                        .eq("user_email", value: email)
                        .execute()
                    
                    let data = response.data
                    let logData = String(decoding: data, as: UTF8.self)
                    //                    print(logData)
                    if let jsonData = logData.data(using: .utf8) {
                        do {
                            // JSONデータを配列にパースする
                            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]], let logDataString = jsonArray.first?[selectField] {
                                
                                // AES復号化を行う
                                let aes = EncryptionAES()
                                
                                // AESで復号化
                                let decryptedString = aes.decrypt(key: enctyptKey, iv: enctyptIV, base64: logDataString)
                                
                                if !decryptedString.isEmpty {
                                    // 復号化した文字列をJSONデコードして配列に変換する
                                    if let data = decryptedString.data(using: .utf8),
                                       let array = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                                        
                                        
                                        ChatGPTService.shared(systemContent: self.systemContent).setConversationHistory(conversationHistory: array)
                                        for (i, message) in array.enumerated() {
                                            if i % 2 == 0 {
                                                messages.append(Message(text: message, isReceived: false))
                                            } else {
                                                messages.append(Message(text: message, isReceived: true))
                                            }
                                        }
                                        
                                    } else {
                                        print("復号化したデータを配列にパースできませんでした。")
                                    }
                                } else {
                                    print("AES復号化に失敗しました。")
                                }
                                
                            } else {
                                print("JSONデータをパースしてlog_dataを取得できませんでした。")
                            }
                        } catch {
                            print("JSONデータのパースエラー: \(error.localizedDescription)")
                        }
                    } else {
                        print("JSON文字列をデータに変換できませんでした。")
                    }
                    if systemContent == SystemContent.stressResistanceSystemContent {
                        let currentCbtType = try await selectCbtType()
                        if let latestType = currentCbtType.last {
                            CbtType.addCBTType = "相談者の心の傾向は" + latestType + "です。" + latestType + "の認知の歪みを改善させてあげてください。"
                        }
                    }
                    
                } catch {
                    print("Error fetching log data: \(error)")
                }
            }
        } else {
            for (i, message) in ChatGPTService.shared(systemContent: self.systemContent).getConversationHistory().enumerated() { // ここから（10）
                if i % 2 == 0 {
                    messages.append(Message(text: message, isReceived: false))
                } else {
                    messages.append(Message(text: message, isReceived: true))
                }
            }
        }
    }
    
    private func sendMessage() {
        if !voiceText.isEmpty {
            messages.append(Message(text: voiceText, isReceived: false))
            ChatGPTService.shared(systemContent: self.systemContent).fetchResponse(voiceText) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        messages.append(Message(text: response, isReceived: true))
                        Task {
                            async let playAudio = interjectionModel.playRandomAssetAudio()
                            async let createSpeech = try await viewModel.createSpeech(input: response, voice: self.voice)
                            // 両方の処理が完了するのを待つ
                            _ = await (playAudio, createSpeech)
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        messages.append(Message(text: "エラーが発生しました。", isReceived: true))
                    }
                    voiceText = ""
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        withAnimation {
            proxy.scrollTo(lastMessage, anchor: .bottom)
        }
    }
}

struct VoiceChat_Previews: PreviewProvider {
    static var previews: some View {
        VoiceChat(voice: "alloy", systemContent: "test")
    }
}
