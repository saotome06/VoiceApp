import SwiftUI

struct PyFeatView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isImagePreviewPresented = false
    @State private var emotionResponse: EmotionResponse?
    @State private var navigateToEmotionResponse = false
    @State private var uploadStatus: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        headerView
                        
                        infoCardView
                        
                        if let image = selectedImage {
                            selectedImageView(image: image)
                        }
                        
                        if selectedImage != nil {
                            analyzeButton
                        }
                        
                        cameraButton
                        
                        disclaimerView
                        
                        if let uploadStatus = uploadStatus {
                            statusView(status: uploadStatus)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("表情認識", displayMode: .inline)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $isImagePreviewPresented) {
             if let image = selectedImage {
                 ImagePreviewView(image: image)
             }
         }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "face.smiling")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("表情からストレスを診断")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("あなたの表情を分析し、ストレスレベルを評価します")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var infoCardView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("表情認識の仕組み")
                .foregroundColor(.black)
                .font(.headline)
            
            Text("1. 顔の特徴点を検出")
                .foregroundColor(.black)
            Text("2. 顔の表情を分析")
                .foregroundColor(.black)
            Text("3. ストレスレベルを推定")
                .foregroundColor(.black)
            
            Text("精度の高い結果を得るために、自然な表情で撮影してください。")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private var cameraButton: some View {
        Button(action: {
            isImagePickerPresented = true
            incrementActionCount(action: "camera_launched")
        }) {
            HStack {
                Image(systemName: "camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                if selectedImage != nil {
                    Text("もう一度撮影する")
                        .font(.headline)
                }else{
                    Text("カメラを起動する")
                        .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
        }            
        .disabled(isAnalyzing)
        .opacity(isAnalyzing ? 0.5 : 1.0)
    }
    
    private var analyzeButton: some View {
        Button(action: {
            incrementActionCount(action: "upload_button_pressed")
            uploadImage()
        }) {
            Text("分析する")
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .disabled(isAnalyzing)
        .opacity(isAnalyzing ? 0.5 : 1.0)
    }
    
    private var disclaimerView: some View {
        Text("※分析に使用する画像は保存されず直ちに削除されます")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private func statusView(status: String) -> some View {
        Text(status)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue.opacity(0.8))
            .cornerRadius(10)
            .multilineTextAlignment(.center)
    }
    
    private func selectedImageView(image: UIImage) -> some View {
        VStack {
            Text("分析する写真")
                .font(.headline)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(10)
                .onTapGesture {
                    isImagePreviewPresented = true
                }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    func uploadImage() {
        guard let image = selectedImage else {
            print("画像の読み込みに失敗しました。")
            return
        }
        isAnalyzing = true  // 分析開始
        
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
                    self.isAnalyzing = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("アップロードエラー: \(error.localizedDescription)")
                    self.uploadStatus = "アップロードに失敗しました。"
                    incrementActionCount(action: "analysis_missed")
                    self.isAnalyzing = false
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

struct ImagePreviewView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .navigationBarTitle("写真プレビュー", displayMode: .inline)
                .navigationBarItems(trailing: Button("閉じる") {
                    presentationMode.wrappedValue.dismiss()
                })
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
