import SwiftUI

struct StressView: View {
//    @State private var empathResponse: TestEmpathResponse?
    @State private var pyFeatResponse: PyFeatResponse?
    @State private var empathLogResponse: [EmpathData] = []
    var body: some View {
        TabView {
            DepressionView()
            .tabItem {
                Label("抑うつ診断", systemImage: "cloud.fill")
            }
            EmpathProgressView(emotionData: empathLogResponse) // EmpathProgressViewを追加
            .tabItem {
                Label("音声認識", systemImage: "waveform") // タブのラベルとアイコンを設定
            }
//            無料版EmpathAPI
//            EmpathGraphView(emotions: self.empathResponse.map { TestEmpathEmotions(for: $0) } ?? DefaultTestEmotions())
//            .tabItem {
//                Label("音声認識", systemImage: "waveform")
//            }
            EmotionView(emotions: self.pyFeatResponse.map { PyFeatEmotions(for: $0) } ?? DefaultPyFeatEmotions())
            .tabItem {
                Label("表情認識", systemImage: "face.smiling")
            }
            TotalStressLevelView(empathEmotionData: empathLogResponse, pyFeatEmotionData: self.pyFeatResponse.map { PyFeatEmotions(for: $0) } ?? DefaultPyFeatEmotions())
            .tabItem {
                Label("ストレス状態", systemImage: "heart.circle.fill")
            }
        }
        .onAppear {
            Task {
                do {
                    async let empathLogResponse = selectEmpathLogResult()
                    async let pyFeatResponse = SelectPyFeatResult()
                    
                    self.empathLogResponse = try await empathLogResponse
                    self.pyFeatResponse = try await pyFeatResponse
                } catch {
                    print("Error fetching Empath result: \(error)")
                }
            }
        }
    }
}

struct StressView_Previews: PreviewProvider {
    static var previews: some View {
        StressView()
    }
}
