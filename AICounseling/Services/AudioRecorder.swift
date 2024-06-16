import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    var apiKey: String { // ここから（2）
        if let EmpathApiKey = Bundle.main.object(forInfoDictionaryKey: "EMPATH_API_KEY") as? String {
            return EmpathApiKey
        } else {
            return "not found"
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 11025,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            
            // 5秒後に録音を停止するタイマーを設定
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
                self?.stopRecording()
            }
        } catch {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if isRecording {
            audioRecorder?.stop()
            audioRecorder = nil
            isRecording = false
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav").path
            Task {
                do {
                    let empathStaus: [StausEmpath] = try await supabaseClient
                        .from("users")
                        .select("empath_status")
                        .eq("user_email", value: userEmail)
                        .execute()
                        .value
                    if let firstStatus = empathStaus.first {
                        let empathStatusValue = firstStatus.empath_status
                        if !empathStatusValue {
                            analyzeWav(apiKey: apiKey, wavFilePath: audioFilename)
                        }
                        print("empath_status value: \(empathStatusValue)")
                    } else {
                        print("empathStaus array is empty or nil")
                    }
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func resampleWavFile(at url: URL, to sampleRate: Double, completion: @escaping (URL?) -> Void) {
        let audioFile = try! AVAudioFile(forReading: url)
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sampleRate, channels: 1, interleaved: false)!
        let outputURL = getDocumentsDirectory().appendingPathComponent("resampled.wav")
        let outputFile = try! AVAudioFile(forWriting: outputURL, settings: outputFormat.settings)
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFile.processingFormat)
        
        player.scheduleFile(audioFile, at: nil) {
            engine.stop()
            player.stop()
            completion(outputURL)
        }
        
        try! engine.start()
        player.play()
    }
}
