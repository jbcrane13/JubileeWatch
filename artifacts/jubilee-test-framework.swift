// MARK: - Testing Framework for JubileeWatch

import XCTest
import Combine
@testable import JubileeWatch

// MARK: - Mock Data Generators

class MockDataGenerator {
    
    static func mockEnvironmentalReading(
        temperature: Double = 78.0,
        humidity: Double = 92.0,
        windSpeed: Double = 3.0,
        dissolvedOxygen: Double = 3.2
    ) -> EnvironmentalReading {
        return EnvironmentalReading(
            id: UUID(),
            timestamp: Date(),
            location: Coordinate(latitude: 30.5225, longitude: -87.9035),
            waterTemperature: temperature,
            airTemperature: temperature + 2,
            humidity: humidity,
            windSpeed: windSpeed,
            windDirection: "SE",
            atmosphericPressure: 30.12,
            dissolvedOxygen: dissolvedOxygen,
            waterLevel: 2.3,
            salinity: 25.0
        )
    }
    
    static func mockJubileePrediction(probability: Double = 65.0) -> JubileePrediction {
        let confidence: ConfidenceLevel = {
            switch probability {
            case 0..<30: return .low
            case 30..<60: return .moderate
            case 60..<80: return .high
            default: return .critical
            }
        }()
        
        return JubileePrediction(
            id: UUID(),
            timestamp: Date(),
            location: Coordinate(latitude: 30.5225, longitude: -87.9035),
            probability: probability,
            confidence: confidence,
            contributingFactors: mockContributingFactors(),
            predictedTimeWindow: DateInterval(start: Date(), duration: 7200),
            lastUpdated: Date()
        )
    }
    
    static func mockContributingFactors() -> [ContributingFactor] {
        return [
            ContributingFactor(
                factor: .waterTemperature,
                value: 78.0,
                impact: 0.8,
                threshold: Threshold(min: 75.0, max: 82.0, optimal: 78.0)
            ),
            ContributingFactor(
                factor: .dissolvedOxygen,
                value: 3.2,
                impact: 0.9,
                threshold: Threshold(min: 0.0, max: 4.0, optimal: 2.0)
            ),
            ContributingFactor(
                factor: .windSpeed,
                value: 3.0,
                impact: 0.7,
                threshold: Threshold(min: 0.0, max: 5.0, optimal: 2.0)
            )
        ]
    }
    
    static func mockUser() -> User {
        return User(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            profileImageURL: nil,
            homeLocation: Coordinate(latitude: 30.5225, longitude: -87.9035),
            savedLocations: [mockSavedLocation()],
            notificationPreferences: mockNotificationPreferences(),
            reliabilityScore: 85.0,
            joinDate: Date().addingTimeInterval(-30*24*60*60),
            contributions: 42
        )
    }
    
    static func mockSavedLocation() -> SavedLocation {
        return SavedLocation(
            id: UUID(),
            name: "Fairhope Pier",
            coordinate: Coordinate(latitude: 30.5225, longitude: -87.9035),
            isDefault: true,
            notificationsEnabled: true
        )
    }
    
    static func mockNotificationPreferences() -> NotificationPreferences {
        return NotificationPreferences(
            pushEnabled: true,
            highProbabilityOnly: false,
            minimumProbability: 60.0,
            quietHoursEnabled: true,
            quietHoursStart: Date(),
            quietHoursEnd: Date(),
            communityAlertsEnabled: true
        )
    }
}

// MARK: - Unit Tests

class JubileePredictionTests: XCTestCase {
    
    func testPredictionCalculation() {
        // Given
        let environmentalData = MockDataGenerator.mockEnvironmentalReading()
        let predictor = JubileePredictor()
        
        // When
        let prediction = predictor.calculateProbability(from: environmentalData)
        
        // Then
        XCTAssertGreaterThanOrEqual(prediction.probability, 0)
        XCTAssertLessThanOrEqual(prediction.probability, 100)
        XCTAssertFalse(prediction.contributingFactors.isEmpty)
    }
    
    func testConfidenceLevelMapping() {
        // Test each confidence level
        let testCases: [(Double, ConfidenceLevel)] = [
            (15.0, .low),
            (45.0, .moderate),
            (70.0, .high),
            (85.0, .critical)
        ]
        
        for (probability, expectedLevel) in testCases {
            let prediction = MockDataGenerator.mockJubileePrediction(probability: probability)
            XCTAssertEqual(prediction.confidence, expectedLevel)
        }
    }
    
    func testEnvironmentalThresholds() {
        let factor = MockDataGenerator.mockContributingFactors().first!
        
        XCTAssertTrue(factor.value >= factor.threshold.min)
        XCTAssertTrue(factor.value <= factor.threshold.max)
        XCTAssertNotNil(factor.impact)
    }
}

// MARK: - API Tests

