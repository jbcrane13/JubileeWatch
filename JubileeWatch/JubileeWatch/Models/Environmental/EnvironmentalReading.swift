import Foundation
import CoreLocation

struct EnvironmentalReading: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let location: Coordinate
    let waterTemperature: Double // Fahrenheit
    let airTemperature: Double // Fahrenheit
    let humidity: Double // Percentage
    let windSpeed: Double // mph
    let windDirection: String // Cardinal direction
    let atmosphericPressure: Double // inHg
    let dissolvedOxygen: Double? // ppm
    let waterLevel: Double? // feet
    let salinity: Double? // ppt
}