import Foundation

struct Config {
    static let apiBaseURL = "https://api.jubileewatch.com/v1"
    static let websocketURL = "wss://api.jubileewatch.com/ws"
    
    // Feature flags
    static let isDebugMode = DEBUG
    static let mockDataEnabled = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
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