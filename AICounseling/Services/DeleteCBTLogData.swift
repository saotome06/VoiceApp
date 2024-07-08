import Foundation

func ExecuteDeleteCBTLogData() async {
    do {
        try await DeleteCBTLogData()
        print("know_log_dataを削除しました")
    } catch {
        // エラーが発生した場合の処理
        print("Failed to update user details:", error)
    }
}

func DeleteCBTLogData() async throws {
    try await supabaseClient
        .from("users")
        .update([
            "know_log_data": ""
        ])
        .eq("user_email", value: userEmail)
        .execute()
}
