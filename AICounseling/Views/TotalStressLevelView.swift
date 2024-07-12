import SwiftUI

struct TotalStressLevelView: View {
    let empathEmotionData: [EmpathData]
    let pyFeatEmotionData: [Emotion]
    @State private var stressLevel: StressLevel?
    @State private var voiceStressLevel: StressLevel?
    @State private var faceStressLevel: StressLevel?
    @State private var totalNegativeEmotionDiff: Double = 0
    @State private var highStressCount: Int?

    var body: some View {
        VStack {
            if stressLevel == nil || voiceStressLevel?.description == "データがまだありません" || faceStressLevel?.description == "データがまだありません" {
                Text("診断できていない項目があります")
                    .foregroundColor(.red)
                    .font(.title)
                    .padding()
            } else {
                if let combinedStressLevel = determineCombinedStressLevel() {
                    Text(combinedStressLevel.emoji)
                        .font(.system(size: 130))
                    Text(combinedStressLevel.description)
                        .foregroundColor(combinedStressLevel.color)
                        .font(.title)
                        .padding()
                }
            }
            Text("抑うつチェック、声、表情からあなたのストレス状態を診断します")
                .font(.caption)
                .padding()
        }
        .onAppear {
            Task {
                do {
                    let (result, count) = try await SelectDepressionResult()
                    if let result = result, let stressLevelEnum = StressLevel(rawValue: result) {
                        self.stressLevel = stressLevelEnum
                        self.highStressCount = count
                    } else {
                        self.stressLevel = nil
                        self.highStressCount = nil
                    }
                } catch {
                    print("Error fetching Empath result: \(error)")
                    self.stressLevel = nil
                }
            }
            
            let average = calculateAverage(emotionData: empathEmotionData)
            let emotionDiff = calculateDifference(from: empathEmotionData.last ?? EmpathData(joy: 1, calm: 1, anger: 1, vigor: -7, sorrow: 10, timestamp: "", primalEmotion: "Sorrow", primalEmotionValue: 10), to: average)
            totalNegativeEmotionDiff = Double(emotionDiff.vigor + emotionDiff.anger + emotionDiff.calm)
            calculateVoiceStressLevel()
            calculateFaceStressLevel()
        }
    }
    
    func determineCombinedStressLevel() -> StressLevel? {
        if stressLevel == .high || voiceStressLevel == .high || faceStressLevel == .high {
            return .high
        } else if stressLevel == .medium || voiceStressLevel == .medium || faceStressLevel == .medium {
            return .medium
        } else {
            return .low
        }
    }
    
    func calculateVoiceStressLevel() {
        var stressResult = "Low"
        if totalNegativeEmotionDiff < -10 {
            stressResult = "High"
        } else if totalNegativeEmotionDiff < 0 {
            stressResult = "Medium"
        }
        if empathEmotionData.isEmpty {
            stressResult = "None"
        }
        self.voiceStressLevel = StressLevel(rawValue: stressResult)
    }
    
    func calculateFaceStressLevel() {
        var stressResult = "Low"
        for emotion in pyFeatEmotionData {
            if ["怒り", "嫌悪", "恐れ", "悲しみ", "驚き"].contains(emotion.japaneseType) && emotion.value * 50 >= 40 {
                stressResult = "High"
            } else if ["怒り", "嫌悪", "恐れ", "悲しみ", "驚き"].contains(emotion.japaneseType) && emotion.value * 50 >= 20 {
                stressResult = "Medium"
            } else if ["怒り", "嫌悪", "恐れ", "悲しみ", "驚き"].contains(emotion.japaneseType) && emotion.value == 0 {
                stressResult = "None"
            }
        }
        self.faceStressLevel = StressLevel(rawValue: stressResult)
    }
}

struct TotalStressLevelView_Previews: PreviewProvider {
    static var previews: some View {
        TotalStressLevelView(empathEmotionData: [
            EmpathData(joy: 1, calm: 1, anger: 1, vigor: -7, sorrow: 10, timestamp: "2024-07-01T15:51:23.171100", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: 2, anger: 1, vigor: -20, sorrow: 10, timestamp: "2024-07-01T15:51:37.037020", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: 2, anger: 1, vigor: -20, sorrow: 10, timestamp: "2024-07-01T15:52:03.007577", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: -20, anger: 1, vigor: -10, sorrow: -10, timestamp: "2024-07-01T15:52:15.145088", primalEmotion: "Sorrow", primalEmotionValue: 10)
        ],
        pyFeatEmotionData: [
            Emotion(type: "anger", value: 0.0272749737),
            Emotion(type: "disgust", value: 0.0001604069),
            Emotion(type: "fear", value: 0.0302514918),
            Emotion(type: "happiness", value: 0.1028032377),
            Emotion(type: "sadness", value: 0.0216290057),
            Emotion(type: "surprise", value: 0.8147978783),
            Emotion(type: "neutral", value: 0.0030830486)
        ])
    }
}
