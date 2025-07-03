import Foundation

struct Config {
    static let apiBaseURL = "https://api.jubileewatch.com/v1"
    static let websocketURL = "wss://api.jubileewatch.com/ws"
    static let streamBaseURL = "https://streams.jubileewatch.com"
    static let imageBaseURL = "https://api.jubileewatch.com/images"
    
    // Feature flags
    #if DEBUG
    static let isDebugMode = true
    static let mockDataEnabled = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    #else
    static let isDebugMode = false
    static let mockDataEnabled = false
    #endif
    
    // API Configuration
    static let apiTimeout: TimeInterval = 30.0
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
}

struct Constants {
    struct App {
        static let name = "JubileeWatch"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.mobilebay.jubileewatch"
    }
    
    struct Defaults {
        static let defaultLatitude = 30.5225
        static let defaultLongitude = -87.9035
        static let defaultLocationName = "Fairhope Municipal Pier"
    }
    
    struct Notification {
        static let highProbabilityThreshold = 75.0
        static let updateInterval: TimeInterval = 300 // 5 minutes
    }
}