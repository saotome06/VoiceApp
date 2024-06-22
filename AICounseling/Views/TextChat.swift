import SwiftUI
import Combine
import Supabase

struct TextChat: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var messagesCountPublisher: AnyPublisher<Int, Never> = Just(0).eraseToAnyPublisher()
    private let systemContent: String
    
    init(systemContent: String) {  // 初期化メソッドを追加
        self.systemContent = systemContent
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
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
        if ChatGPTService.shared(systemContent: self.systemContent).getConversationHistory() == [] && self.systemContent.count <= 800 {
            guard let email = UserDefaults.standard.string(forKey: "user_email") else { return }
            Task {
                do {
                    let response = try await supabaseClient.from("users")
                        .select("log_data")
                        .eq("user_email", value: email)
                        .execute()
                    
                    let data = response.data
                    let logData = String(decoding: data, as: UTF8.self)
                    let jsonLogData = extractLogData(from: logData)
                    ChatGPTService.shared(systemContent: self.systemContent).setConversationHistory(conversationHistory: jsonLogData)
//                    print(jsonLogData)
                    for (i, message) in jsonLogData.enumerated() {
                        if i % 2 == 0 {
                            messages.append(Message(text: message, isReceived: false))
                        } else {
                            messages.append(Message(text: message, isReceived: true))
                        }
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
    
    func extractLogData(from jsonString: String) -> [String] {
        // まず最初のJSONをパースして "log_data" を取得
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert jsonString to Data")
            return []
        }

        do {
            // 最初のJSONオブジェクトのパース
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]],
               let logDataString = jsonArray.first?["log_data"] {
                // "log_data" の内容を再度JSONとしてパースして [String] を取得
                if let logData = logDataString.data(using: .utf8) {
                    return try JSONSerialization.jsonObject(with: logData, options: []) as? [String] ?? []
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return []
        }

        return []
    }
    
    
    private func sendMessage() {
        if !inputText.isEmpty {
            messages.append(Message(text: inputText, isReceived: false))
            
            ChatGPTService.shared(systemContent: self.systemContent).fetchResponse(inputText) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        messages.append(Message(text: response, isReceived: true))
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        messages.append(Message(text: "エラーが発生しました。", isReceived: true))
                    }
                    inputText = ""
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
