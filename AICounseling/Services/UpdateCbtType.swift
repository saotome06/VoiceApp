import Foundation

func ExecuteUpdateCbtType(type: [String]) async {
    do {
        var currentTypes = try await selectCbtType()
        currentTypes.append(contentsOf: type)
//        currentTypes = Array(Set(currentTypes))  // Remove duplicates
        try await UpdateCbtType(type: currentTypes)
        print("Cbtが更新されました")
    } catch {
        // エラーが発生した場合の処理
        print("Failed to update user details:", error)
    }
}

func UpdateCbtType(type: [String]) async throws {
    try await supabaseClient
        .from("users")
        .update([
            "cbt_type": type
        ])
        .eq("user_email", value: userEmail)
        .execute()
}

func selectCbtType() async throws -> [String] {
    let currentCbtType: [CurrentCbt] = try await supabaseClient
        .from("users")
        .select("cbt_type")
        .eq("user_email", value: userEmail)
        .execute()
        .value
    
    guard let result = currentCbtType.first else {
        return []
    }
    
    return result.cbt_type
}

struct CurrentCbt: Decodable {
    let cbt_type: [String]
}
