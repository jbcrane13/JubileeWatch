# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JubileeWatch is an iOS app for monitoring and predicting jubilee events along the Gulf Coast. It's built with SwiftUI targeting iOS 17.0+ and uses a clean MVVM architecture with service layers.

## Release Candidate Status

🚀 **RELEASE CANDIDATE READY** - All mock data has been replaced with real API integration:
- Environmental data now fetches from `https://api.jubileewatch.com/v1/environmental/current`
- Webcam feeds connect to `https://streams.jubileewatch.com/` endpoints
- Community features use real API endpoints for sightings and alerts
- Production error handling with retry logic implemented
- Build passes for both Debug and Release configurations

## Build and Development Commands

### Building the Project
```bash
# Build for iOS Simulator
xcodebuild -project JubileeWatch.xcodeproj -scheme JubileeWatch -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild -project JubileeWatch.xcodeproj -scheme JubileeWatch clean build

# Build with specific iOS version
xcodebuild -project JubileeWatch.xcodeproj -scheme JubileeWatch -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project JubileeWatch.xcodeproj -scheme JubileeWatch -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test class
xcodebuild test -project JubileeWatch.xcodeproj -scheme JubileeWatch -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:JubileeWatchTests/ServiceTests
```

### Swift Package Manager
```bash
# Resolve dependencies
swift package resolve

# Update dependencies
swift package update
```

## Architecture & Code Structure

### Core Architecture Pattern
The app follows MVVM with a service layer:
- **Views** handle UI presentation using SwiftUI
- **Services** manage business logic, API calls, and data persistence
- **Models** define data structures shared across the app
- **Utilities** contain extensions and constants

### Key Service Layers

1. **APIService** (`Services/API/APIService.swift`)
   - Central API communication using URLSession with protocol abstraction
   - Base URL: `https://api.jubileewatch.com/v1`
   - Implements URLSessionProtocol for testability

2. **WebSocketManager** (`Services/API/WebSocketManager.swift`)
   - Real-time updates via WebSocket
   - URL: `wss://api.jubileewatch.com/ws`

3. **LocationManager** (`Services/Location/LocationManager.swift`)
   - Handles GPS and location permissions
   - Default location: Fairhope Municipal Pier (30.5225, -87.9035)

4. **NotificationManager** (`Services/Notifications/NotificationManager.swift`)
   - Push notification handling
   - High probability threshold: 75%
   - Update interval: 5 minutes

### Project File Structure Notes

The project has a nested structure: `JubileeWatch/JubileeWatch/JubileeWatch/`
- Root `JubileeWatch/` contains the `.xcodeproj` file
- Second `JubileeWatch/` is the main target directory
- Third `JubileeWatch/` contains the actual source files

Assets are duplicated at root level due to Xcode project configuration requirements.

### API Endpoints Structure
The app expects these API endpoint patterns:
- `/environmental/current` - Current environmental conditions
- `/predictions/current` - Current jubilee predictions
- `/community/sightings` - Submit and retrieve sightings

### Dependencies (via Swift Package Manager)
- Alamofire (5.8.0+) - Networking
- Charts (5.0.0+) - Data visualization
- Starscream (4.0.0+) - WebSocket client

### Environment Configuration

The app uses compile-time flags and runtime arguments:
```swift
#if DEBUG
static let isDebugMode = true
static let mockDataEnabled = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
#else 
static let isDebugMode = false
static let mockDataEnabled = false  // No mock data in release builds
#endif

// API Configuration
static let apiTimeout: TimeInterval = 30.0
static let maxRetryAttempts = 3
static let retryDelay: TimeInterval = 1.0
```

### Release Configuration

**Production API Endpoints:**
- Base URL: `https://api.jubileewatch.com/v1`
- WebSocket: `wss://api.jubileewatch.com/ws`
- Streaming: `https://streams.jubileewatch.com`
- Images: `https://api.jubileewatch.com/images`

**Error Handling:**
- Automatic retry for network failures (max 3 attempts)
- Graceful fallback to cached data when API unavailable
- User-friendly error messages with recovery suggestions
- Offline mode support with local data persistence

### Required Permissions
The Info.plist must include:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `UIBackgroundModes`: background-fetch, remote-notification, location

### Common Development Tasks

When adding new features:
1. Models go in `Models/` with appropriate subdirectory
2. Services go in `Services/` following the protocol-oriented pattern
3. Views go in `Views/` organized by feature area
4. Always check for existing utilities in `Utilities/Extensions/` before creating new ones

### Testing Approach
- Unit tests use protocol abstractions for mocking (see URLSessionProtocol pattern)
- Test files mirror the source structure in `JubileeWatchTests/`
- Mock data generators available for UI testing when `UI_TESTING` argument is set