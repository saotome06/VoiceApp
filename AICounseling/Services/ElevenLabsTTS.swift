import Foundation
import AVFoundation

struct ElevenLabsRequest: Codable {
    let text: String
    let model_id: String
    let voice_settings: VoiceSettings
    
    enum CodingKeys: String, CodingKey {
        case text
        case model_id
        case voice_settings
    }
}

struct VoiceSettings: Codable {
    let stability: Double
    let similarity_boost: Double
    
    enum CodingKeys: String, CodingKey {
        case stability
        case similarity_boost
    }
}

class ElevenLabsTTS: NSObject, AVAudioPlayerDelegate {
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1/text-to-speech"
    private var audioPlayer: AVAudioPlayer?
    private var completion: ((Error?) -> Void)?
    
    init(apiKey: String) {
        self.apiKey = apiKey
        super.init()
    }
    
    func generateSpeech(text: String, voiceId: String) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/\(voiceId)") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let requestBody = ElevenLabsRequest(
            text: text,
            model_id: "eleven_multilingual_v2",
            voice_settings: VoiceSettings(stability: 0.5, similarity_boost: 0.75)
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        let encodedBody = try encoder.encode(requestBody)
        request.httpBody = encodedBody
        
        // リクエストボディを出力
        if let jsonString = String(data: encodedBody, encoding: .utf8) {
            print("Request body: \(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // レスポンスの詳細を出力
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")
        }
        
        return data
    }
    
    class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
        let continuation: CheckedContinuation<Void, Error>
        
        init(continuation: CheckedContinuation<Void, Error>) {
            self.continuation = continuation
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                continuation.resume(returning: ())  // 再生が成功した場合
            } else {
                continuation.resume(throwing: NSError(domain: "AudioPlayback", code: -1, userInfo: nil))  // 再生に失敗した場合
            }
        }
    }
    
    // AVAudioPlayerDelegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio playback finished successfully")
        } else {
            print("Audio playback did not finish successfully")
        }
        completion?(nil)
    }
}
