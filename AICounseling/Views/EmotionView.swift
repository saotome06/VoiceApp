import SwiftUI

struct EmotionView: View {
    let emotions: [Emotion]

    var body: some View {
        List(emotions) { emotion in
            HStack {
                Text(emotion.type.capitalized)
                Spacer()
                Text(String(format: "%.5f", emotion.value))
            }
        }
    }
}

struct Emotion: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
}
