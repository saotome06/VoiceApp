import SwiftUI

struct EmpathGraphView: View {
    let emotions: [TestEmpathEmotion]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("音声認識")
                    .font(.largeTitle)
                    .padding()
                
                if let energyEmotion = emotions.first(where: { $0.type.lowercased() == "vigor" }) {
                    VStack {
                        Text("元気度")
                            .font(.title2)
                            .padding(.top)
                        
                        if energyEmotion.value <= 30 , isHighStress(){
                            Text("高いストレスを抱えている状態です")
                                .font(.title2)
                                .foregroundColor(.red)
                        }else if energyEmotion.value <= 25,isStress(){
                            Text("少しストレスを抱えている状態です")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }else{
                            Text("良好な状態です")
                            .font(.title2)
                            .foregroundColor(.green)

                        }
                            
                        EnergyPieChartView(energy: energyEmotion.value)
                            .frame(width: 200, height: 200)
                            .padding()


                    }
                    .frame(maxWidth: .infinity)
                }
                
                Text("感情")
                    .font(.title2)
                    .padding(.top)
                
                Spacer()
                
                EmpathBarChartView(emotions: emotions.filter { $0.type.lowercased() != "vigor" })
                    .frame(height: 300)
                    .padding()
                
                List(emotions.filter { $0.type.lowercased() != "error"}) { emotion in
                    HStack {
                        Text(emotion.japaneseType)
                        Spacer()
                        Text(String(format: "%.0f", emotion.value))
                    }
                }
                .frame(height: CGFloat(emotions.count) * 70)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    private func isHighStress() -> Bool {
        // max:50, 80% -> 40
        if let anger = emotions.first(where: { $0.type.lowercased() == "anger" }), anger.value >= 40 {
            return true
        }
        // max:50, 80% -> 40
        if let sadness = emotions.first(where: { $0.type.lowercased() == "sadness" }), sadness.value >= 40 {
            return true
        }
        
        return false
    }
    
    private func isStress() -> Bool {
        // max:50, 30% -> 15
        if let anger = emotions.first(where: { $0.type.lowercased() == "anger" }), anger.value >= 15 {
            return true
        }
        // max:50, 30% -> 15
        if let sadness = emotions.first(where: { $0.type.lowercased() == "sadness" }), sadness.value >= 15 {
            return true
        }
        
        return false
    }
}

struct EmpathBarChartView: View {
    let emotions: [TestEmpathEmotion]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                Spacer()
                ForEach(emotions) { emotion in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(emotion.color)
                            .frame(width: (geometry.size.width / CGFloat(emotions.count)) * 0.8,
                                   height: CGFloat(emotion.value) / 10 * geometry.size.height)
                            .cornerRadius(20)
                        Text(emotion.japaneseType)
                            .font(.caption)
                    }
                }
                Spacer()
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

struct TestEmpathEmotion: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
    
    var japaneseType: String {
        switch type.lowercased() {
        case "anger": return "怒り"
        case "calm": return "落ち着き"
        case "joy": return "喜び"
        case "sorrow": return "悲しみ"
        case "vigor": return "エネルギー"
        default: return "不明"
        }
    }
    
    var color: Color {
        switch type.lowercased() {
        case "anger": return .red
        case "calm": return .blue
        case "joy": return .orange
        case "sorrow": return .gray
        case "vigor": return .green
        default: return .black
        }
    }
}

struct EmpathGraphView_Previews: PreviewProvider {
    static var previews: some View {
        EmpathGraphView(emotions: [
            TestEmpathEmotion(type: "anger", value: 0),
            TestEmpathEmotion(type: "calm", value: 0),
            TestEmpathEmotion(type: "joy", value: 10),
            TestEmpathEmotion(type: "sorrow", value: 3),
            TestEmpathEmotion(type: "vigor", value: 10)
        ])
    }
}
