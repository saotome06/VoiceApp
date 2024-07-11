import SwiftUI

struct DepressionView: View {
    @State private var stressLevel: StressLevel? // ストレスレベルをOptionalに変更
    @State private var highStressCount: Int?
    
    var body: some View {
        VStack {
            Text("抑うつ診断結果")
                .font(.largeTitle)
                .padding(.top, 40) // 上部にスペースを追加
            Spacer() // 残りのスペースを下に持ってくる
        
            if let stressLevel = stressLevel {
                VStack(alignment: .leading, spacing: 20) {
                    Text(stressLevel.depressionDescription)
                        .font(.title2)
                        .foregroundColor(stressLevel.color)
                    
                    ProgressView(value: Double(highStressCount ?? 0), total: 9)
                        .accentColor(progressColor)
                        .frame(height: 20)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("ストレス度: \(highStressCount ?? 0)/9")
                        .font(.headline)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(radius: 5)
                Spacer() // 残りのスペースを下に持ってくる
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
                    let (result, count) = try await SelectDepressionResult()
                    if let result = result, let stressLevelEnum = StressLevel(rawValue: result) {
                        self.stressLevel = stressLevelEnum
                        self.highStressCount = count
                    } else {
                        self.stressLevel = nil
                        self.highStressCount = nil
                    }
                } catch {
                    print("Error fetching Empath result: \(error)")
                    self.stressLevel = nil
                    self.highStressCount = nil
                }
            }
        }
    }
    private var progressColor: Color {
        guard let count = highStressCount else { return .gray }
        if count >= 7 {
            return .red
        } else if count >= 1 {
            return .yellow
        } else {
            return .green
        }
    }
}

struct DepressionView_Previews: PreviewProvider {
    static var previews: some View {
        DepressionView()
    }
}
