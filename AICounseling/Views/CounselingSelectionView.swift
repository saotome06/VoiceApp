import SwiftUI

struct CounselingSelectionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダー
                Text("カウンセリングの選択")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 説明文
                Text("あなたに合ったカウンセリング方法を選んでください。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // カウンセリングオプション
                VStack(alignment: .leading, spacing: 15) {
                    TalkDialogView(
                        iconName: "message.fill",
                        title: "チャットカウンセリング",
                        description: "カウンセラーとチャットで相談"
                    )

                    MoveView(iconName: "mic.fill", title: "音声カウンセリング", description: "カウンセラーと音声通話で相談", destination: CounselorListView(counselors: sampleCounselors))
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 追加情報
                InfoSectionView(title: "カウンセリングの特徴", items: [
                    "会話内容は他人には見られません",
                    "その時の気分に応じて、トーク内容を選択できます",
                    "音声カウンセリングを行うと、会話中の音声から自動でストレス診断が行われます",
                ])
                
            }
            .padding()
        }
    }
}

struct InfoSectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


struct CounselingSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CounselingSelectionView()
    }
}