class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        apiService = APIService(session: mockURLSession)
    }
    
    func testFetchCurrentConditions() async throws {
        // Given
        let expectedData = MockDataGenerator.mockEnvironmentalReading()
        mockURLSession.data = try JSONEncoder().encode(
            APIResponse(success: true, data: expectedData, error: nil, timestamp: Date())
        )
        
        // When
        let result = try await apiService.fetchCurrentConditions()
        
        // Then
        XCTAssertEqual(result.waterTemperature, expectedData.waterTemperature)
        XCTAssertEqual(result.humidity, expectedData.humidity)
    }
    
    func testWebSocketConnection() {
        let expectation = XCTestExpectation(description: "WebSocket connects")
        let webSocketManager = WebSocketManager()
        
        webSocketManager.onConnect = {
            expectation.fulfill()
        }
        
        webSocketManager.connect()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAPIErrorHandling() async {
        // Given
        let apiError = APIError(
            code: "RATE_LIMIT",
            message: "Rate limit exceeded",
            details: ["retry_after": "60"]
        )
        mockURLSession.data = try! JSONEncoder().encode(
            APIResponse<EnvironmentalReading>(
                success: false,
                data: nil,
                error: apiError,
                timestamp: Date()
            )
        )
        
        // When/Then
        do {
            _ = try await apiService.fetchCurrentConditions()
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is APIServiceError)
        }
    }
}

// MARK: - Mock Network Session

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        let response = self.response ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data ?? Data(), response)
    }
}

// MARK: - UI Tests

class JubileeWatchUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    func testTabNavigation() {
        // Test Dashboard is default
        XCTAssertTrue(app.staticTexts["JubileeWatch"].exists)
        
        // Navigate to Community
        app.tabBars.buttons["Community"].tap()
        XCTAssertTrue(app.staticTexts["Community"].exists)
        
        // Navigate to Map
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.staticTexts["Jubilee Map"].exists)
        
        // Navigate to Trends
        app.tabBars.buttons["Trends"].tap()
        XCTAssertTrue(app.staticTexts["Trends & Analytics"].exists)
        
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
    }
    
    func testHighProbabilityAlert() {
        // Wait for high probability condition
        let alert = app.otherElements["High Jubilee Probability Detected!"]
        
        // Simulate high probability
        app.launchEnvironment = ["MOCK_HIGH_PROBABILITY": "true"]
        app.launch()
        
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
    }
    
    func testChatMessageSending() {
        // Navigate to Community
        app.tabBars.buttons["Community"].tap()
        
        // Type message
        let messageField = app.textFields["Type a message..."]
        messageField.tap()
        messageField.typeText("Test message")
        
        // Send message
        app.buttons["Send"].tap()
        
        // Verify message appears
        XCTAssertTrue(app.staticTexts["Test message"].exists)
    }
    
    func testLocationSettings() {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Tap Change location
        app.buttons["Change"].tap()
        
        // Verify location picker appears
        XCTAssertTrue(app.maps.element.exists)
    }
}

// MARK: - Integration Tests

class JubileeIntegrationTests: XCTestCase {
    
    func testEndToEndPredictionFlow() async throws {
        // 1. Fetch environmental data
        let apiService = APIService()
        let environmentalData = try await apiService.fetchCurrentConditions()
        
        // 2. Calculate prediction
        let predictor = JubileePredictor()
        let prediction = predictor.calculateProbability(from: environmentalData)
        
        // 3. Store in cache
        let cacheManager = CacheManager()
        try cacheManager.store(prediction, key: "current_prediction")
        
        // 4. Trigger notification if needed
        let notificationManager = NotificationManager()
        if prediction.probability > 75 {
            try await notificationManager.scheduleHighProbabilityAlert(prediction)
        }
        
        // 5. Update UI
        XCTAssertNotNil(prediction)
        XCTAssertTrue(prediction.probability >= 0 && prediction.probability <= 100)
    }
    
    func testCommunityReportingFlow() async throws {
        // 1. User creates sighting
        let sighting = Sighting(
            id: UUID(),
            userId: UUID(),
            timestamp: Date(),
            location: Coordinate(latitude: 30.5225, longitude: -87.9035),
            species: ["Flounder", "Shrimp", "Blue Crab"],
            description: "Large jubilee event at pier",
            photos: nil,
            verifiedByUsers: []
        )
        
        // 2. Submit to API
        let apiService = APIService()
        let response = try await apiService.submitSighting(sighting)
        
        // 3. Broadcast via WebSocket
        let webSocketManager = WebSocketManager()
        webSocketManager.broadcast(event: .jubileeConfirmed, data: sighting)
        
        // 4. Update local cache
        let cacheManager = CacheManager()
        var cachedEvents = try cacheManager.fetch([JubileeEvent].self, key: "jubilee_events") ?? []
        // Add new event based on sighting
        
        XCTAssertTrue(response.success)
    }
}

// MARK: - Performance Tests

class PerformanceTests: XCTestCase {
    
    func testPredictionCalculationPerformance() {
        let environmentalData = MockDataGenerator.mockEnvironmentalReading()
        let predictor = JubileePredictor()
        
        measure {
            _ = predictor.calculateProbability(from: environmentalData)
        }
    }
    
    func testLargeDatasetProcessing() {
        let readings = (0..<1000).map { _ in
            MockDataGenerator.mockEnvironmentalReading()
        }
        
        measure {
            let analyzer = DataAnalyzer()
            _ = analyzer.processHistoricalData(readings)
        }
    }
    
    func testCachePerformance() {
        let cacheManager = CacheManager()
        let testData = MockDataGenerator.mockJubileePrediction()
        
        measure {
            try? cacheManager.store(testData, key: "test_key")
            _ = try? cacheManager.fetch(JubileePrediction.self, key: "test_key")
        }
    }
}

// MARK: - Test Protocols

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}