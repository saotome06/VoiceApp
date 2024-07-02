import SwiftUI

struct EmpathProgressBarChartView: View {
    var data: [CGFloat]
    var labels: [String]
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack {
                    Text(String(format: "%.0f", data[index]))
                        .font(.caption)
                    if data[index] >= 0 {
                        Spacer()
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 45, height: data[index] * 14)
                            .cornerRadius(20)
                    } else {
                        Spacer()
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 45, height: -data[index] * 14)
                            .cornerRadius(20)
                    }
                    Text(labels[index])
                        .font(.caption)
                }
                .padding(5)
            }
        }
        .padding()
    }
}
