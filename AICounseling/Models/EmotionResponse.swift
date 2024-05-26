import Foundation

struct EmotionResponse: Codable {
    let anger: [String: Double]
    let disgust: [String: Double]
    let fear: [String: Double]
    let happiness: [String: Double]
    let sadness: [String: Double]
    let surprise: [String: Double]
    let neutral: [String: Double]
}
