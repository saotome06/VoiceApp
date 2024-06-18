import SwiftUI

struct StressView: View {
    @State private var empathResponse: EmpathResponse?
    
    var body: some View {
        TabView {
            DepressionView()
            .tabItem {
                Label("ストレス状態", systemImage: "heart.circle.fill")
            }
            EmpathGraphView(emotions: self.empathResponse.map { emotions(for: $0) } ?? defaultEmotions())
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
//            EmpathGraphView(emotions: [
//                EmpathEmotion(type: "error", value: 0),
//                EmpathEmotion(type: "sorrow", value: 0),
//                EmpathEmotion(type: "energy", value: 10),
//                EmpathEmotion(type: "anger", value: 5),
//                EmpathEmotion(type: "calm", value: 39),
//                EmpathEmotion(type: "joy", value: 3)
//            ])
        }
        .onAppear {
            Task {
                do {
                    self.empathResponse = try await SelectEmpathResult()
                } catch {
                    print("Error fetching Empath result: \(error)")
                }
            }
        }
    }
    
    private func emotions(for empathResponse: EmpathResponse) -> [EmpathEmotion] {
        return [
            EmpathEmotion(type: "error", value: empathResponse.error),
            EmpathEmotion(type: "sorrow", value: empathResponse.sorrow),
            EmpathEmotion(type: "energy", value: empathResponse.energy),
            EmpathEmotion(type: "anger", value: empathResponse.anger),
            EmpathEmotion(type: "calm", value: empathResponse.calm),
            EmpathEmotion(type: "joy", value: empathResponse.joy)
        ]
    }
    
    private func defaultEmotions() -> [EmpathEmotion] {
        return [
            EmpathEmotion(type: "error", value: 0),
            EmpathEmotion(type: "sorrow", value: 0),
            EmpathEmotion(type: "energy", value: 0),
            EmpathEmotion(type: "anger", value: 0),
            EmpathEmotion(type: "calm", value: 0),
            EmpathEmotion(type: "joy", value: 0)
        ]
    }
}

struct StressView_Previews: PreviewProvider {
    static var previews: some View {
        StressView()
    }
}
