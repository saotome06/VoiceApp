import SwiftUI

struct LogResetFormView: View {
    @State private var completionMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            WarningModalView()
            
            VStack(spacing: 20) {
                Button(action: {
                    resetLogData()
                }) {
                    Text("カウンセリングの会話履歴を削除")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("「とにかく話す」「アドバイスが欲しい」トークの履歴が削除されます。")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                Button(action: {
                    resetCBTLogData()
                }) {
                    Text("認知行動療法の会話履歴を削除")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("「考えの歪みを知る」「ストレスに強くなる」トークの履歴が削除されます。")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if !completionMessage.isEmpty {
                Text(completionMessage)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding()
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

struct WarningModalView: View {
    var body: some View {
        VStack {
            Text("※これまでの会話履歴が削除されるとAIとの会話の記憶も失われます。")
                .font(.title3)
                .foregroundColor(.red)
                .padding(.bottom, 5)
            Text("※読み込みが重くなってしまった時やAIとのやりとりがおかしくなってしまった時以外は基本的に消さないことをおすすめします。")
                .font(.title3)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

struct LogResetFormView_Previews: PreviewProvider {
    static var previews: some View {
        LogResetFormView()
    }
}
