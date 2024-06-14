import SwiftUI

struct EmpathGraphView: View {
    let emotions: [EmpathEmotion]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("音声認識")
                    .font(.largeTitle)
                    .padding()
                
                if let energyEmotion = emotions.first(where: { $0.type.lowercased() == "energy" }) {
                    VStack {
                        Text("元気度")
                            .font(.title2)
                            .padding(.top)
                        
                        EnergyPieChartView(energy: energyEmotion.value)
                            .frame(width: 200, height: 200)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Text("感情")
                    .font(.title2)
                    .padding(.top)
                
                EmpathBarChartView(emotions: emotions.filter { $0.type.lowercased() != "energy" && $0.type.lowercased() != "error" })
                    .frame(height: 300)
                    .padding()
                
                List(emotions.filter { $0.type.lowercased() != "error"}) { emotion in
                    HStack {
                        Text(emotion.japaneseType)
                        Spacer()
                        Text(String(format: "%.0f", emotion.value))
                    }
                }
                .frame(height: CGFloat(emotions.count) * 50)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct EmpathBarChartView: View {
    let emotions: [EmpathEmotion]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(emotions) { emotion in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(emotion.color)
                            .frame(width: (geometry.size.width / CGFloat(emotions.count)) * 0.8,
                                   height: CGFloat(emotion.value) / 50 * geometry.size.height)
                            .cornerRadius(20)
                        Text(emotion.japaneseType)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

struct EmpathEmotion: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
    
    var japaneseType: String {
        switch type.lowercased() {
        case "anger": return "怒り"
        case "sorrow": return "悲しみ"
        case "energy": return "エネルギー"
        case "calm": return "落ち着き"
        case "joy": return "喜び"
        case "error": return "エラー"
        default: return "不明"
        }
    }
    
    var color: Color {
        switch type.lowercased() {
        case "anger": return .red
        case "sorrow": return .blue
        case "energy": return .orange
        case "calm": return .green
        case "joy": return .yellow
        case "error": return .gray
        default: return .black
        }
    }
}

struct EmpathGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EmpathGraphView(emotions: [
            EmpathEmotion(type: "error", value: 0),
            EmpathEmotion(type: "sorrow", value: 0),
            EmpathEmotion(type: "energy", value: 40),
            EmpathEmotion(type: "anger", value: 5),
            EmpathEmotion(type: "calm", value: 39),
            EmpathEmotion(type: "joy", value: 3)
        ])
    }
}
