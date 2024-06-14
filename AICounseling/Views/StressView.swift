import SwiftUI

struct StressView: View {
    var body: some View {
        TabView {
            EmpathGraphView(emotions: [
                EmpathEmotion(type: "error", value: 0),
                EmpathEmotion(type: "sorrow", value: 0),
                EmpathEmotion(type: "energy", value: 40),
                EmpathEmotion(type: "anger", value: 5),
                EmpathEmotion(type: "calm", value: 39),
                EmpathEmotion(type: "joy", value: 3)
            ])
            .tabItem {
                Label("音声認識", systemImage: "waveform")
            }
            EmotionView(emotions: [
                Emotion(type: "anger", value: 0.0272749737),
                Emotion(type: "disgust", value: 0.0001604069),
                Emotion(type: "fear", value: 0.0302514918),
                Emotion(type: "happiness", value: 0.1028032377),
                Emotion(type: "sadness", value: 0.0216290057),
                Emotion(type: "surprise", value: 0.8147978783),
                Emotion(type: "neutral", value: 0.0030830486)
            ])
            .tabItem {
                Label("表情認識", systemImage: "face.smiling")
            }
        }
    }
}

struct StressView_Previews: PreviewProvider {
    static var previews: some View {
        StressView()
    }
}
