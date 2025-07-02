import Foundation

struct ContributingFactor: Codable {
    let factor: EnvironmentalFactor
    let value: Double
    let impact: Double // -1 to 1, negative reduces probability, positive increases
    let threshold: Threshold
}

enum EnvironmentalFactor: String, Codable {
    case waterTemperature = "Water Temperature"
    case dissolvedOxygen = "Dissolved Oxygen"
    case windSpeed = "Wind Speed"
    case windDirection = "Wind Direction"
    case atmosphericPressure = "Atmospheric Pressure"
    case humidity = "Humidity"
    case tidalPhase = "Tidal Phase"
    case moonPhase = "Moon Phase"
}

struct Threshold: Codable {
    let min: Double
    let max: Double
    let optimal: Double
}