import Foundation

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

enum WebSocketEvent: String {
    case environmentalUpdate = "environmental_update"
    case predictionUpdate = "prediction_update"
    case chatMessage = "chat_message"
    case communityAlert = "community_alert"
    case jubileeConfirmed = "jubilee_confirmed"
}

struct CachedData<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}