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
                    incrementActionCount(action: "camera_launched")
                }) {
                    Text("カメラを起動")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if selectedImage != nil {
                    Button(action: {
                        incrementActionCount(action: "upload_button_pressed")
                        uploadImage()
                    }) {
                        Text("分析する")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Text("※分析に使用する画像は保存されず直ちに削除されます")
                    .padding()
                    .foregroundColor(.gray)
                
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
        ※分析結果はストレス状態の確認ページから確認できますのでこのページにとどまる必要はありません。
        """
        
        ImageUploadService.upload(imageData: imageData) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.emotionResponse = response
                    self.navigateToEmotionResponse = true
                    self.uploadStatus = "分析が完了しました。ストレス確認のページから結果をご確認ください。"
                    incrementActionCount(action: "analysis_completed")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("アップロードエラー: \(error.localizedDescription)")
                    self.uploadStatus = "アップロードに失敗しました。"
                    incrementActionCount(action: "analysis_missed")
                }
            }
        }
        

    }
    func incrementActionCount(action: String) {
        Task<Void, Never> {
            do {
                let userEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""
                
                let response: [ActionCounts] = try await supabaseClient
                    .from("action_num")
                    .select("user_email, pyfeat_count")
                    .eq("user_email", value: userEmail)
                    .execute()
                    .value
                
                var currentCounts = response.first?.pyfeat_count ?? [:]
                currentCounts[action] = (currentCounts[action] ?? 0) + 1
                let updatedActionCounts = ActionCounts(user_email: userEmail, pyfeat_count: currentCounts)

                try await supabaseClient
                    .from("action_num")
                    .upsert(updatedActionCounts, onConflict: "user_email")
                    .execute()
                
                print("\(action) count incremented")
            } catch {
                print("Error incrementing \(action) count: \(error)")
            }
        }
    }
}
struct ActionCounts: Codable {
    var user_email: String
    var pyfeat_count: [String: Int]
}

struct PyFeatView_Previews: PreviewProvider {
    static var previews: some View {
        PyFeatView()
    }
}
