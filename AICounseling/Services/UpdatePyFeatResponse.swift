import Foundation

func ExecuteUpdatePyFeatResponse(jsonDict: [String: Any]) async {
    do {
        guard let response = PyFeatResponse.fromDictionary(jsonDict) else {
            print("Failed to create EmpathResponse from dictionary")
            return
        }
        
        try await UpdatePyFeatResponse(response: response)
        print("PyFeatが更新されました")
    } catch {
        // エラーが発生した場合の処理
        print("Failed to update user details:", error)
    }
}

func UpdatePyFeatResponse(response: PyFeatResponse) async throws {
    try await supabaseClient
        .from("users")
        .update([
            "pyfeat_response": response
        ])
        .eq("user_email", value: userEmail)
        .execute()
}
