import SwiftUI

struct LogResetFormView: View {
    @State private var completionMessage: String = ""
    
    var body: some View {
        VStack {
            Text("※これまでの会話履歴が削除されるとAIとの会話の記憶も失われます。")
                .font(.title3)
                .padding()
                .foregroundColor(.red)
            Text("※読み込みが重くなってしまった時やAIとのやりとりがおかしくなってしまった時以外は基本的に消さないことをおすすめします。")
                .font(.title3)
                .padding()
                .foregroundColor(.red)
            
            Button(action: {
                resetLogData()
            }) {
                Text("カウンセリングの会話履歴を削除")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Text("「とにかく話す」「アドバイスが欲しい」トークの履歴が削除されます。")
                .font(.title3)
                .padding()
                .foregroundColor(.gray)
            
            Button(action: {
                resetCBTLogData()
            }) {
                Text("認知行動療法の会話履歴を削除")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Text("「考えの歪みを知る」「ストレスに強くなる」トークの履歴が削除されます。")
                .font(.title3)
                .padding()
                .foregroundColor(.gray)
            
            if !completionMessage.isEmpty {
                Text(completionMessage)
                    .font(.title3)
                    .padding()
                    .foregroundColor(.green)
            }
        }
    }
    
    private func resetLogData() {
        Task {
            do {
                await ExecuteDeleteLogData()
                completionMessage = "削除が完了しました"
            } catch {
                completionMessage = "削除に失敗しました"
            }
        }
    }
    
    private func resetCBTLogData() {
        Task {
            do {
                await ExecuteDeleteCBTLogData()
                completionMessage = "削除が完了しました"
            } catch {
                completionMessage = "削除に失敗しました"
            }
        }
    }
}

struct LogResetFormView_Previews: PreviewProvider {
    static var previews: some View {
        LogResetFormView()
    }
}
