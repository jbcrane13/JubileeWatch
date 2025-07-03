import Foundation
import Combine

class EnvironmentalAPIService: ObservableObject {
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func fetchCurrentConditions() async throws -> EnvironmentalReading {
        return try await apiService.fetchCurrentConditions()
    }
    
    func fetchHistoricalData(startDate: Date, endDate: Date) async throws -> [EnvironmentalReading] {
        let url = URL(string: Config.apiBaseURL)!
            .appendingPathComponent(APIEndpoints.Environmental.historical)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let dateFormatter = ISO8601DateFormatter()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "start_date", value: dateFormatter.string(from: startDate)),
            URLQueryItem(name: "end_date", value: dateFormatter.string(from: endDate))
        ]
        
        guard let finalURL = urlComponents.url else {
            throw APIServiceError.invalidURL
        }
        
        let request = URLRequest(url: finalURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<[EnvironmentalReading]>.self, from: data)
        
        if response.success, let readings = response.data {
            return readings
        } else {
            throw APIServiceError.requestFailed(response.error?.message ?? "Failed to fetch historical data")
        }
    }
    
    func fetchOxygenTrendData(hours: Int = 24) async throws -> [OxygenReading] {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -hours, to: endDate) ?? endDate
        
        let readings = try await fetchHistoricalData(startDate: startDate, endDate: endDate)
        
        return readings.compactMap { reading in
            guard let oxygen = reading.dissolvedOxygen else { return nil }
            return OxygenReading(
                timestamp: reading.timestamp,
                oxygenLevel: oxygen,
                location: reading.location
            )
        }
    }
}

struct OxygenReading: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let oxygenLevel: Double
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case timestamp, oxygenLevel, location
    }
}