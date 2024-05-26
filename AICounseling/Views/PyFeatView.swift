import SwiftUI

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
        guard let image = selectedImage else {
            print("画像の読み込みに失敗しました。")
            return
        }
        
        let resizedImage = ImageResizer.resizeImage(image: image, targetSize: CGSize(width: 800, height: 800))
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 1.0) else {
            print("JPEGデータへの変換に失敗しました。")
            return
        }
        
        ImageUploadService.upload(imageData: imageData) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.emotionResponse = response
                }
            case .failure(let error):
                print("アップロードエラー: \(error.localizedDescription)")
            }
        }
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
