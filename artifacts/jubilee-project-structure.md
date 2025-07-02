# JubileeWatch iOS Project Structure

## Project Setup Instructions for Claude Code

### 1. Initialize Xcode Project

```bash
# Create new iOS app project
# Bundle ID: com.mobilebay.jubileewatch
# Interface: SwiftUI
# Language: Swift
# Include Core Data: No (using custom models)
# Include Tests: Yes
```

### 2. Directory Structure

```
JubileeWatch/
├── JubileeWatch/
│   ├── App/
│   │   ├── JubileeWatchApp.swift
│   │   └── Info.plist
│   ├── Models/
│   │   ├── Environmental/
│   │   │   ├── EnvironmentalReading.swift
│   │   │   └── Coordinate.swift
│   │   ├── Predictions/
│   │   │   ├── JubileePrediction.swift
│   │   │   └── ContributingFactor.swift
│   │   ├── User/
│   │   │   ├── User.swift
│   │   │   └── NotificationPreferences.swift
│   │   ├── Community/
│   │   │   ├── ChatMessage.swift
│   │   │   ├── ForumPost.swift
│   │   │   └── Sighting.swift
│   │   └── Historical/
│   │       └── JubileeEvent.swift
│   ├── Services/
│   │   ├── API/
│   │   │   ├── APIService.swift
│   │   │   ├── APIEndpoints.swift
│   │   │   └── WebSocketManager.swift
│   │   ├── Prediction/
│   │   │   └── JubileePredictor.swift
│   │   ├── Location/
│   │   │   └── LocationManager.swift
│   │   ├── Notifications/
│   │   │   └── NotificationManager.swift
│   │   └── Cache/
│   │       └── CacheManager.swift
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── ProbabilityGaugeView.swift
│   │   │   └── EnvironmentalConditionsView.swift
│   │   ├── Community/
│   │   │   ├── CommunityView.swift
│   │   │   ├── ChatView.swift
│   │   │   └── ForumView.swift
│   │   ├── Map/
│   │   │   ├── JubileeMapView.swift
│   │   │   └── HeatMapOverlay.swift
│   │   ├── Trends/
│   │   │   ├── TrendsView.swift
│   │   │   └── ChartsView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   └── LocationPickerView.swift
│   │   └── Components/
│   │       ├── TabBarView.swift
│   │       └── AlertBanner.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── Localizable.strings
│   └── Utilities/
│       ├── Extensions/
│       │   ├── Color+Theme.swift
│       │   └── Date+Formatting.swift
│       └── Constants.swift
├── JubileeWatchTests/
│   ├── ModelTests/
│   ├── ServiceTests/
│   ├── ViewModelTests/
│   └── Mocks/
└── JubileeWatchUITests/
    └── UITests.swift
```

### 3. Dependencies (Swift Package Manager)

Add these packages in Xcode:

```swift
// Package.swift dependencies
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
    .package(url: "https://github.com/danielgindi/Charts", from: "5.0.0"),
    .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0"),
    .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
]
```

### 4. Required Capabilities & Permissions

Enable in Xcode project settings:
- Push Notifications
- Background Modes (Remote notifications, Background fetch)
- Location Services (When In Use & Always)

Info.plist keys:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>JubileeWatch needs your location to provide accurate jubilee predictions for your area.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Enable background location to receive jubilee alerts even when the app is closed.</string>
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to share photos of jubilee sightings.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is needed to share jubilee photos.</string>
```

### 5. API Configuration

Create `Config.swift`:
```swift
struct Config {
    static let apiBaseURL = "https://api.jubileewatch.com/v1"
    static let websocketURL = "wss://api.jubileewatch.com/ws"
    static let mapboxAccessToken = "YOUR_MAPBOX_TOKEN"
    
    // Feature flags
    static let isDebugMode = DEBUG
    static let mockDataEnabled = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
}
```

### 6. Color Theme

```swift
extension Color {
    static let jubileePrimary = Color(hex: "06B6D4") // Cyan-500
    static let jubileeBackground = Color(hex: "111827") // Gray-900
    static let jubileeSecondary = Color(hex: "1F2937") // Gray-800
    static let jubileeAccent = Color(hex: "10B981") // Green-400
    static let jubileeWarning = Color(hex: "F59E0B") // Yellow-400
    static let jubileeDanger = Color(hex: "EF4444") // Red-400
}
```

### 7. Core Services Implementation

#### LocationManager.swift
```swift
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    private let manager = CLLocationManager()
    
    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
}
```

#### NotificationManager.swift
```swift
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleJubileeAlert(_ prediction: JubileePrediction) {
        let content = UNMutableNotificationContent()
        content.title = "High Jubilee Probability!"
        content.body = "\(Int(prediction.probability))% chance at \(prediction.location)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: prediction.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

### 8. Build Schemes

Create these schemes in Xcode:
- **JubileeWatch**: Production build
- **JubileeWatch-Dev**: Development with mock data
- **JubileeWatch-UITests**: UI testing with mock services

### 9. GitHub Actions CI/CD

`.github/workflows/ios.yml`:
```yaml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -switch /Applications/Xcode_15.0.app
      
    - name: Build and Test
      run: |
        xcodebuild clean build test \
          -project JubileeWatch.xcodeproj \
          -scheme JubileeWatch \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### 10. SwiftUI App Entry Point

```swift
import SwiftUI

@main
struct JubileeWatchApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var apiService = APIService()
    @StateObject private var predictionManager = PredictionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(apiService)
                .environmentObject(predictionManager)
                .preferredColorScheme(.dark)
        }
    }
}
```

## Next Steps for Claude Code

1. Initialize Git repository
2. Create Xcode project with the above structure
3. Copy the data models from the artifacts
4. Implement the SwiftUI views based on the React mockup
5. Set up the testing framework
6. Configure CI/CD
7. Add app icons and launch screen

The React mockup provides the visual design and interaction patterns that should be translated to SwiftUI components. Each React component has a corresponding SwiftUI view in the project structure.