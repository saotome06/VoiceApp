import Supabase
import SwiftUI

struct SupabaseService {
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

    private var client: SupabaseClient {
        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    func updateUserDetails(email: String, nickname: String, age: Int, gender: String) async throws {
        let response = try await client
            .from("users")
            .update(["nickname": nickname, "age": "\(age)", "gender": gender])
            .eq("user_email", value: email)
            .execute()
    }
}
struct UserRegistView: View {
    @State private var nickname: String = ""
    @State private var age: String = ""
    @State private var gender: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let supabaseService = SupabaseService()
    private let userEmail: String = UserDefaults.standard.string(forKey: "user_email") ?? ""

    var body: some View {
        VStack {
            TextField("ニックネーム", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("年齢", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("性別", text: $gender)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                Task {
                    await updateUserDetails()
                }
            }) {
                Text("更新")
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
    }

    private func updateUserDetails() async {
        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "有効な年齢を入力してください"
            return
        }

        do {
            try await supabaseService.updateUserDetails(email: userEmail, nickname: nickname, age: ageInt, gender: gender)
            DispatchQueue.main.async {
                self.successMessage = "ユーザー情報が更新されました"
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "ユーザー情報の更新に失敗しました: \(error.localizedDescription)"
                self.successMessage = nil
            }
        }
    }
}

struct UserRegistView_Previews: PreviewProvider {
    static var previews: some View {
        UserRegistView()
    }
}
