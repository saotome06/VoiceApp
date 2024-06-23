import Foundation

struct EmotionDataTransformer {
    static func transformData(inputData: [String: [String: Double]]) -> [String: Double] {
        var outputData = [String: Double]()
        
        for (key, valueDict) in inputData {
            if let value = valueDict["0"] {
                outputData[key] = value
            }
        }
        
        return outputData
    }
}

// JSONデータを変換するためのメソッド
func convertJsonToDictionary(jsonString: String) -> [String: [String: Double]]? {
    guard let data = jsonString.data(using: .utf8) else { return nil }
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = jsonObject as? [String: [String: Double]] {
            return dictionary
        }
    } catch {
        print("JSON parsing error: \(error.localizedDescription)")
    }
    return nil
}
