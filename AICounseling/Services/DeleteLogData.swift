import Foundation

func ExecuteDeleteLogData() async {
    do {
        try await DeleteLogData()
        print("log_dataを削除しました")
    } catch {
        // エラーが発生した場合の処理
        print("Failed to update user details:", error)
    }
}

func DeleteLogData() async throws {
    try await supabaseClient
        .from("users")
        .update([
            "log_data": ""
        ])
        .eq("user_email", value: userEmail)
        .execute()
}
