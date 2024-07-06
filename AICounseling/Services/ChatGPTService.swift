import Foundation
import Supabase

private var enctyptKey: String { // ここから（2）
    if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_KEY") as? String {
        return gptApiKey
    } else {
        return "not found"
    }
}

private var enctyptIV: String { // ここから（2）
    if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_IV") as? String {
        return gptApiKey
    } else {
        return "not found"
    }
}

class ChatGPTService {
    private var apiKey: String { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return gptApiKey
        } else {
            return "not found"
        }
    }
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private var conversationHistory: [String] = [] // （3）
    private var systemContent: String
    
    // Singletonインスタンスを保持する変数
    private static var sharedService: ChatGPTService? = nil
    
    // シングルトンインスタンスを取得するメソッド
    static func shared(systemContent: String) -> ChatGPTService {
        if sharedService == nil {
            sharedService = ChatGPTService(systemContent: systemContent)
        }
        return sharedService!
    }
    
    // シングルトンインスタンスをリセットするメソッド
    static func resetSharedInstance(systemContent: String) {
        sharedService = ChatGPTService(systemContent: systemContent)
    }
    
    // プライベートイニシャライザ
    private init(systemContent: String) {
        self.systemContent = systemContent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getConversationHistory() -> [String]{
        return self.conversationHistory
    }
    
    func setConversationHistory(conversationHistory: [String]){
        self.conversationHistory = conversationHistory
    }
    
    func fetchResponse(_ message: String, completion: @escaping (Result<String, Error>) -> Void) { // （5）
        // ユーザーのメッセージを履歴に追加する
        conversationHistory.append(message) // （6）
        // APIリクエストを作成する
        guard let url = URL(string: apiURL) else { // （7）
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // リクエストヘッダーを設定する
        var request = URLRequest(url: url) // ここから（8）
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // ここまで（8）
        
        // 送信データ用のmessagesリストを作成する
        var messages = [["role": "system", "content": systemContent]] // （9）
        
        // 過去のメッセージをもとに、ユーザーとアシスタントのメッセージを交互に追加する
        for (i, message) in conversationHistory.enumerated() { // ここから（10）
            if i % 2 == 0 {
                messages.append(["role": "user", "content": message])
            } else {
                messages.append(["role": "assistant", "content": message])
            }
        } // ここまで（10）
        
        // 最後に現在のユーザーのメッセージを追加する
        messages.append(["role": "user", "content": message]) // （11）
        
        var parameters: [String: Any] = [ // ここから（12）
            "model": "ft:gpt-3.5-turbo-1106:personal:counseling-2:9Zh7f86h",
            "messages": messages
        ] // ここまで（12）
        if self.systemContent == SystemContent.knowDistortionSystemContent {
            parameters["model"] = "gpt-3.5-turbo"
//            parameters["model"] = "gpt-4o"
        }
        print(parameters)
        
        // リクエストボディを設定する
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters) // （13）
        
        // リクエストを送信する
        let task = URLSession.shared.dataTask(with: request) { data, response, error in // （14）
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // レスポンスデータを処理する
            guard let data = data else { // （15）
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            //            print("data: \(String(data: data, encoding: .utf8) ?? "")")
            
            do {
                // レスポンスデータをパースして、アシスタントのメッセージを取得する
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], // ここから（16）
                   let text = jsonResult["choices"] as? [[String: Any]],
                   let firstChoice = text.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String { // ここまで（16）
                    // 認知の歪みを知るの場合はログを記録しないようにする
                    if self.systemContent.count <= 800 {
                        // アシスタントのメッセージを履歴に追加して、コールバックを呼び出す
                        self.conversationHistory.append(content) // ここから（17）
                        self.saveLogToDatabase(conversationHistory: self.conversationHistory)
                    }
                    completion(.success(content)) // ここまで（17）
                } else {
                    let errorMessage = "エラーが発生しました。" // ここから（18）
                    self.conversationHistory.append(errorMessage)
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: ["message": errorMessage]))) // ここまで（18）
                }
            } catch {
                let errorMessage = "エラーが発生しました。" // ここから（19）
                self.conversationHistory.append(errorMessage)
                completion(.failure(NSError(domain: "Error", code: 0, userInfo: ["message": errorMessage]))) // ここまで（19）
            }
        }
        
        task.resume()
    }
    
    func saveLogToDatabase(conversationHistory: [String]) {
        let email = UserDefaults.standard.string(forKey: "user_email") ?? ""
        let aes = EncryptionAES()
        
        Task {
            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(conversationHistory)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    // JSONデータを文字列に変換できない場合のエラーハンドリング
                    return
                }
                let formattedJsonString = try formatJSONString(jsonString)


                let jsonEncrypted = aes.encrypt(key: enctyptKey, iv: enctyptIV, text: formattedJsonString)
                let _ = try await supabaseClient
                    .from("users")
                    .update(["log_data": jsonEncrypted])
                    .eq("user_email", value: email)
                    .execute()
            } catch {
                // エラーハンドリング
                print("Error:", error)
            }
        }
    }
    
    func formatJSONString(_ jsonString: String) throws -> String {
        let jsonData = jsonString.data(using: .utf8)!
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        let formattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        guard let formattedString = String(data: formattedData, encoding: .utf8) else {
            throw NSError(domain: "JSON formatting error", code: 0, userInfo: nil)
        }
//        print(formattedString)
        return formattedString
    }
}

// ISO8601形式の文字列に変換するためのヘルパー
extension Date {
    func iso8601String() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return dateFormatter.string(from: self)
    }
}
