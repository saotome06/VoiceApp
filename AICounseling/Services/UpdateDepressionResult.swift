func ExecuteUpdateDepressionResult(result: String) async throws {
    try await UpdateDepressionResult(result: result)
}

func UpdateDepressionResult(result: String) async throws {
    try await supabaseClient
        .from("users")
        .update([
            "depression_result": result
        ])
        .eq("user_email", value: userEmail)
        .execute()
}
