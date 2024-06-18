import Combine

struct ResultDepression: Decodable {
    let depression_result: String
}

func SelectDepressionResult() async throws -> String? {
    let resultStatus: [ResultDepression] = try await supabaseClient
        .from("users")
        .select("depression_result")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    if let firstStatus = resultStatus.first {
        return firstStatus.depression_result
    } else {
        return nil
    }
}
