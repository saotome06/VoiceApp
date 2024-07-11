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
    @State private var isNavigationActive = false // ナビゲーションリンクの表示状態を管理
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Section(header: Text("質問 \(index + 1)")) {
                            Text(questions[index])
                            CustomSegmentedPicker(selectedOption: $answers[index], options: options)
                        }
                    }
                }
                .navigationBarTitle("抑うつ診断", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: submitAnswers) {
                    Text("提出")
                }
                .disabled(!allQuestionsAnswered))
                
                if let submissionMessage = submissionMessage {
                    Text(submissionMessage.text)
                        .padding()
                    
                    NavigationLink(destination: DepressionView()) {
                        Text("診断結果を見る")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                // ナビゲーションリンク
                NavigationLink(
                    destination: DepressionView(),
                    isActive: $isNavigationActive,
                    label: {
                        EmptyView()
                    })
                .hidden()
            }
        }
        var allQuestionsAnswered: Bool {
            // answers配列の全ての要素がnilでないことを確認
            return !answers.contains(nil)
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

struct CustomSegmentedPicker: View {
    @Binding var selectedOption: Int?
    let options: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<options.count, id: \.self) { index in
                Button(action: {
                    selectedOption = index
                }) {
                    Text(options[index])
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(10)
                        .background(selectedOption == index ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedOption == index ? Color.white : Color.black)
                        .cornerRadius(8)
                        .fixedSize(horizontal: false, vertical: true) // テキストが折り返されるようにする
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct SubmissionMessage {
    let text: String
}

struct DepressionJudgmentView_Previews: PreviewProvider {
    static var previews: some View {
        DepressionJudgmentView()
    }
}
