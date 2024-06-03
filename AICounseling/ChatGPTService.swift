import Foundation

class ChatGPTService {
    static let shared = ChatGPTService() // (0)
    private var apiKey: String { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return gptApiKey
        } else {
            return "not found"
        }
    }
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private var conversationHistory: [String] = [] // （3）
    private let systemContent =
    """
        このチャットボットは心の悩みに関するカウンセリングを行います。
    """.trimmingCharacters(in: .whitespacesAndNewlines)
    
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
        
        let parameters: [String: Any] = [ // ここから（12）
            "model": "ft:gpt-3.5-turbo-1106:personal:counseling-1:9UEt36bK",
            "messages": messages
        ] // ここまで（12）
        print(messages)
        
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
                    // アシスタントのメッセージを履歴に追加して、コールバックを呼び出す
                    self.conversationHistory.append(content) // ここから（17）
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
}
