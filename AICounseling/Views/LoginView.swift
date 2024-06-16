import SwiftUI
import Speech
import OpenAISwift
import Supabase

struct User: Codable {
    var id: Int
    var nickname: String?
    var user_email: String
    var age: Int?
    var gender: String?
}

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var loginSuccessMessage: String?
    @State private var loginError: String?
    @State private var users: [User] = []
    @State private var errorMessage: String?
    @State private var isLoggedIn = false // ログイン状態を管理する変数
    
    private var supabaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not found in Info.plist or is not a valid URL")
        }
        return url
    }

    private var supabaseKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("SUPABASE_KEY not found in Info.plist")
        }
        return key
    }
//    private let supabaseURL = URL(string: "https://czzksxjserxpdjbfrojw.supabase.co")!
//    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6emtzeGpzZXJ4cGRqYmZyb2p3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYwNTQ3OTMsImV4cCI6MjAzMTYzMDc5M30.DAwICvLXS9Cvgs3RnheCbteLeDxxmEFuwwL0N-hYprM"
    private var client: SupabaseClient {
        print("tess111111", supabaseKey)
        print("tesstfafafaaff2222", supabaseURL)

        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    var body: some View {
        VStack {
            Text("ログイン")
                .font(.title)
                .padding()
            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                Task {
                    await fetchUsers()
                    checkLogin()
                }
            })
            {
                Text("ログイン")
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }else if let loginSuccessMessage = loginSuccessMessage {
                Text(loginSuccessMessage)
                    .foregroundColor(.green)
                    .padding()
            }

        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            UserRegistView()
        }


    }
    
    private func fetchUsers() async {
        do {
            let response = try await client
                .from("users")
                .select()
                .execute()
            let data = response.data
            let jsonDecoder = JSONDecoder()
            let users = try jsonDecoder.decode([User].self, from: data)

            DispatchQueue.main.async {
                self.users = users
                self.errorMessage = nil
            }
         
        } catch {
            print("Error fetching or decoding users: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching users: \(error.localizedDescription)"
            }
        }
        
        
    }

    private func checkLogin() {
        guard !email.isEmpty else {
            errorMessage = "メールアドレスを入力してください"
            return
        }
        
        guard users.contains(where: { $0.user_email == email }) else {
            errorMessage = "メールアドレスが見つかりません"
            return
        }
        
        loginSuccessMessage = "ログイン成功"
        isLoggedIn = true
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
