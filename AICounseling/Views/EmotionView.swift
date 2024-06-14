import SwiftUI

struct EmotionView: View {
    let emotions: [Emotion]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("表情認識")
                    .font(.largeTitle)
                    .padding()
                
                BarChartView(emotions: emotions)
                    .frame(height: 300)
                    .padding()
                
                List(emotions) { emotion in
                    HStack {
                        Text(emotion.type.capitalized)
                        Spacer()
                        Text(String(format: "%.5f", emotion.value))
                    }
                }
                .frame(height: CGFloat(emotions.count) * 60)
            }
        }
    }
}

struct Emotion: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
    
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
