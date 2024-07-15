import Supabase
import SwiftUI

struct UserRegistView: View {
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
    
    @State private var nickname: String = ""
    @State private var gender: String = ""
    @State private var birthdate = Date()
    @State private var selectedGender: Gender?
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var UserRegistSuccessMessage: String?
    @State private var isUserDataComplete = false
    @State private var isLoading = false

    private let userEmail: String = UserDefaults.standard.string(forKey: "user_email") ?? ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("プロフィール登録画面")
                .font(.title)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
            
            TextField("ニックネーム", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
//            Text("生年月日")
//                .font(.headline)
//            DatePicker("", selection: $birthdate, displayedComponents: .date)
//                .labelsHidden()
//                .datePickerStyle(WheelDatePickerStyle())
//                .environment(\.locale, Locale(identifier: "ja_JP"))
//                .frame(maxHeight: 200)
            
            Text("性別")
                .font(.headline)
            HStack {
                ForEach(Gender.allCases, id: \.self) { gender in
                    RadioButton(title: gender.rawValue, isSelected: selectedGender == gender) {
                        self.selectedGender = gender
                    }
                }
            }
            Button(action: {
                Task {
                    await registerUser()
                }
            }) {
                Text("登録")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .disabled(isLoading)

            if isLoading { 
                ProgressView()
            }
            
        }
        .padding()
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isUserDataComplete) {
            MainView()
        }
        
        if let message = UserRegistSuccessMessage {
            Text(message)
                .foregroundColor(.green)
                .padding()
        }

    }

    func registerUser() async {
        if validateInput() {
            do {
                try await updateUserDetails(email: userEmail, nickname: nickname, birthdate: birthdate, gender: selectedGender?.key ?? "")
                try await upsertUserAction(email: userEmail)
                isUserDataComplete = true 
                UserRegistSuccessMessage = "ユーザ登録に成功しました"
            } catch {
                print("Failed to update user details:", error)
                isUserDataComplete = false
                alertMessage = "ユーザ登録に失敗しました: \(error.localizedDescription)"
                isShowingAlert = true
            }
            isLoading = false

        }
    }

    func validateInput() -> Bool {
        if nickname.isEmpty {
            alertMessage = "ニックネームを入力してください"
            isShowingAlert = true
            return false
        }

        if selectedGender == nil {
            alertMessage = "性別を選択してください"
            isShowingAlert = true
            return false
        }

        return true
    }
    
    func upsertUserAction(email: String)
        async throws {
            try await client
                .from("action_num")
                .upsert(
                [
                    "user_email": email
                ],
                onConflict: "user_email"
            )
            .execute()
        }
    
    
    func updateUserDetails(email: String, nickname: String, birthdate: Date, gender: String)
        async throws {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            
            let birthdateString = dateFormatter.string(from: birthdate)
            try await client
                .from("users")
                .update([
                    "nickname": nickname,
                    "birthdate": birthdateString,
                    "gender": gender
                ])
                .eq("user_email", value: email)
                .execute()

            DispatchQueue.main.async {
                UserDefaults.standard.set(nickname, forKey: "nickname")
                UserDefaults.standard.set(birthdateString, forKey: "birthdate")
                UserDefaults.standard.set(gender, forKey: "gender")
                UserDefaults.standard.set(true, forKey: "isUserDataComplete")
            }
        }
    
}


enum Gender: String, CaseIterable {
    case male = "男"
    case female = "女"
    case unspecified = "選択しない"
    
    var key: String {
        switch self {
            case .male:
                return "male"
            case .female:
                return "female"
            case .unspecified:
                return "unspecified"
        }
    }
}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                Text(title)
            }
        }
        .foregroundColor(isSelected ? .blue : .primary)
        .padding(.horizontal)
    }
    
}

struct UserRegistView_Previews: PreviewProvider {
    static var previews: some View {
        UserRegistView()
    }
}
