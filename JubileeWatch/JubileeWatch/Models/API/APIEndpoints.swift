import Foundation

struct APIEndpoints {
    struct Environmental {
        static let current = "environmental/current"
        static let historical = "environmental/historical"
        static let forecast = "environmental/forecast"
    }
    
    struct Predictions {
        static let current = "predictions/current"
        static let historical = "predictions/historical"
        static let forecast = "predictions/forecast"
    }
    
    struct Community {
        static let sightings = "community/sightings"
        static let reports = "community/reports"
        static let alerts = "community/alerts"
    }
    
    struct Webcams {
        static let list = "webcams/list"
        static let locations = "webcams/locations"
        static let conditions = "webcams/conditions"
    }
    
    struct User {
        static let profile = "user/profile"
        static let settings = "user/settings"
        static let notifications = "user/notifications"
    }
}

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: APIError?
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case success, data, error, timestamp
    }
}

struct APIError: Codable {
    let code: String
    let message: String
    let details: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let success: Bool
    let data: [T]
    let pagination: PaginationInfo
    let error: APIError?
    let timestamp: Date
}

struct PaginationInfo: Codable {
    let page: Int
    let pageSize: Int
    let totalPages: Int
    let totalCount: Int
    let hasNext: Bool
    let hasPrevious: Bool
}