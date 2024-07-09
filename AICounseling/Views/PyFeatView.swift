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
                Spacer()
                
                Button(action: {
                    isImagePickerPresented = true
                    incrementActionCount(action: "camera_launched")
                }) {
                    HStack {
                        Image(systemName: "face.smiling")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        VStack(alignment: .leading) {
                            Text("カメラを起動する")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("表情からストレス度を診断する")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.trailing, 20)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                if selectedImage != nil {
                    Button(action: {
                        incrementActionCount(action: "upload_button_pressed")
                        uploadImage()
                    }) {
                        Text("分析する")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                Text("※分析に使用する画像は保存されず直ちに削除されます")
                    .padding()
                    .foregroundColor(.gray)
                    .font(.footnote)
                
                if let uploadStatus = uploadStatus {
                    Text(uploadStatus)
                        .padding()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationBarTitle("表情認識", displayMode: .inline)
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
