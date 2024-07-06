import SwiftUI
import Combine
import Supabase

struct TextChat: View {
    private var enctyptKey: String { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_KEY") as? String {
            return gptApiKey
        } else {
            return "not found"
        }
    }

    private var enctyptIV: String { // ここから（2）
        if let gptApiKey = Bundle.main.object(forInfoDictionaryKey: "ENCRYPT_IV") as? String {
            return gptApiKey
        } else {
            return "not found"
        }
    }

    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var messagesCountPublisher: AnyPublisher<Int, Never> = Just(0).eraseToAnyPublisher()
    @State private var isSending = false
    private let systemContent: String
    
    init(systemContent: String) {  // 初期化メソッドを追加
        self.systemContent = systemContent
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        MessageView(message: Message(text: "何かお困りごとはありますか？", isReceived: true))
                        LazyVStack {
                            ForEach(messages, id: \.self) { message in
                                MessageView(message: message)
                            }
                        }
                        .onReceive(messagesCountPublisher) { _ in
                            scrollToBottom(proxy: proxy)
                        }
//                        .onChange(of: messages.count) {
//                            scrollToBottom(proxy: proxy)
//                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    TextEditor(text: $inputText)
                        .padding(5)
                        .frame(height: 50)
                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 3))
                        .padding(.trailing, 10)
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .padding(5)
                            .shadow(color: .gray, radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .cornerRadius(30)
                .onAppear {
                    fetchLogData()
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: EmptyView())
    }
    
    private func fetchLogData(){
        // conversationHistoryが何もない = アプリが落とされたか、一度も会話をしていないか
        // 以下は、アプリが落とされた場合にDBから引っ張ってくる処理
        // 将来はUserDefaultにconversationHistoryを突っ込んでやればAPI使用をさらに減らせるかも
        if ChatGPTService.shared(systemContent: self.systemContent).getConversationHistory() == [] && self.systemContent != SystemContent.knowDistortionSystemContent {
            guard let email = UserDefaults.standard.string(forKey: "user_email") else { return }
            Task {
                do {
                    let response = try await supabaseClient.from("users")
                        .select("log_data")
                        .eq("user_email", value: email)
                        .execute()
                    
                    let data = response.data
                    let logData = String(decoding: data, as: UTF8.self)
                    print(logData)
                    if let jsonData = logData.data(using: .utf8) {
                        do {
                            // JSONデータを配列にパースする
                            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]], let logDataString = jsonArray.first?["log_data"] {
                                
                                // AES復号化を行う
                                let aes = EncryptionAES()

                                // AESで復号化
                                let decryptedString = aes.decrypt(key: enctyptKey, iv: enctyptIV, base64: logDataString)
                                
                                if !decryptedString.isEmpty {
                                    // 復号化した文字列をJSONデコードして配列に変換する
                                    if let data = decryptedString.data(using: .utf8),
                                       let array = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
    
                                        ChatGPTService.shared(systemContent: self.systemContent).setConversationHistory(conversationHistory: array)
                                        for (i, message) in array.enumerated() {
                                            if i % 2 == 0 {
                                                messages.append(Message(text: message, isReceived: false))
                                            } else {
                                                messages.append(Message(text: message, isReceived: true))
                                            }
                                        }
                                                                                
                                    } else {
                                        print("復号化したデータを配列にパースできませんでした。")
                                    }
                                } else {
                                    print("AES復号化に失敗しました。")
                                }
                                
                            } else {
                                print("JSONデータをパースしてlog_dataを取得できませんでした。")
                            }
                        } catch {
                            print("JSONデータのパースエラー: \(error.localizedDescription)")
                        }
                    } else {
                        print("JSON文字列をデータに変換できませんでした。")
                    }

                } catch {
                    print("Error fetching log data: \(error)")
                }
            }
        } else {
            for (i, message) in ChatGPTService.shared(systemContent: self.systemContent).getConversationHistory().enumerated() { // ここから（10）
                if i % 2 == 0 {
                    messages.append(Message(text: message, isReceived: false))
                } else {
                    messages.append(Message(text: message, isReceived: true))
                }
            }
        }
    }
    
    
    private func sendMessage() {
        if !inputText.isEmpty  && !isSending {
            isSending = true
            let messageText = inputText
            inputText = ""
            
            messages.append(Message(text: messageText, isReceived: false))
            
            ChatGPTService.shared(systemContent: self.systemContent).fetchResponse(messageText) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        messages.append(Message(text: response, isReceived: true))
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        messages.append(Message(text: "エラーが発生しました。", isReceived: true))
                    }
                    isSending = false
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        withAnimation {
            proxy.scrollTo(lastMessage, anchor: .bottom)
        }
    }
}

struct TextChat_Previews: PreviewProvider {
    static var previews: some View {
        TextChat(systemContent: "このチャットボットは心の悩みに関するカウンセリングを行います。20文字以内で返して。")
    }
}
