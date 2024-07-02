struct TestEmpathResponse: Codable {
    let anger: Double
    let calm: Double
    let joy: Double
    let sorrow: Double
    let vigor: Double
    
    func toDictionary() -> [String: Double] {
        return [
            "anger": anger,
            "calm": calm,
            "joy": joy,
            "sorrow": sorrow,
            "vigor": vigor
        ]
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> TestEmpathResponse? {
        guard let anger = dictionary["anger"] as? Double,
              let calm = dictionary["calm"] as? Double,
              let joy = dictionary["joy"] as? Double,
              let sorrow = dictionary["sorrow"] as? Double,
              let vigor = dictionary["vigor"] as? Double else {
            return nil
        }
        return TestEmpathResponse(anger: anger, calm: calm, joy: joy, sorrow: sorrow, vigor: vigor)
    }
}

func TestEmpathEmotions(for empathResponse: TestEmpathResponse) -> [TestEmpathEmotion] {
    return [
        TestEmpathEmotion(type: "anger", value: empathResponse.anger),
        TestEmpathEmotion(type: "calm", value: empathResponse.calm),
        TestEmpathEmotion(type: "joy", value: empathResponse.joy),
        TestEmpathEmotion(type: "sorrow", value: empathResponse.sorrow),
        TestEmpathEmotion(type: "vigor", value: empathResponse.vigor)
    ]
}

func DefaultTestEmotions() -> [TestEmpathEmotion] {
    return [
        TestEmpathEmotion(type: "anger", value: 0),
        TestEmpathEmotion(type: "calm", value: 0),
        TestEmpathEmotion(type: "joy", value: 0),
        TestEmpathEmotion(type: "sorrow", value: 0),
        TestEmpathEmotion(type: "vigor", value: 0)
    ]
}

struct StausTestEmpath: Decodable {
    let empath_status: Bool
}
