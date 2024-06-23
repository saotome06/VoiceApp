import Combine

struct ResultPyFeat: Decodable {
    let pyfeat_response: PyFeatResponse
}

func SelectPyFeatResult() async throws -> PyFeatResponse? {
    let resultStatus: [ResultPyFeat] = try await supabaseClient
        .from("users")
        .select("pyfeat_response")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    if let firstStatus = resultStatus.first {
        return firstStatus.pyfeat_response
    } else {
        return nil
    }
}
