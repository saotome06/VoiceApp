import SwiftUI
import UIKit

// UIImagePickerControllerを使うためのヘルパー
struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct PyFeatView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var emotionResponse: EmotionResponse?
    
    var body: some View {
        VStack {
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("カメラを起動")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if selectedImage != nil {
                Button(action: {
                    uploadImage()
                }) {
                    Text("画像をアップロード")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if let emotionResponse = emotionResponse {
                ForEach(0..<emotionResponse.anger.count, id: \.self) { index in
                    EmotionView(emotions: parseEmotions(from: emotionResponse, index: index))
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    func uploadImage() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("画像の読み込みまたはJPEGデータへの変換に失敗しました。")
            return
        }
        
        let url = URL(string: "https://my-first-run-zth7maukia-an.a.run.app/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
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
                print("エラー: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("サーバーエラー")
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("レスポンス: \(responseString)")
                do {
                    let decodedResponse = try JSONDecoder().decode(EmotionResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.emotionResponse = decodedResponse
                    }
                } catch {
                    print("レスポンスのパースに失敗しました: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func parseEmotions(from response: EmotionResponse, index: Int) -> [Emotion] {
        return [
            Emotion(type: "Anger", value: response.anger["\(index)"] ?? 0),
            Emotion(type: "Disgust", value: response.disgust["\(index)"] ?? 0),
            Emotion(type: "Fear", value: response.fear["\(index)"] ?? 0),
            Emotion(type: "Happiness", value: response.happiness["\(index)"] ?? 0),
            Emotion(type: "Sadness", value: response.sadness["\(index)"] ?? 0),
            Emotion(type: "Surprise", value: response.surprise["\(index)"] ?? 0),
            Emotion(type: "Neutral", value: response.neutral["\(index)"] ?? 0)
        ]
    }
}

struct PyFeatView_Previews: PreviewProvider {
    static var previews: some View {
        PyFeatView()
    }
}
