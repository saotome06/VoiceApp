import SwiftUI

struct EmotionLabelView: View {
    let emotion: Emotion
    
    var body: some View {
        HStack {
            Circle()
                .fill(emotion.color)
                .frame(width: 10, height: 10)
            Text(emotion.type.capitalized)
                .fontWeight(.bold)
            Spacer()
            Text(String(format: "%.5f", emotion.value))
        }
        .padding(.horizontal)
    }
}
