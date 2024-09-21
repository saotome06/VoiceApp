import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    var apiKey: String {
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
//            AVSampleRateKey: 11025,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
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
//            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav").path
//            uploadFileToChunkEndpoint(filePath: audioFilename)
//            無料版EmpathAPI
//            Task {
//                do {
//                    let empathStaus: [StausEmpath] = try await supabaseClient
//                        .from("users")
//                        .select("empath_status")
//                        .eq("user_email", value: userEmail)
//                        .execute()
//                        .value
//                    if let firstStatus = empathStaus.first {
//                        let empathStatusValue = firstStatus.empath_status
//                        uploadFileToChunkEndpoint(filePath: audioFilename)
//                        if !empathStatusValue {
//                            analyzeWav(apiKey: apiKey, wavFilePath: audioFilename)
//                        }
//                    } else {
//                        print("empathStaus array is empty or nil")
//                    }
//                }
//            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
