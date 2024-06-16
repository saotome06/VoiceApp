import Foundation

func ExecuteUpdateEmpathResponse(jsonDict: [String: Any]) async {
    do {
        guard let response = EmpathResponse.fromDictionary(jsonDict) else {
            print("Failed to create EmpathResponse from dictionary")
            return
        }
        
        try await UpdateEmpathResponse(response: response)
        try await UpdateEmpathStatus(status: true)
        print("Empathが更新されました")
    } catch {
        // エラーが発生した場合の処理
        print("Failed to update user details:", error)
    }
}

func UpdateEmpathResponse(response: EmpathResponse)
    async throws {
        try await supabaseClient
            .from("users")
            .update([
                "empath_response": response
            ])
            .eq("user_email", value: userEmail)
            .execute()
        }

func UpdateEmpathStatus(status: Bool)
    async throws {
        try await supabaseClient
            .from("users")
            .update([
                "empath_status": status
            ])
            .eq("user_email", value: userEmail)
            .execute()
    }

func SelectEmpathStatus() {
    Task {
        do {
            let empathStaus: [StausEmpath] = try await supabaseClient
                .from("users")
                .select("empath_status")
                .eq("user_email", value: userEmail)
                .execute()
                .value
            print(empathStaus)
            print("ステータス更新かくにん")
        }
    }
}
