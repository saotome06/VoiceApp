import Foundation
import SwiftOpenAI
import AVFoundation

final class CreateAudioViewModel2: NSObject, ObservableObject {
    @Published var isLoadingTextToSpeechAudio: TextToSpeechType = .finishedPlaying
    @Published var audioLevel: Float = 0.0
    private var elevenlab_apiKey: String {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "ELEVENLAB_API_KEY") as? String {
            return apiKey
        } else {
            return "not found"
        }
    }
    
    private lazy var tts: ElevenLabsTTS = {
        return ElevenLabsTTS(apiKey: elevenlab_apiKey)
    }()
    
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
//            let data = try await openAI.createSpeech(
//                model: .tts(.tts1),
//                input: "猫が寝転んで楽しそうだったから私も混じって寝転びたい",
//                voice: OpenAIVoiceType(rawValue: voice)!,
//                responseFormat: .mp3,
//                speed: 1.0
//            )
            let data = try await tts.generateSpeech(text: input, voiceId: "8EkOjt4xTPGMclNlh1pk")
            do {
                avAudioPlayer = try AVAudioPlayer(data: data)
                avAudioPlayer.delegate = self
                avAudioPlayer.prepareToPlay()
                avAudioPlayer.isMeteringEnabled = true
                avAudioPlayer.play()
                print("eegeegg")
                startMetering()
                isLoadingTextToSpeechAudio = .finishedLoading
            } catch {
                print("エラー")
            }
            
//            if let filePath = FileManager.default.urls(for: .documentDirectory,
//                                                       in: .userDomainMask).first?.appendingPathComponent("speech.mp3"),
//               let data {
//                do {
//                    try data.write(to: filePath)
//                    print("File created: \(filePath)")
//                    
//                    avAudioPlayer = try AVAudioPlayer(contentsOf: filePath)
//                    avAudioPlayer.delegate = self
//                    avAudioPlayer.isMeteringEnabled = true
//                    avAudioPlayer.play()
//                    startMetering()
//                    isLoadingTextToSpeechAudio = .finishedLoading
//                } catch {
//                    print("Error saving file: ", error.localizedDescription)
//                }
//            } else {
//                print("Error trying to save file in filePath")
//            }
//            
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
