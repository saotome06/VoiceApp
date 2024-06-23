import SwiftUI

struct PyFeatView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var emotionResponse: EmotionResponse?
    @State private var navigateToEmotionResponse = false
    @State private var uploadStatus: String?
    
    var body: some View {
        NavigationView {
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
                
                if let uploadStatus = uploadStatus {
                    Text(uploadStatus)
                        .padding()
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
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
        
        self.uploadStatus = """
        表情分析中...
        5~10分ほど時間がかかる場合があります。
        """
        
        ImageUploadService.upload(imageData: imageData) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.emotionResponse = response
                    self.navigateToEmotionResponse = true
                    self.uploadStatus = "分析が完了しました。ストレス確認のページから結果をご確認ください。"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("アップロードエラー: \(error.localizedDescription)")
                    self.uploadStatus = "アップロードに失敗しました。"
                }
            }
        }
    }
}

struct PyFeatView_Previews: PreviewProvider {
    static var previews: some View {
        PyFeatView()
    }
}
