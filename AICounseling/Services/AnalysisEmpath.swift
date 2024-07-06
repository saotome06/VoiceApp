import Foundation
import AVFoundation

func uploadFileToChunkEndpoint(filePath: String) {
    guard let audioData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Failed to read file at \(filePath)")
        return
    }
    
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = URLRequest(url: URL(string: "https://empath-api-zth7maukia-an.a.run.app/run-script")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var httpBody = Data()
    httpBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    httpBody.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
    httpBody.append("\(userEmail)\r\n".data(using: .utf8)!)
    
    httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
    httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filePath)\"\r\n".data(using: .utf8)!)
    httpBody.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
    httpBody.append(audioData)
    httpBody.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = httpBody
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code: \(httpResponse.statusCode)")
        }
        
//        if let data = data, let responseString = String(data: data, encoding: .utf8) {
//            print("Response: \(responseString)")
//        }
    }
    task.resume()
}
