import SwiftUI

struct EnergyPieChartView: View {
    let energy: Double
    let maxEnergy: Double = 50.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat(energy / maxEnergy))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.0f%%", energy / maxEnergy * 100))
                    .font(.largeTitle)
                    .bold()
            }
            .frame(width: 200, height: 200)
        }
    }
}
