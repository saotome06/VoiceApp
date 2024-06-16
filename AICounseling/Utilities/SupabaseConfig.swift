import Foundation
import Supabase

struct SupabaseConfig {
    static var supabaseKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("SUPABASE_KEY not found in Info.plist")
        }
        return key
    }
    
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString) else {
          fatalError("SUPABASE_URL not found in Info.plist or is not a valid URL")
        }
        return url
    }
}

func initializeSupabaseClient() -> SupabaseClient {
    let key = SupabaseConfig.supabaseKey
    let url = SupabaseConfig.supabaseURL
    return SupabaseClient(supabaseURL: url, supabaseKey: key)
}

public let supabaseClient = initializeSupabaseClient()
public let userEmail: String = UserDefaults.standard.string(forKey: "user_email") ?? ""
