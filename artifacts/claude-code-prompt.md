# Claude Code Implementation Prompt for JubileeWatch iOS App

Please create a complete iOS app project called JubileeWatch using the provided artifacts. Follow these steps carefully:

## 1. Initialize the Xcode Project

```bash
# Create a new iOS app project with these specifications:
- Product Name: JubileeWatch
- Team: None (for now)
- Organization Identifier: com.mobilebay
- Bundle Identifier: com.mobilebay.jubileewatch
- Interface: SwiftUI
- Language: Swift
- Use Core Data: NO
- Include Tests: YES
- Create Git repository on my Mac: YES
```

**IMPORTANT**: This should create a `JubileeWatch.xcodeproj` file in the root directory.

## 2. Set Up Directory Structure

Create the following directory structure inside the JubileeWatch folder (referring to the JubileeWatch iOS Project Structure artifact):

```
JubileeWatch/
├── JubileeWatch/
│   ├── App/
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   ├── Resources/
│   └── Utilities/
├── JubileeWatchTests/
└── JubileeWatchUITests/
```

## 3. Implement Data Models

Using the **JubileeWatch Data Models & API Structure** artifact:
- Create all model files in their respective subdirectories under Models/
- Copy all structs, enums, and type definitions exactly as provided
- Ensure all Codable conformances are maintained

## 4. Implement SwiftUI Views

Using the **JubileeWatch SwiftUI Views** artifact:
- Create all view files in their respective subdirectories under Views/
- Start with ContentView.swift as the main tab container
- Implement each screen (Dashboard, Community, Map, Trends, Settings)
- Create the reusable components in Views/Components/

## 5. Create Color Theme Extension

Create `Utilities/Extensions/Color+Theme.swift`:
```swift
import SwiftUI

extension Color {
    static let jubileePrimary = Color(red: 6/255, green: 182/255, blue: 212/255) // Cyan-500
    static let jubileeBackground = Color(red: 17/255, green: 24/255, blue: 39/255) // Gray-900
    static let jubileeSecondary = Color(red: 31/255, green: 41/255, blue: 55/255) // Gray-800
    static let jubileeAccent = Color(red: 16/255, green: 185/255, blue: 129/255) // Green-400
    static let jubileeWarning = Color(red: 245/255, green: 158/255, blue: 11/255) // Yellow-400
    static let jubileeDanger = Color(red: 239/255, green: 68/255, blue: 68/255) // Red-400
}
```

## 6. Update App Entry Point

Replace the default JubileeWatchApp.swift with:
```swift
import SwiftUI

@main
struct JubileeWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
```

## 7. Add Dependencies

In Xcode:
1. Select the JubileeWatch project in navigator
2. Select the JubileeWatch target
3. Go to "Package Dependencies" tab
4. Add these Swift packages:
   - https://github.com/Alamofire/Alamofire (5.8.0)
   - https://github.com/danielgindi/Charts-ios.git (5.0.0)
   - https://github.com/daltoniam/Starscream (4.0.0)

## 8. Configure Capabilities & Info.plist

1. In project settings, enable these capabilities:
   - Push Notifications
   - Background Modes (check: Remote notifications, Background fetch)
   - Maps (for MapKit usage)

2. Add to Info.plist:
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

## 9. Implement Testing Framework

Using the **JubileeWatch Testing Framework** artifact:
- Create test files in JubileeWatchTests/
- Implement MockDataGenerator class
- Add unit tests for models and predictions
- Create mock network session
- Set up UI test scenarios in JubileeWatchUITests/

## 10. Create Placeholder Service Files

Create these placeholder files in Services/:
- `API/APIService.swift`
- `API/WebSocketManager.swift`  
- `Prediction/JubileePredictor.swift`
- `Location/LocationManager.swift`
- `Notifications/NotificationManager.swift`
- `Cache/CacheManager.swift`

Each should contain a basic class structure that the views expect.

## 11. Add App Icons and Launch Screen

1. In Assets.xcassets, add an AppIcon set
2. Create a LaunchScreen with:
   - Dark background (#111827)
   - "JubileeWatch" text in center
   - Wave icon or imagery

## 12. Create Build Schemes

In Xcode, create these schemes:
- **JubileeWatch** (default, for production)
- **JubileeWatch-Dev** (with environment variable: MOCK_DATA_ENABLED = YES)
- **JubileeWatch-UITests** (for UI testing)

## 13. Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: JubileeWatch iOS app structure"
```

## 14. Build and Run

1. Select the iPhone 15 Pro simulator
2. Build the project (⌘B) to ensure no compilation errors
3. Run the app (⌘R) to see the UI mockup working

## Important Notes:

- The **JubileeWatch iOS App Mockup** artifact shows the React version for visual reference - translate the design to SwiftUI
- Start with getting the tab navigation and basic screens working, then add features incrementally
- Some features (like real-time data) will need backend integration later
- Use the mock data generator from the testing framework to populate the UI during development

## Verification Checklist:
- [ ] JubileeWatch.xcodeproj file exists
- [ ] All 5 main screens are accessible via tab navigation
- [ ] Dark mode UI with cyan accents is working
- [ ] Project builds without errors
- [ ] Basic navigation between screens works
- [ ] Test files are in place

Please implement this step by step, and let me know if you need clarification on any part!
each of the artifacts that I have  mentioned, have been downloaded and saved to the follwing directory: /Users/blake/Documents/GitHub/JubileeWatch