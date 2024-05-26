import SwiftUI

struct PieChartSlice: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let center = CGPoint(x: width / 2, y: height / 2)
                path.move(to: center)
                path.addArc(center: center, radius: width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .fill(color)
        }
    }
}
