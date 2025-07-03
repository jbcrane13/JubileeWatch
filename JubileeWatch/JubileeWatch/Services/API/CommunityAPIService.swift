import Foundation
import Combine

class CommunityAPIService: ObservableObject {
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func fetchRecentSightings(limit: Int = 20) async throws -> [Sighting] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Community.sightings)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sort", value: "timestamp_desc")
        ]
        
        guard let finalURL = urlComponents.url else {
            throw APIServiceError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JubileeWatch/\(Constants.App.version)", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[Sighting]>.self, from: data)
        
        if response.success, let sightings = response.data {
            return sightings
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch sightings")
        }
    }
    
    func submitSighting(_ sighting: Sighting) async throws -> Sighting {
        let response = try await apiService.submitSighting(sighting)
        
        if response.success, let submittedSighting = response.data {
            return submittedSighting
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to submit sighting")
        }
    }
    
    func fetchCommunityAlerts() async throws -> [CommunityAlert] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Community.alerts)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JubileeWatch/\(Constants.App.version)", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[CommunityAlert]>.self, from: data)
        
        if response.success, let alerts = response.data {
            return alerts
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch alerts")
        }
    }
}

struct CommunityAlert: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let alertType: AlertType
    let priority: AlertPriority
    let location: String?
    let coordinates: Coordinates?
    let timestamp: Date
    let expiresAt: Date?
    let isActive: Bool
    
    enum AlertType: String, Codable {
        case jubileeEvent = "jubilee_event"
        case highProbability = "high_probability"
        case weatherWarning = "weather_warning"
        case maintenanceAlert = "maintenance_alert"
    }
    
    enum AlertPriority: String, Codable {
        case low, medium, high, critical
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, message
        case alertType = "alert_type"
        case priority, location, coordinates, timestamp
        case expiresAt = "expires_at"
        case isActive = "is_active"
    }
}