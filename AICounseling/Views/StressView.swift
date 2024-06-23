import SwiftUI

struct StressView: View {
    @State private var empathResponse: EmpathResponse?
    @State private var pyFeatResponse: PyFeatResponse?
    
    var body: some View {
        TabView {
            DepressionView()
            .tabItem {
                Label("ストレス状態", systemImage: "heart.circle.fill")
            }
            EmpathGraphView(emotions: self.empathResponse.map { EmpathEmotions(for: $0) } ?? DefaultEmotions())
            .tabItem {
                Label("音声認識", systemImage: "waveform")
            }
            EmotionView(emotions: self.pyFeatResponse.map { PyFeatEmotions(for: $0) } ?? DefaultPyFeatEmotions())
            .tabItem {
                Label("表情認識", systemImage: "face.smiling")
            }
        }
        .onAppear {
            Task {
                do {
                    self.empathResponse = try await SelectEmpathResult()
                    self.pyFeatResponse = try await SelectPyFeatResult()
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
