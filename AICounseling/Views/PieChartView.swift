import SwiftUI

struct PieChartView: View {
    let emotions: [Emotion]
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let total = emotions.reduce(0) { $0 + $1.value }
                let angles = calculateAngles(for: emotions, total: total)
                
                ZStack {
                    ForEach(0..<emotions.count, id: \.self) { index in
                        PieChartSlice(startAngle: angles[index].0, endAngle: angles[index].1, color: emotions[index].color)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
            }
            .frame(height: 200)  // サイズを調整
            
            ForEach(emotions) { emotion in
                EmotionLabelView(emotion: emotion)
            }
        }
    }
    
    func calculateAngles(for emotions: [Emotion], total: Double) -> [(start: Angle, end: Angle)] {
        var angles: [(start: Angle, end: Angle)] = []
        var startAngle = Angle.degrees(0)
        
        for emotion in emotions {
            let endAngle = startAngle + Angle.degrees(360 * (emotion.value / total))
            angles.append((start: startAngle, end: endAngle))
            startAngle = endAngle
        }
        
        return angles
    }
}
