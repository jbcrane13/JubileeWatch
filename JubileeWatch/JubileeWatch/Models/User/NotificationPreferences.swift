import Foundation

struct NotificationPreferences: Codable {
    var pushEnabled: Bool
    var highProbabilityOnly: Bool
    var minimumProbability: Double
    var quietHoursEnabled: Bool
    var quietHoursStart: Date
    var quietHoursEnd: Date
    var communityAlertsEnabled: Bool
}