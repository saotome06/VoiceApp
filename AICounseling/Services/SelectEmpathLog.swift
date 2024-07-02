import Combine

func selectEmpathLogResult() async throws -> [EmpathData] {
    let resultStatus: [ResultEmpathProgress] = try await supabaseClient
        .from("users")
        .select("empath_result_log")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    guard let result = resultStatus.first else {
        return []
    }
    
    return result.empath_result_log
}
