import Foundation
import Combine

class APIService: ObservableObject {
    private let session: URLSessionProtocol
    private let baseURL = URL(string: Config.apiBaseURL)!
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        setupURLSession()
    }
    
    private func setupURLSession() {
        if let urlSession = session as? URLSession {
            urlSession.configuration.timeoutIntervalForRequest = Config.apiTimeout
            urlSession.configuration.timeoutIntervalForResource = Config.apiTimeout
        }
    }
    
    func fetchCurrentConditions() async throws -> EnvironmentalReading {
        let url = baseURL.appendingPathComponent(APIEndpoints.Environmental.current)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JubileeWatch/\(Constants.App.version)", forHTTPHeaderField: "User-Agent")
        
        return try await performRequest(request: request, responseType: EnvironmentalReading.self)
    }
    
    func fetchCurrentPrediction() async throws -> JubileePrediction {
        let url = baseURL.appendingPathComponent(APIEndpoints.Predictions.current)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JubileeWatch/\(Constants.App.version)", forHTTPHeaderField: "User-Agent")
        
        return try await performRequest(request: request, responseType: JubileePrediction.self)
    }
    
    func submitSighting(_ sighting: Sighting) async throws -> APIResponse<Sighting> {
        let url = baseURL.appendingPathComponent(APIEndpoints.Community.sightings)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JubileeWatch/\(Constants.App.version)", forHTTPHeaderField: "User-Agent")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(sighting)
        
        return try await performRequestWithResponse(request: request, responseType: APIResponse<Sighting>.self)
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(request: URLRequest, responseType: T.Type) async throws -> T {
        let response: APIResponse<T> = try await performRequestWithResponse(request: request, responseType: APIResponse<T>.self)
        
        if response.success, let data = response.data {
            return data
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Unknown error")
        }
    }
    
    private func performRequestWithResponse<T: Codable>(request: URLRequest, responseType: T.Type) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...Config.maxRetryAttempts {
            do {
                let (data, urlResponse) = try await session.data(for: request)
                
                // Check HTTP status code
                if let httpResponse = urlResponse as? HTTPURLResponse {
                    guard 200...299 ~= httpResponse.statusCode else {
                        throw APIServiceError.httpError(httpResponse.statusCode)
                    }
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    return try decoder.decode(responseType, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    if Config.isDebugMode {
                        print("Response data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
                    }
                    throw APIServiceError.decodingError
                }
                
            } catch {
                lastError = error
                
                if attempt < Config.maxRetryAttempts {
                    print("Request failed, retrying in \(Config.retryDelay) seconds (attempt \(attempt)/\(Config.maxRetryAttempts))")
                    try await Task.sleep(nanoseconds: UInt64(Config.retryDelay * 1_000_000_000))
                } else {
                    print("Request failed after \(Config.maxRetryAttempts) attempts")
                }
            }
        }
        
        throw lastError ?? APIServiceError.requestFailed("Unknown error after \(Config.maxRetryAttempts) attempts")
    }
}

enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingError
    case httpError(Int)
    case networkError
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .decodingError:
            return "Failed to decode response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .networkError:
            return "Network connection error"
        case .timeout:
            return "Request timed out"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .timeout:
            return true
        case .httpError(let code):
            return code >= 500 || code == 429 // Server errors or rate limiting
        default:
            return false
        }
    }
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}