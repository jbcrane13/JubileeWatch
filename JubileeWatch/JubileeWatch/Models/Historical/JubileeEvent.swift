import Foundation

struct JubileeEvent: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let peakTime: Date?
    let location: Coordinate
    let confirmedSightings: [Sighting]
    let environmentalData: [EnvironmentalReading]
    let peakProbability: Double
    let actualIntensity: JubileeIntensity
}

enum JubileeIntensity: String, Codable, CaseIterable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case exceptional = "Exceptional"
}