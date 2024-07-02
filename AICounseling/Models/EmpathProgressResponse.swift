import Foundation
import Combine

// データモデルの定義
struct EmpathData: Identifiable, Decodable {
    var id = UUID()
    var joy: Int
    var calm: Int
    var anger: Int
    var vigor: Int
    var sorrow: Int
    var timestamp: String
    var primalEmotion: String
    var primalEmotionValue: Int
    
    enum CodingKeys: String, CodingKey {
        case joy, calm, anger, vigor, sorrow, timestamp, primalEmotion, primalEmotionValue
    }
}

struct ResultEmpathProgress: Decodable {
    let empath_result_log: [EmpathData]
}
