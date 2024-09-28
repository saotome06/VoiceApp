import Foundation
import Combine
import AVFoundation
import Speech
import SwiftUI

final class SpeechRecorder: ObservableObject {
    @Published var audioText: String = ""
    @Published var audioRunning: Bool = false
    @Published var lastUpdateTime: Date?
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var inactivityTimer: Timer?
    private let inactivityThreshold: TimeInterval = 1.0 // インアクティビティの閾値（秒）
    private let chatGPTService = ChatGPTService(systemContent: 
        """
        この文章はユーザーが音声入力で喋った内容です。この文章が途中で途切れているかどうかを判定して。
        途切れていない場合や判断がつかない場合は「True」、途中で途切れている場合は「False」と回答してください。
        例：「ラーメンと野菜と」「この間のスパイダーマ」などのように明らかに喋り途中だとわかる場合は「False」にして。
        以下の文章を判断してください。
        """
    )
    private var finished_talk_wait_count: Int = 0
    
    func toggleRecording() {
        if self.audioEngine.isRunning {
            self.stopRecording()
        } else {
            try! self.startRecording()
            //            audioRecorder.startRecording()
        }
    }
    
    func stopRecording() {
        self.recognitionTask?.cancel()
        self.recognitionTask?.finish()
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.audioEngine.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch {
            print("AVAudioSession error")
        }
        
        self.audioRunning = false
        self.inactivityTimer?.invalidate()
        self.inactivityTimer = nil
    }
    
    func startRecording() throws {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        if self.recognitionRequest == nil {
            self.stopRecording()
            return
        }
        
        self.audioText = ""
        recognitionRequest?.shouldReportPartialResults = true
        if #available(iOS 13, *) {
            recognitionRequest?.requiresOnDeviceRecognition = false
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if let error = error {
                print(String(describing: error))
                self.stopRecording()
                return
            }
            
            if let result = result {
                self.audioText = result.bestTranscription.formattedString
                self.resetUpdateTime()
//                self.resetInactivityTimer()
                
                if result.isFinal {
                    print("録音タイムリミット")
//                    self.stopRecording()
                    inputNode.removeTap(onBus: 0)
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        try self.audioEngine.start()
        self.audioRunning = true
        self.resetInactivityTimer()
    }
    
    private func resetInactivityTimer() {
        self.inactivityTimer?.invalidate()
        self.inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityThreshold, repeats: false) { _ in
            self.checkInactivity()
        }
    }
    
    private func checkInactivity() {
        let now = Date()
        if let lastUpdate = self.lastUpdateTime, now.timeIntervalSince(lastUpdate) >= inactivityThreshold {
            if !self.audioText.isEmpty {
                // ChatGPTを使って、テキストが完結しているか判定する
//                self.checkIfAudioTextIsComplete()
                self.stopRecording()
                //                audioRecorder.stopRecording()
                //                let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav")
                //                audioPlayer.playAudio(url: wavFilePath)
                //                let wavFilePath = audioRecorder.getDocumentsDirectory().appendingPathComponent("recording.wav").path
                //                analyzeWav(apiKey: apiKey, wavFilePath: wavFilePath)
            } else {
                // リセットが間に合わなかった場合に備えて再度タイマーを設定
                self.resetInactivityTimer()
            }
        } else {
            // リセットが間に合わなかった場合に備えて再度タイマーを設定
            self.resetInactivityTimer()
        }
    }
    
    func resetUpdateTime() {
        lastUpdateTime = Date()
    }
    
    // 音声認識後に自然言語処理を使って判定するメソッド
    func checkIfAudioTextIsComplete() {
        guard !self.audioText.isEmpty else { return }
        chatGPTService.fetchResponse(self.audioText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("ChatGPTからの返答: \(response)")
                    print(self?.audioText)
                    
                    // ChatGPTの返答を分析して、完了していると判断した場合に録音を停止する
                    if response.contains("False") || response.contains("false") {
                        if self!.finished_talk_wait_count >= 3 {
                            self?.stopRecording()
                        }
                        self?.resetInactivityTimer()
                        self?.finished_talk_wait_count += 1
                    } else {
                        self?.stopRecording()
                        self?.finished_talk_wait_count = 0
                    }
                    
                case .failure(let error):
                    print("エラーが発生しました: \(error.localizedDescription)")
                }
            }
        }
    }
}
