import SwiftUI

struct DepressionView: View {
    @State private var stressLevel: StressLevel? // ストレスレベルをOptionalに変更
    
    var body: some View {
        VStack {
            if let stressLevel = stressLevel {
                Text(stressLevel.emoji)
                    .font(.system(size: 130))
                Text(stressLevel.depressionDescription)
                    .font(.title)
                    .padding()
                    .foregroundColor(stressLevel.color)
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

struct DepressionView_Previews: PreviewProvider {
    static var previews: some View {
        DepressionView()
    }
}
