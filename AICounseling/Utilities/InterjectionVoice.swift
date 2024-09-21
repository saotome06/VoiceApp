import Foundation
import UIKit
import SwiftOpenAI
import AVFoundation

final class InterjectionVoice: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isLoadingTextToSpeechAudio: TextToSpeechType = .noExecuted
    
    private var openAI: SwiftOpenAI { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return SwiftOpenAI(apiKey: gptApiKey)
        } else {
            fatalError("OPENAI_API_KEY not found in Info.plist")
        }
    }
    var avAudioPlayer = AVAudioPlayer()
    
    enum TextToSpeechType {
        case noExecuted
        case isLoading
        case finishedLoading
        case finishedPlaying
    }
    
    func playAudioAgain() {
        avAudioPlayer.play()
    }
    
    func playAssetAudio(assetName: String) {
        if let audioData = NSDataAsset(name: assetName)?.data {
            do {
                avAudioPlayer = try AVAudioPlayer(data: audioData)
                avAudioPlayer.play()
                print("Playing audio from asset: \(assetName)")
            } catch {
                print("Error playing audio asset: \(error.localizedDescription)")
            }
        } else {
            print("Audio asset not found: \(assetName)")
        }
    }
    
    func playRandomAssetAudio() {
        // 音声ファイル名の配列
        let audioAssets = ["EInterjectionVoice_Morioki_1", "EInterjectionVoice_Morioki_2", "EInterjectionVoice_Morioki_3"]
        
        // ランダムに1つ選択
        if let randomAsset = audioAssets.randomElement() {
            playAssetAudio(assetName: randomAsset)
        } else {
            print("No audio assets available")
        }
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
                speed: 1.0
            )
            
            if let filePath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first?.appendingPathComponent("speech.mp3"),
               let data {
                do {
                    try data.write(to: filePath)
                    print("File created: \(filePath)")
                    
                    avAudioPlayer = try AVAudioPlayer(contentsOf: filePath)
                    avAudioPlayer.delegate = self
                    avAudioPlayer.play()
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
}
