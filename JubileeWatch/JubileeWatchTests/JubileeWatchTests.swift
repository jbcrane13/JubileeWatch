import XCTest
import Combine
@testable import JubileeWatch

final class JubileeWatchTests: XCTestCase {
    var apiService: APIService!
    var mockURLSession: MockURLSession!
    
    override func setUpWithError() throws {
        mockURLSession = MockURLSession()
        apiService = APIService(session: mockURLSession)
    }
    
    override func tearDownWithError() throws {
        apiService = nil
        mockURLSession = nil
    }
    
    func testPredictionCalculation() throws {
        let environmentalData = MockDataGenerator.mockEnvironmentalReading()
        let predictor = JubileePredictor()
        
        let prediction = predictor.calculateProbability(from: environmentalData)
        
        XCTAssertGreaterThanOrEqual(prediction.probability, 0)
        XCTAssertLessThanOrEqual(prediction.probability, 100)
        XCTAssertFalse(prediction.contributingFactors.isEmpty)
    }
    
    func testConfidenceLevelMapping() {
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
}

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
            )
        ]
    }
}

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