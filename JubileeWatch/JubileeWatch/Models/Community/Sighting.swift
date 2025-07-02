import Foundation

struct Sighting: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let timestamp: Date
    let location: Coordinate
    let species: [String]
    let description: String
    let photos: [String]?
    let verifiedByUsers: [UUID]
}