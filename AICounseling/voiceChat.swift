import SwiftUI
import Combine
import Speech
import OpenAISwift
import AVFoundation
import Foundation
import Supabase
import SwiftOpenAI

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
    
    let voice: String
    
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
//                    ios17以上でないと対応していない
//                    .onChange(of: messages.count) {
//                        scrollToBottom(proxy: proxy)
//                    }
                    .onReceive(messagesCountPublisher) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    Capsule()
                        .frame(width: CGFloat(viewModel.audioLevel) * 500, height: CGFloat(viewModel.audioLevel) * 500)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
        }
        .onChange(of: self.speechRecorder.audioRunning) { newValue in
            if !newValue {
                if !self.speechRecorder.audioText.isEmpty {
                    prepareLoadingSound()
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
        .onChange(of: self.speechRecorder.audioText) { newValue in
            if self.speechRecorder.audioText.count == 3 {
                audioRecorder.startRecording()
            }
//            if self.speechRecorder.audioText.count == 30 {
//                audioRecorder.stopRecording()
//                let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav").path
//                print("sddsfdsdfdd")
////                analyzeWav(apiKey: apiKey, wavFilePath: wavFilePath)
//            }
        }
        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
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
                                try await viewModel.createSpeech(input: response, voice: voice)
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
                try await interjectionModel.createSpeech(input: randomInterjection, voice: voice)
            } catch {
                print("Failed to create speech: \(error)")
            }
        }
    }
}

struct VoiceChat_Previews: PreviewProvider {
    static var previews: some View {
        VoiceChat(voice: "alloy")
    }
}
