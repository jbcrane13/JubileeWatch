// MARK: - Core Data Models

import Foundation
import CoreLocation

// MARK: - Environmental Data

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

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Jubilee Prediction

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

// MARK: - User & Social

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

struct NotificationPreferences: Codable {
    var pushEnabled: Bool
    var highProbabilityOnly: Bool
    var minimumProbability: Double
    var quietHoursEnabled: Bool
    var quietHoursStart: Date
    var quietHoursEnd: Date
    var communityAlertsEnabled: Bool
}

// MARK: - Community Features

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let content: String
    let timestamp: Date
    let location: Coordinate?
    let attachments: [Attachment]?
}

struct ForumPost: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let title: String
    let content: String
    let category: PostCategory
    let timestamp: Date
    let location: Coordinate?
    let images: [String]?
    let replies: [ForumReply]
    let upvotes: Int
    let verified: Bool
}

struct ForumReply: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let content: String
    let timestamp: Date
}

enum PostCategory: String, Codable, CaseIterable {
    case sighting = "Sighting Report"
    case question = "Question"
    case discussion = "Discussion"
    case tips = "Tips & Advice"
    case photos = "Photos"
}

struct Attachment: Codable {
    let type: AttachmentType
    let url: String
    let thumbnail: String?
}

enum AttachmentType: String, Codable {
    case image
    case video
}

// MARK: - Historical Data

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

enum JubileeIntensity: String, Codable, CaseIterable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case exceptional = "Exceptional"
}

// MARK: - API Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: APIError?
    let timestamp: Date
}

struct APIError: Codable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let totalItems: Int
    let hasMore: Bool
}

// MARK: - API Endpoints Structure

struct APIEndpoints {
    static let baseURL = "https://api.jubileewatch.com/v1"
    
    struct Environmental {
        static let current = "/environmental/current"
        static let historical = "/environmental/historical"
        static let forecast = "/environmental/forecast"
    }
    
    struct Predictions {
        static let current = "/predictions/current"
        static let historical = "/predictions/historical"
        static let subscribe = "/predictions/subscribe"
    }
    
    struct Community {
        static let chat = "/community/chat"
        static let forum = "/community/forum"
        static let sightings = "/community/sightings"
    }
    
    struct User {
        static let profile = "/user/profile"
        static let locations = "/user/locations"
        static let preferences = "/user/preferences"
    }
    
    struct Analytics {
        static let trends = "/analytics/trends"
        static let patterns = "/analytics/patterns"
        static let statistics = "/analytics/statistics"
    }
}

// MARK: - WebSocket Events

enum WebSocketEvent: String {
    case environmentalUpdate = "environmental_update"
    case predictionUpdate = "prediction_update"
    case chatMessage = "chat_message"
    case communityAlert = "community_alert"
    case jubileeConfirmed = "jubilee_confirmed"
}

// MARK: - Cache Models

struct CachedData<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}