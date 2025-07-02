import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let profileImageURL: String?
    let homeLocation: Coordinate?
    let savedLocations: [SavedLocation]
    let notificationPreferences: NotificationPreferences
    let reliabilityScore: Double // 0-100
    let joinDate: Date
    let contributions: Int
}

struct SavedLocation: Codable, Identifiable {
    let id: UUID
    let name: String
    let coordinate: Coordinate
    let isDefault: Bool
    let notificationsEnabled: Bool
}