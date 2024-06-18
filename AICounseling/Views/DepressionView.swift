import SwiftUI

struct DepressionView: View {
    @State private var stressLevel: StressLevel? // ストレスレベルをOptionalに変更
    
    var body: some View {
        VStack {
            if let stressLevel = stressLevel {
                Text(stressLevel.emoji)
                    .font(.system(size: 130))
                Text(stressLevel.description)
                    .font(.title)
                    .padding()
            } else {
                Text("ストレス診断をしてください")
                    .font(.title)
                    .padding()
                NavigationLink(destination: DepressionJudgmentView()) {
                    Text("ストレス診断を行う")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let result = try await SelectDepressionResult()
                    if let result = result, let stressLevelEnum = StressLevel(rawValue: result) {
                        self.stressLevel = stressLevelEnum
                    } else {
                        self.stressLevel = nil
                    }
                } catch {
                    print("Error fetching Empath result: \(error)")
                    self.stressLevel = nil
                }
            }
        }
    }
}

enum StressLevel: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var emoji: String {
        switch self {
        case .low:
            return "😊" // 笑顔のアイコン
        case .medium:
            return "😟" // 不安そうな顔のアイコン
        case .high:
            return "😞" // ダウンしている顔のアイコン
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return "良好な状態です"
        case .medium:
            return "少しストレスを感じています"
        case .high:
            return "高ストレスな状態です"
        }
    }
}

struct DepressionView_Previews: PreviewProvider {
    static var previews: some View {
        DepressionView()
    }
}
