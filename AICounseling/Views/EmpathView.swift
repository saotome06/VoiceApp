import SwiftUI

struct EmpathView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var isMenuOpen = false
    
    var body: some View {
        NavigationView {
            VStack {
                if audioRecorder.isRecording {
                    Button(action: {
                        audioRecorder.stopRecording()
                        let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav").path
//                        analyzeWav(apiKey: apiKey, wavFilePath: wavFilePath)
                    }) {
                        Text("Stop Recording")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        audioRecorder.startRecording()
                    }) {
                        Text("Start Recording")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                if !audioRecorder.isRecording {
                    Button(action: {
                        let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav")
                        audioPlayer.playAudio(url: wavFilePath)
                    }) {
                        Text("Play Recording")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(audioRecorder.isRecording)
                }
                
                if audioPlayer.isPlaying {
                    Button(action: {
                        audioPlayer.stopAudio()
                    }) {
                        Text("Stop Playing")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle("Audio Recorder")
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
            .navigationBarItems(leading: EmptyView())
        }
    }
}

struct EmpathView_Previews: PreviewProvider {
    static var previews: some View {
        EmpathView()
    }
}
