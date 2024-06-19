import SwiftUI
import Combine

struct TextChat: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var messagesCountPublisher: AnyPublisher<Int, Never> = Just(0).eraseToAnyPublisher()
    
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
                        print(messages,"ffsgsgsg")
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
            }
        }
//        .navigationBarBackButtonHidden(true) // Backボタンを隠す
        .navigationBarItems(leading: EmptyView())
    }
    
    private func sendMessage() {
        if !inputText.isEmpty {
            messages.append(Message(text: inputText, isReceived: false))
            
            ChatGPTService.shared.fetchResponse(inputText) { result in
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
        TextChat()
    }
}
