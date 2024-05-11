import SwiftUI
import Speech
import OpenAISwift

struct VoiceChat: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var voiceText: String = ""
    @State private var isRecording: Bool = false
    @ObservedObject private var speechRecorder = SpeechRecorder()
    @State private var showingAlert = false
    @ObservedObject private var viewModel = CreateAudioViewModel2()
    
    let interjections = ["うーん", "あーー", "あ、はい", "えーーと", "ええ、", "ん〜〜と", "おお！", "うーん、うん"]
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages, id: \.self) { message in
                            MessageView(message: message)
                        }
                    }
                    .onChange(of: messages.count) {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if(AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized &&
                           SFSpeechRecognizer.authorizationStatus() == .authorized){
                            self.showingAlert = false
                            self.speechRecorder.toggleRecording()
                            if !self.speechRecorder.audioRunning {
                                viewModel.isPlayingLoadingVoice = 0
                                prepareLoadingSound()
                                voiceText = self.speechRecorder.audioText
                                sendMessage()
                                print(voiceText)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                }
                            }
                        }
                        else{
                            self.showingAlert = true
                        }
                    }) {
                        if !self.speechRecorder.audioRunning {
                            Text("スピーチ開始")
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundColor(.white)
                                .background(viewModel.isPlayingLoadingVoice != 2 ? Color.gray : Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .disabled(viewModel.isPlayingLoadingVoice != 2)
                        } else {
                            Text("スピーチ終了")
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundColor(.white)
                                .background(viewModel.isPlayingLoadingVoice != 2 ? Color.gray : Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .disabled(viewModel.isPlayingLoadingVoice != 2)
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("マイクの使用または音声の認識が許可されていません"))
                    }
                    Spacer()
                }
                
                Text(self.speechRecorder.audioText)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.vertical)
        }
    }
    
    private func sendMessage() {
        if !voiceText.isEmpty {
            messages.append(Message(text: voiceText, isReceived: false))
            
            ChatGPTService.shared.fetchResponse(voiceText) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        messages.append(Message(text: response, isReceived: true))
                        Task {
                            do {
                                try await viewModel.createSpeech(input: response)
                            } catch {
                                print("Failed to create speech: \(error)")
                            }
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
    
    private func prepareLoadingSound() {
        let randomIndex = Int.random(in: 0..<interjections.count)
        let randomInterjection = interjections[randomIndex]
        Task {
            do {
                try await viewModel.createSpeech(input: randomInterjection)
            } catch {
                print("Failed to create speech: \(error)")
            }
        }
    }
}

struct VoiceChat_Previews: PreviewProvider {
    static var previews: some View {
        VoiceChat()
    }
}
