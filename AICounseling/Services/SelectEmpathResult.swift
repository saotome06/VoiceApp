import Combine

struct ResultEmpath: Decodable {
    let empath_response: TestEmpathResponse
}

func SelectEmpathResult() async throws -> TestEmpathResponse? {
    let resultStatus: [ResultEmpath] = try await supabaseClient
        .from("users")
        .select("empath_response")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    if let firstStatus = resultStatus.first {
        return firstStatus.empath_response
    } else {
        return nil
    }
}
