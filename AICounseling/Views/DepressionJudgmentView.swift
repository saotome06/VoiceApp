import SwiftUI

struct DepressionJudgmentView: View {
    @State private var answers: [Int?] = Array(repeating: nil, count: 9)
    let questions = [
        "気がはりつめている",
        "不安だ",
        "落ち着かない",
        "ゆううつだ",
        "何をするも面倒だ",
        "物事に集中できない",
        "気分が晴れない",
        "仕事が手につかない",
        "悲しいと感じる"
    ]
    
    let options = ["ほとんどなかった", "ときどきあった", "しばしばあった", "ほとんどいつもあった"]
    
    @State private var submissionMessage: SubmissionMessage?
    @State private var isNavigationActive = false
    @State private var showResultButton = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<questions.count, id: \.self) { index in
                            QuestionCard(
                                question: questions[index],
                                questionNumber: index + 1,
                                selectedOption: $answers[index],
                                options: options
                            )
                        }
                        
                        SubmitButton(action: submitAnswers, isDisabled: !allQuestionsAnswered)
                            .padding(.top, 20)
                        
                        if let submissionMessage = submissionMessage {
                            Text(submissionMessage.text)
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        }
                        
                        if showResultButton {  // 条件を変更
                            NavigationLink(destination: DepressionView()) {
                                Text("診断結果を見る")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(leading: EmptyView())
            .navigationBarBackButtonHidden(true) // Backボタンを隠す
        }
    }
    
    private func submitAnswers() {
        // 高ストレス、低ストレス、ストレスなしを判定
        let oftenIndex = options.firstIndex(of: "しばしばあった")!
        let alwaysIndex = options.firstIndex(of: "ほとんどいつもあった")!
        
        var highStressCount = 0
        for answer in answers.compactMap({ $0 }) {
            if answer == oftenIndex || answer == alwaysIndex {
                highStressCount += 1
            }
        }
        
        var stressLevel: String
        if highStressCount >= 7 {
            stressLevel = "High"
        } else if highStressCount >= 1 {
            stressLevel = "Medium"
        } else {
            stressLevel = "Low"
        }
        
        updateDepressionResult(result: stressLevel)
        self.submissionMessage = SubmissionMessage(text: "回答を送信しました")
        self.showResultButton = true  // 診断結果を見るボタンを表示
        let capturedHighStressCount = highStressCount
        Task {
            do {
                try await updateDepressionNum()
                try await updateHighStressCount(highStressCount:capturedHighStressCount)
            } catch {
                print("Error updating depression number: \(error)")
            }
        }
    }
    
    var allQuestionsAnswered: Bool {
        !answers.contains(nil)
    }
}

struct QuestionCard: View {
    let question: String
    let questionNumber: Int
    @Binding var selectedOption: Int?
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("質問 \(questionNumber)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(question)
                .font(.title3)
                .fontWeight(.medium)
            
            CustomSegmentedPicker(selectedOption: $selectedOption, options: options)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CustomSegmentedPicker: View {
    @Binding var selectedOption: Int?
    let options: [String]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<options.count, id: \.self) { index in
                Button(action: {
                    selectedOption = index
                }) {
                    Text(options[index])
                        .font(.system(size: 14))
                        .foregroundColor(selectedOption == index ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOption == index ? Color.blue : Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct SubmitButton: View {
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text("提出")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? Color.gray : Color.blue)
                .cornerRadius(10)
        }
        .disabled(isDisabled)
    }
}

private func updateDepressionResult(result: String) {
    Task {
        do {
            try await ExecuteUpdateDepressionResult(result: result)
            print("ストレス度が更新されました")
        } catch {
            print("Failed to update user details:", error)
        }
    }
}


private func updateDepressionNum() async throws {
    struct DepressionNum: Decodable {
        var depression_count: Int
    }


    let response:[DepressionNum] = try await supabaseClient
        .from("action_num")
        .select("depression_count")
        .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
        .execute()
        .value

    // 現在の値を確認
    guard let currentValue = response.first else {
        print("No matching record found")
        return
    }

    // 更新する値を決定
    let newValue = currentValue.depression_count + 1
    
    // 値を更新する
    try await supabaseClient
        .from("action_num")
        .update(["depression_count": newValue])
        .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
        .execute()
}

private func updateHighStressCount(highStressCount: Int) async throws {
    struct HighStressNum: Decodable {
        var high_stress_count: Int
    }

    // 値を更新する
    try await supabaseClient
        .from("users")
        .update(["high_stress_count": highStressCount])
        .eq("user_email", value: UserDefaults.standard.string(forKey: "user_email") ?? "")
        .execute()
}

struct SubmissionMessage {
    let text: String
}

struct DepressionJudgmentView_Previews: PreviewProvider {
    static var previews: some View {
        DepressionJudgmentView()
    }
}
