struct EmpathResponse: Codable {
    let joy: Double
    let error: Double
    let anger: Double
    let sorrow: Double
    let calm: Double
    let energy: Double
    
    func toDictionary() -> [String: Double] {
        return [
            "joy": joy,
            "error": error,
            "anger": anger,
            "sorrow": sorrow,
            "calm": calm,
            "energy": energy
        ]
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> EmpathResponse? {
        guard let joy = dictionary["joy"] as? Double,
              let error = dictionary["error"] as? Double,
              let anger = dictionary["anger"] as? Double,
              let sorrow = dictionary["sorrow"] as? Double,
              let calm = dictionary["calm"] as? Double,
              let energy = dictionary["energy"] as? Double else {
            return nil
        }
        return EmpathResponse(joy: joy, error: error, anger: anger, sorrow: sorrow, calm: calm, energy: energy)
    }
}

struct StausEmpath: Decodable {
    let empath_status: Bool
}
