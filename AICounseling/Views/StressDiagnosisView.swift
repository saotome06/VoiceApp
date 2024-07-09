import SwiftUI

struct StressDiagnosisView: View {
    var body: some View {
        TabView {
            DepressionJudgmentView()
            .tabItem {
                Label("抑うつチェック", systemImage: "cloud.fill")
            }
            PyFeatView()
            .tabItem {
                Label("表情認識", systemImage: "face.smiling")
            }
            NavigationView {
                VStack {
                    MoveView(iconName: "mic.fill", title: "音声カウンセリング", description: "カウンセラーと音声通話で相談", destination: CounselorListView(counselors: sampleCounselors))
                    Text("音声通話を行うと声によるストレス診断が行われます")
                        .padding()
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                .padding()
                .navigationBarTitle("音声認識", displayMode: .inline)
            }
            .tabItem {
                Label("音声認識", systemImage: "mic.fill")
            }
        }
    }
}

struct StressDiagnosisView_Previews: PreviewProvider {
    static var previews: some View {
        StressDiagnosisView()
    }
}
