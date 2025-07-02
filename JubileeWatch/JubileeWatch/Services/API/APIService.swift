import Foundation
import Combine

class APIService: ObservableObject {
    private let session: URLSessionProtocol
    private let baseURL = URL(string: Config.apiBaseURL)!
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchCurrentConditions() async throws -> EnvironmentalReading {
        let url = baseURL.appendingPathComponent(APIEndpoints.Environmental.current)
        let request = URLRequest(url: url)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<EnvironmentalReading>.self, from: data)
        
        if response.success, let environmentalData = response.data {
            return environmentalData
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Unknown error")
        }
    }
    
    func fetchCurrentPrediction() async throws -> JubileePrediction {
        let url = baseURL.appendingPathComponent(APIEndpoints.Predictions.current)
        let request = URLRequest(url: url)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<JubileePrediction>.self, from: data)
        
        if response.success, let prediction = response.data {
            return prediction
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Unknown error")
        }
    }
    
    func submitSighting(_ sighting: Sighting) async throws -> APIResponse<Sighting> {
        let url = baseURL.appendingPathComponent(APIEndpoints.Community.sightings)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(sighting)
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Sighting>.self, from: data)
        
        return response
    }
}

enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}