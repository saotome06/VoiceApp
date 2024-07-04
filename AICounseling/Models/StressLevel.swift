import SwiftUI

enum StressLevel: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var emoji: String {
        switch self {
        case .low:
            return "😊" // 笑顔のアイコン
        case .medium:
            return "😟" // 不安そうな顔のアイコン
        case .high:
            return "😞" // ダウンしている顔のアイコン
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return "良好な状態です"
        case .medium:
            return "少しストレスを感じています"
        case .high:
            return "高ストレスな状態です"
        }
    }
    
    var depressionDescription: String {
        switch self {
        case .low:
            return "良好な精神状態です"
        case .medium:
            return "軽度から中等度の抑うつ傾向が見られます"
        case .high:
            return "重度の抑うつ傾向が見られます"
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
