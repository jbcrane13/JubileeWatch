import Foundation
import Combine

class WebcamAPIService: ObservableObject {
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func fetchWebcams() async throws -> [WebcamData] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Webcams.list)
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[WebcamData]>.self, from: data)
        
        if response.success, let webcams = response.data {
            return webcams
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch webcams")
        }
    }
    
    func fetchWebcamLocations() async throws -> [WebcamLocationData] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Webcams.locations)
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[WebcamLocationData]>.self, from: data)
        
        if response.success, let locations = response.data {
            return locations
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch webcam locations")
        }
    }
    
    func fetchWebcamConditions() async throws -> [WebcamConditionData] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Webcams.conditions)
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[WebcamConditionData]>.self, from: data)
        
        
        if response.success, let conditions = response.data {
            return conditions
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch webcam conditions")
        }
    }
}