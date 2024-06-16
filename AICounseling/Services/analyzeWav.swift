import Foundation

func analyzeWav(apiKey: String, wavFilePath: String) {
    let url = URL(string: "https://api.webempath.net/v2/analyzeWav")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    
    // Add the API key as a parameter
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"apikey\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(apiKey)\r\n".data(using: .utf8)!)
    
    // Add the WAV file
    let fileUrl = URL(fileURLWithPath: wavFilePath)
    let filename = fileUrl.lastPathComponent
    let mimetype = "audio/wav"
    let fileData = try! Data(contentsOf: fileUrl)
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"wav\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)
    
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data")
            return
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print(jsonResponse)
            Task {
                await ExecuteUpdateEmpathResponse(jsonDict: jsonResponse)
            }
        } else {
            let responseString = String(data: data, encoding: .utf8)
            print("Response: \(responseString ?? "Invalid response")")
        }
    }
    
    task.resume()
}
