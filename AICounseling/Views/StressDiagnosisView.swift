import SwiftUI

struct StressDiagnosisView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // ヘッダー
                Text("ストレス診断方法の選択")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 説明文
                Text("ストレス診断方法を選んでください。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // カウンセリングオプション
                VStack(alignment: .leading, spacing: 15) {
                    MoveView(iconName: "cloud.fill", title: "抑うつチェック", description: "質問に答えてストレス診断", destination: DepressionJudgmentView())
                    MoveView(iconName: "face.smiling", title: "表情からストレス診断", description: "表情からストレス度を分析します", destination: PyFeatView())
                    MoveView(iconName: "mic.fill", title: "音声でストレス診断", description: "音声通話を行うと声によるストレス診断が行われます", destination: CounselorListView(counselors: sampleCounselors))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 追加情報
                InfoSectionView(title: "ストレス診断", items: [
                    "3つすべての診断を行うと「ストレス度の確認」ページよりあなたのストレス度合いの結果が見れます",
                    "表情からのストレス診断ではカメラを使用します"
                ])
                
            }
            .padding()
        }
    }
}

struct StressDiagnosisView_Previews: PreviewProvider {
    static var previews: some View {
        StressDiagnosisView()
    }
}
