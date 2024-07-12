import Combine

struct ResultDepression: Decodable {
    let depression_result: String
    let high_stress_count: Int
}

func SelectDepressionResult() async throws -> (String?, Int?) {
    let resultStatus: [ResultDepression] = try await supabaseClient
        .from("users")
        .select("depression_result, high_stress_count")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    if let firstStatus = resultStatus.first {
        return (firstStatus.depression_result, firstStatus.high_stress_count)
    } else {
        return (nil, nil)
    }
}
