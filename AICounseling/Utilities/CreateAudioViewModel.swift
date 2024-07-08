import Foundation
import SwiftOpenAI
import AVFoundation

final class CreateAudioViewModel2: NSObject, ObservableObject {
    @Published var isLoadingTextToSpeechAudio: TextToSpeechType = .finishedPlaying
    @Published var audioLevel: Float = 0.0
    
    private var openAI: SwiftOpenAI { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return SwiftOpenAI(apiKey: gptApiKey)
        } else {
            fatalError("OPENAI_API_KEY not found in Info.plist")
        }
    }
    var avAudioPlayer = AVAudioPlayer()
    var timer: Timer?
    
    enum TextToSpeechType {
        case noExecuted
        case isLoading
        case finishedLoading
        case finishedPlaying
    }
    
    func playAudioAgain() {
        avAudioPlayer.play()
        startMetering()
    }
    
    @MainActor
    func createSpeech(input: String, voice: String) async {
        isLoadingTextToSpeechAudio = .isLoading
        do {
            let data = try await openAI.createSpeech(
                model: .tts(.tts1),
                input: input,
                voice: OpenAIVoiceType(rawValue: voice)!,
                responseFormat: .mp3,
                speed: voice == "shimmer" ? 0.95 : 1.0
            )
            
            if let filePath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first?.appendingPathComponent("speech.mp3"),
               let data {
                do {
                    try data.write(to: filePath)
                    print("File created: \(filePath)")
                    
                    avAudioPlayer = try AVAudioPlayer(contentsOf: filePath)
                    avAudioPlayer.delegate = self
                    avAudioPlayer.isMeteringEnabled = true
                    avAudioPlayer.play()
                    startMetering()
                    isLoadingTextToSpeechAudio = .finishedLoading
                    //                    isPlayingLoadingVoice = true // 再生が開始されたことを通知
                } catch {
                    print("Error saving file: ", error.localizedDescription)
                }
            } else {
                print("Error trying to save file in filePath")
            }
            
        } catch {
            print("Error creating Audios: ", error.localizedDescription)
        }
    }
    
    private func startMetering() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioMeter()
        }
    }
    
    private func updateAudioMeter() {
        avAudioPlayer.updateMeters()
        let averagePower = avAudioPlayer.averagePower(forChannel: 0)
        audioLevel = pow(10, averagePower / 20)
    }
}

extension CreateAudioViewModel2: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isLoadingTextToSpeechAudio = .finishedPlaying
    }
}
