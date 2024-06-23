struct PyFeatResponse: Codable {
    let anger: Double
    let disgust: Double
    let fear: Double
    let happiness: Double
    let sadness: Double
    let surprise: Double
    let neutral: Double
    
    func toDictionary() -> [String: Double] {
        return [
            "anger": anger,
            "disgust": disgust,
            "fear": fear,
            "happiness": happiness,
            "sadness": sadness,
            "surprise": surprise,
            "neutral": neutral
        ]
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> PyFeatResponse? {
        guard let anger = dictionary["anger"] as? Double,
              let disgust = dictionary["disgust"] as? Double,
              let fear = dictionary["fear"] as? Double,
              let happiness = dictionary["happiness"] as? Double,
              let sadness = dictionary["sadness"] as? Double,
              let surprise = dictionary["surprise"] as? Double,
              let neutral = dictionary["neutral"] as? Double else {
            return nil
        }
        return PyFeatResponse(anger: anger, disgust: disgust, fear: fear, happiness: happiness, sadness: sadness, surprise: surprise, neutral: neutral)
    }
}

func PyFeatEmotions(for pyFeatResponse: PyFeatResponse) -> [Emotion] {
    return [
        Emotion(type: "anger", value: pyFeatResponse.anger),
        Emotion(type: "disgust", value: pyFeatResponse.disgust),
        Emotion(type: "fear", value: pyFeatResponse.fear),
        Emotion(type: "happiness", value: pyFeatResponse.happiness),
        Emotion(type: "sadness", value: pyFeatResponse.sadness),
        Emotion(type: "surprise", value: pyFeatResponse.surprise),
        Emotion(type: "neutral", value: pyFeatResponse.neutral)
    ]
}

func DefaultPyFeatEmotions() -> [Emotion] {
    return [
        Emotion(type: "anger", value: 0),
        Emotion(type: "disgust", value: 0),
        Emotion(type: "fear", value: 0),
        Emotion(type: "happiness", value: 0),
        Emotion(type: "sadness", value: 0),
        Emotion(type: "surprise", value: 0),
        Emotion(type: "neutral", value: 0)
    ]
}
