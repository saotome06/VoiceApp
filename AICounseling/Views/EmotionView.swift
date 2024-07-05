import SwiftUI

struct EmotionView: View {
    let emotions: [Emotion]
    @State private var faceStressLevel: StressLevel?
    
    var body: some View {
        ScrollView {
            VStack {
                Text("表情認識")
                    .font(.largeTitle)
                    .padding()
                
                if let stressLevel = faceStressLevel {
                    Text(stressLevel.description)
                        .font(.title)
                        .padding()
                        .foregroundColor(stressLevel.color)
                }
                
                BarChartView(emotions: emotions)
                    .frame(height: 300)
                    .padding()
                
                List(emotions) { emotion in
                    HStack {
                        Text(emotion.japaneseType)
                        Spacer()
                        Text(String(format: "%.5f", emotion.value * 50))
                    }
                }
                .frame(height: CGFloat(emotions.count) * 60)
            }
            .onAppear {
                calculateStressLevel()
            }
        }
    }
    
    func calculateStressLevel() {
        var stressResult = "Low"
        for emotion in emotions {
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

struct Emotion: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
    
    var japaneseType: String {
        switch type.lowercased() {
        case "anger": return "怒り"
        case "disgust": return "嫌悪"
        case "fear": return "恐れ"
        case "happiness": return "幸福"
        case "sadness": return "悲しみ"
        case "surprise": return "驚き"
        case "neutral": return "自然"
        default: return "不明"
        }
    }
    
    var color: Color {
        switch type.lowercased() {
        case "anger": return .red
        case "disgust": return .green
        case "fear": return .purple
        case "happiness": return .yellow
        case "sadness": return .blue
        case "surprise": return .orange
        case "neutral": return .gray
        default: return .black
        }
    }
}

struct EmotionView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionView(emotions: [
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
