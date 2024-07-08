import SwiftUI

func calculateAverage(emotionData: [EmpathData]) -> EmpathData {
    guard !emotionData.isEmpty else {
        return EmpathData(
            joy: 0,
            calm: 0,
            anger: 0,
            vigor: 0,
            sorrow: 0,
            timestamp: "", // 平均データにはタイムスタンプが不要
            primalEmotion: "Average",
            primalEmotionValue: 0
        )
    }
    
    let count = emotionData.count
    let totalJoy = emotionData.reduce(0) { $0 + $1.joy }
    let totalCalm = emotionData.reduce(0) { $0 + $1.calm }
    let totalAnger = emotionData.reduce(0) { $0 + $1.anger }
    let totalVigor = emotionData.reduce(0) { $0 + $1.vigor }
    let totalSorrow = emotionData.reduce(0) { $0 + $1.sorrow }
    
    return EmpathData(
        joy: totalJoy / count,
        calm: totalCalm / count,
        anger: totalAnger / count,
        vigor: totalVigor / count,
        sorrow: totalSorrow / count,
        timestamp: "", // 平均データにはタイムスタンプが不要
        primalEmotion: "Average",
        primalEmotionValue: 0
    )
}

func calculateDifference(from data: EmpathData, to average: EmpathData) -> EmpathData {
    return EmpathData(
        joy: data.joy - average.joy,
        calm: data.calm - average.calm,
        anger: data.anger - average.anger,
        vigor: data.vigor - average.vigor,
        sorrow: data.sorrow - average.sorrow,
        timestamp: data.timestamp,
        primalEmotion: data.primalEmotion,
        primalEmotionValue: data.primalEmotionValue
    )
}

struct EmpathProgressView: View {
    let emotionData: [EmpathData]
    @State private var voiceStressLevel: StressLevel?
    @State private var totalNegativeEmotionDiff: Double = 0
    
    var body: some View {
        ScrollView {
            VStack {
                Text("音声ストレス診断結果")
                    .font(.largeTitle)
                    .padding()
                
                let average = calculateAverage(emotionData: emotionData)
//                let emotionDiff = calculateDifference(from: emotionData.last ?? EmpathData(joy: 1, calm: 1, anger: 1, vigor: -7, sorrow: 10, timestamp: "", primalEmotion: "Sorrow", primalEmotionValue: 10), to: average)
                
                Text("元気度")
                    .font(.title2)
                    .padding(.top)
                
                EnergyPieChartView(energy: Double(emotionData.last?.vigor ?? 0) + 20)
                    .frame(width: 200, height: 200)
                    .padding(30)
                
                if let stressLevel = voiceStressLevel {
                    Text(stressLevel.description)
                        .font(.title)
                        .padding()
                        .foregroundColor(stressLevel.color)
                }
                
                Spacer()
                
                // 平均値の表示
                VStack(alignment: .center) {
                    Text("あなたの平常値")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                    EmpathProgressBarChartView(
                        data: [CGFloat(average.joy), CGFloat(average.calm), CGFloat(average.anger), CGFloat(average.vigor), CGFloat(average.sorrow)],
                        labels: ["喜び", "平静", "怒り", "活力", "悲しみ"]
                    )
                }
                .padding()
                .padding(.bottom, 8)
                
                // 各データと平均値との差分の表示
                Text("平常値との変化量")
                    .font(.title2)
                ForEach(emotionData.reversed()) { data in
                    let difference = calculateDifference(from: data, to: average)
                    VStack(alignment: .center) {
                        Text("日付: \(data.timestamp.components(separatedBy: "T")[0])") // タイムスタンプから日付部分を取得
                            .font(.headline)
                        EmpathProgressBarChartView(
                            data: [CGFloat(difference.joy), CGFloat(difference.calm), CGFloat(difference.anger), CGFloat(difference.vigor), CGFloat(difference.sorrow)],
                            labels: ["喜び", "平静", "怒り", "活力", "悲しみ"]
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding(.bottom, 8)
                }
                // カウンセリングページへの動線
                NavigationLink(destination: CounselingSelectionView()) {
                    Text("音声ストレス診断を行う")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.top, 20)
                }
            }
            .padding()
            .onAppear {
                let average = calculateAverage(emotionData: emotionData)
                let emotionDiff = calculateDifference(from: emotionData.last ?? EmpathData(joy: 1, calm: 1, anger: 1, vigor: -7, sorrow: 10, timestamp: "", primalEmotion: "Sorrow", primalEmotionValue: 10), to: average)
                totalNegativeEmotionDiff = Double(emotionDiff.vigor + emotionDiff.anger + emotionDiff.calm)
                
                calculateStressLevel()
            }
        }
    }
    
    func calculateStressLevel() {
        var stressResult = "Low"
        if totalNegativeEmotionDiff < -10 {
            stressResult = "High"
        } else if totalNegativeEmotionDiff < 0 {
            stressResult = "Medium"
        }
        if emotionData.isEmpty {
            stressResult = "None"
        }
        self.voiceStressLevel = StressLevel(rawValue: stressResult)
    }
}

struct EmpathProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EmpathProgressView(emotionData: [
            EmpathData(joy: 1, calm: 1, anger: 1, vigor: -7, sorrow: 10, timestamp: "2024-07-01T15:51:23.171100", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: 2, anger: 1, vigor: -20, sorrow: 10, timestamp: "2024-07-01T15:51:37.037020", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: 2, anger: 1, vigor: -20, sorrow: 10, timestamp: "2024-07-01T15:52:03.007577", primalEmotion: "Sorrow", primalEmotionValue: 10),
            EmpathData(joy: 2, calm: -20, anger: 1, vigor: -10, sorrow: -10, timestamp: "2024-07-01T15:52:15.145088", primalEmotion: "Sorrow", primalEmotionValue: 10)
        ])
    }
}
