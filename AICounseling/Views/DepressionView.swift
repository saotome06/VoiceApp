import SwiftUI

struct DepressionView: View {
    @State private var stressLevel: StressLevel? // ストレスレベルをOptionalに変更
    
    var body: some View {
        VStack {
            Text("抑うつ診断結果")
                .font(.largeTitle)
                .padding(.top, 40) // 上部にスペースを追加
            Spacer() // 残りのスペースを下に持ってくる
        
            if let stressLevel = stressLevel {
                Text(stressLevel.emoji)
                    .font(.system(size: 130))
                Text(stressLevel.depressionDescription)
                    .font(.title)
                    .padding()
                    .foregroundColor(stressLevel.color)
                NavigationLink(destination: DepressionJudgmentView()) {
                    Text("抑うつ診断を行う")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
            } else {
                Text("抑うつ診断結果がありません")
                    .font(.title)
                    .padding()
                NavigationLink(destination: DepressionJudgmentView()) {
                    Text("抑うつ診断を行う")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 20)
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
