import Foundation

struct ImageUploadService {
    static func upload(imageData: Data, completion: @escaping (Result<EmotionResponse, Error>) -> Void) {
        let url = URL(string: "https://my-first-run-zth7maukia-an.a.run.app/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(Data(boundaryPrefix.utf8))
        body.append(Data("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!))
        body.append(Data("\(userEmail)\r\n".data(using: .utf8)!))
        
        body.append(Data(boundaryPrefix.utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"captured_image.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        request.httpBody = body
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300
        
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let error = NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "サーバーエラー: ステータスコード \(statusCode)"])
                print("サーバーエラー")
                completion(.failure(error))
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("レスポンス: \(responseString)")
                if let inputData = convertJsonToDictionary(jsonString: responseString) {
                    let outputData = EmotionDataTransformer.transformData(inputData: inputData)
                    Task {
                        await ExecuteUpdatePyFeatResponse(jsonDict: outputData)
                    }
                    print(outputData)
                } else {
                    print("Failed to convert JSON string to dictionary")
                }
                do {
                    let decodedResponse = try JSONDecoder().decode(EmotionResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
