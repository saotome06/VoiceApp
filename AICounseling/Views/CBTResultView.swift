import SwiftUI

struct CBTResultView: View {
    @State private var cbtTypeResult: [String] = []
//    let cbtTypeResult = [
//        "Fortune-telling",
//        "Mind Reading",
//        "All-or-nothing thinking",
//        "Personalization",
//        "Emotional reasoning",
//        "Labeling",
//        "Mind Reading",
//        "Personalization",
//        "Mind Reading",
//        "Emotional reasoning",
//        "All-or-nothing thinking"
//    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("あなたの心の傾向")
                    .font(.largeTitle)
                    .padding()
                
                if let latestType = cbtTypeResult.last {
                    VStack {
                        Text(CbtType.type[latestType]?[1] ?? latestType)
                            .font(.title)
                            .padding()
                            .foregroundColor(.green)
                        Text(CbtType.description[latestType] ?? latestType)
                            .font(.title3)
                            .padding()
                            .foregroundColor(.gray)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
                
                CBTPieChartView(data: summarizeData())
                    .frame(height: 350)
                    .padding(.bottom, 50)
                
                Spacer()
                
                Text("これまでの心の傾向")
                    .font(.title2)
                    .padding()
                
                VStack(alignment: .leading) {
                    ForEach(cbtTypeResult.indices.reversed(), id: \.self) { index in
                        HStack {
                            Text("\(index + 1)回目の診断:")
                            VStack(alignment: .leading) {
                                Text(CbtType.type[cbtTypeResult[index]]?[0] ?? cbtTypeResult[index])
                                    .fontWeight(index == cbtTypeResult.count - 1 ? .bold : .regular)
                                    .foregroundColor(index == cbtTypeResult.count - 1 ? .blue : .primary)
                                Text(CbtType.type[cbtTypeResult[index]]?[1] ?? "")
                                    .fontWeight(index == cbtTypeResult.count - 1 ? .bold : .regular)
                                    .foregroundColor(index == cbtTypeResult.count - 1 ? .blue : .primary)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            Task {
                do {
                    let currentCbtType = try await selectCbtType()
                    self.cbtTypeResult.append(contentsOf: currentCbtType)
                    print(cbtTypeResult)
                } catch {
                    print("Error fetching CBT types: \(error)")
                }
            }
        }
    }
    
    private func summarizeData() -> [String: Int] {
        var summary = [String: Int]()
        for pattern in cbtTypeResult {
            summary[pattern, default: 0] += 1
        }
        return summary
    }
}

struct CBTPieChartView: View {
    let data: [String: Int]
    
    var colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .mint, .indigo
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let total = data.values.reduce(0, +)
            let angles = calculateAngles(data: data, total: total)
            
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let (key, value) = data.sorted(by: { $0.value > $1.value })[index]
                    let startAngle = angles[index].start
                    let endAngle = angles[index].end
                    let percentage = Double(value) / Double(total) * 100
                    
                    PieSliceView(startAngle: startAngle, endAngle: endAngle, holeRadius: geometry.size.width / 2.7)
                        .fill(colors[index % colors.count])
                        .overlay(
                            PieSliceLabelView(label: "\(CbtType.type[key]?[1] ?? key) \(String(format: "%.1f", percentage))%", startAngle: startAngle, endAngle: endAngle, geometry: geometry, color: colors[index % colors.count])
                        )
                }
                Text("傾向の出現回数")
                    .font(.title2)
                    .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .padding(20)
    }
    
    private func calculateAngles(data: [String: Int], total: Int) -> [(start: Angle, end: Angle)] {
        var angles: [(start: Angle, end: Angle)] = []
        var startAngle: Angle = .degrees(0)
        
        for (_, value) in data.sorted(by: { $0.value > $1.value }) {
            let proportion = Double(value) / Double(total)
            let endAngle = startAngle + .degrees(proportion * 360)
            angles.append((start: startAngle, end: endAngle))
            startAngle = endAngle
        }
        
        return angles
    }
}

struct PieSliceView: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var holeRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        path.move(to: CGPoint(x: center.x + holeRadius * cos(CGFloat(startAngle.radians)),
                              y: center.y + holeRadius * sin(CGFloat(startAngle.radians))))
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLine(to: CGPoint(x: center.x + holeRadius * cos(CGFloat(endAngle.radians)),
                                 y: center.y + holeRadius * sin(CGFloat(endAngle.radians))))
        path.addArc(center: center, radius: holeRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        return path
    }
}

struct PieSliceLabelView: View {
    var label: String
    var startAngle: Angle
    var endAngle: Angle
    var geometry: GeometryProxy
    var color: Color
    
    var body: some View {
        let angle = (startAngle + endAngle) / 2
        let radius = geometry.size.width / 2 * 0.7
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.width / 2)
        let labelPosition = CGPoint(x: center.x + CGFloat(cos(angle.radians)) * radius,
                                    y: center.y + CGFloat(sin(angle.radians)) * radius)
        
        return Text(label)
            .font(.headline)
            .foregroundColor(color)
            .padding(5)
            .background(Color.white.opacity(0.7))
            .cornerRadius(5)
            .position(x: labelPosition.x, y: labelPosition.y)
    }
}

struct CBTResultView_Previews: PreviewProvider {
    static var previews: some View {
        CBTResultView()
    }
}
