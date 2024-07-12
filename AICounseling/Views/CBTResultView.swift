import SwiftUI

struct CBTResultView: View {
    @State private var cbtTypeResult: [String] = []
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)  // 固定の上部マージン
                    Text("心の傾向分析")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if cbtTypeResult.isEmpty {
                        emptyStateView
                            .frame(height: geometry.size.height * 0.6)  // 画面の60%の高さを確保
                        Spacer()
                    } else {
                        latestResultView
                        CBTPieChartView(data: summarizeData())
                            .frame(height: 350)
                            .padding(.bottom, 50)
                        
                        historyView
                    }
                }
                .padding()
                .frame(minHeight: geometry.size.height)  // ScrollViewの最小の高さを画面の高さに設定
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .onAppear(perform: fetchData)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("まだ診断結果がありません")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("「考え方の歪みを知りたい」を選択して診断を始めましょう")
                .font(.title2)
                .foregroundColor(.secondary)
            
            NavigationLink(destination: CounselingSelectionView()) {
                Text("カウンセリングを行う")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private var latestResultView: some View {
        Group {
            if let latestType = cbtTypeResult.last {
                VStack(spacing: 15) {
                    Text("最新の診断結果")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(CbtType.type[latestType]?[1] ?? latestType)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(CbtType.description[latestType] ?? latestType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .shadow(radius: 5)
            }
        }
    }
    
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("診断履歴")
                .font(.title2.bold())
                .padding(.bottom, 5)
            
            ForEach(cbtTypeResult.indices.reversed(), id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.blue))
                    
                    VStack(alignment: .leading) {
                        Text(CbtType.type[cbtTypeResult[index]]?[0] ?? cbtTypeResult[index])
                            .font(.headline)
                        Text(CbtType.type[cbtTypeResult[index]]?[1] ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private func summarizeData() -> [String: Int] {
        var summary = [String: Int]()
        for pattern in cbtTypeResult {
            summary[pattern, default: 0] += 1
        }
        return summary
    }
    
    private func fetchData() {
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

// CBTPieChartView, PieSliceView, PieSliceLabelView は変更なし

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
