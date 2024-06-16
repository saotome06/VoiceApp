import SwiftUI

struct EnergyPieChartView: View {
    public let energy: Double
    public let maxEnergy: Double = 50.0
    
    @State public var trimValue: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: trimValue)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0)) // アニメーションを追加
                
                Text(String(format: "%.0f%%", energy / maxEnergy * 100))
                    .font(.largeTitle)
                    .bold()
            }
            .onAppear {
                updateTrimValue()
            }
            .frame(width: 200, height: 200)
        }
    }
    
    public func updateTrimValue() {
        withAnimation {
            trimValue = CGFloat(energy / maxEnergy)
        }
    }
}

struct EnergyPieChartView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyPieChartView(energy: 10.0)
    }
}
