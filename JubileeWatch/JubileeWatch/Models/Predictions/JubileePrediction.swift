import Foundation

struct JubileePrediction: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let location: Coordinate
    let probability: Double // 0-100
    let confidence: ConfidenceLevel
    let contributingFactors: [ContributingFactor]
    let predictedTimeWindow: DateInterval
    let lastUpdated: Date
}

enum ConfidenceLevel: String, Codable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case critical = "Critical"
}