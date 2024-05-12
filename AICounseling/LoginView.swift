import SwiftUI
import Speech
import OpenAISwift

struct LoginView: View {
    var body: some View {
        // メールアドレスとパスワードを入力し,決定を押すと送信される
        VStack {
            Text("ログイン")
                .font(.title)
                .padding()
            TextField("メールアドレス", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("パスワード", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                // ログイン処理
            }) {
                Text("ログイン")
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
