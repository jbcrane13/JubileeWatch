import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Alert Banner
                    if viewModel.showHighProbabilityAlert {
                        AlertBanner(
                            message: "High Jubilee Probability Detected!",
                            type: .warning
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Oxygen Level Trend
                    OxygenLevelTrendView()
                        .padding(.horizontal)
                    
                    // Environmental Conditions
                    EnvironmentalConditionsGrid(conditions: viewModel.currentConditions)
                        .padding(.horizontal)
                    
                    // Recent Activity
                    RecentActivitySection(activities: viewModel.recentActivities)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.jubileeBackground)
            .navigationTitle("JubileeWatch")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

class DashboardViewModel: ObservableObject {
    @Published var currentProbability: Double = 65.0
    @Published var showHighProbabilityAlert = false
    @Published var currentConditions: [EnvironmentalCondition] = []
    @Published var recentActivities: [Activity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService()
    private var updateTimer: Timer?
    
    init() {
        if Config.mockDataEnabled {
            setupMockData()
            simulateRealTimeUpdates()
        } else {
            Task {
                await loadRealTimeData()
            }
            startRealTimeUpdates()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func setupMockData() {
        currentConditions = [
            EnvironmentalCondition(
                icon: "thermometer",
                label: "Water Temp",
                value: "78°F",
                trend: "↑ 2° from yesterday",
                isOptimal: true
            ),
            EnvironmentalCondition(
                icon: "drop.fill",
                label: "Dissolved O₂",
                value: "3.2 ppm",
                trend: "↓ 0.1 from yesterday",
                isOptimal: false
            ),
            EnvironmentalCondition(
                icon: "wind",
                label: "Wind Speed",
                value: "3 mph",
                trend: "SE direction",
                isOptimal: true
            ),
            EnvironmentalCondition(
                icon: "humidity.fill",
                label: "Humidity",
                value: "92%",
                trend: "↑ 5% from yesterday",
                isOptimal: true
            ),
            EnvironmentalCondition(
                icon: "water.waves",
                label: "Wave Height",
                value: "2.5 ft",
                trend: "↓ 0.5 ft from yesterday",
                isOptimal: true
            )
        ]
        
        recentActivities = [
            Activity(id: UUID(), title: "New sighting reported", subtitle: "Fairhope Pier - 2 min ago", type: .sighting),
            Activity(id: UUID(), title: "Probability updated", subtitle: "65% → 68%", type: .prediction),
            Activity(id: UUID(), title: "Community alert", subtitle: "High activity reported", type: .community)
        ]
    }
    
    @MainActor
    private func loadRealTimeData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let conditionsTask = apiService.fetchCurrentConditions()
            async let predictionTask = apiService.fetchCurrentPrediction()
            
            let (conditions, prediction) = try await (conditionsTask, predictionTask)
            
            // Convert environmental reading to UI conditions
            currentConditions = convertToEnvironmentalConditions(conditions)
            currentProbability = prediction.probability
            
            // Check for high probability alert
            if currentProbability > Constants.Notification.highProbabilityThreshold && !showHighProbabilityAlert {
                showHighProbabilityAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showHighProbabilityAlert = false
                }
            }
            
            // TODO: Fetch recent activities from API
            loadRecentActivities()
            
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to mock data
            setupMockData()
        }
        
        isLoading = false
    }
    
    private func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: Constants.Notification.updateInterval, repeats: true) { _ in
            Task {
                await self.loadRealTimeData()
            }
        }
    }
    
    private func simulateRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.currentProbability += Double.random(in: -5...5)
            self.currentProbability = max(0, min(100, self.currentProbability))
            
            if self.currentProbability > 75 && !self.showHighProbabilityAlert {
                self.showHighProbabilityAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showHighProbabilityAlert = false
                }
            }
        }
    }
    
    private func convertToEnvironmentalConditions(_ reading: EnvironmentalReading) -> [EnvironmentalCondition] {
        var conditions: [EnvironmentalCondition] = []
        
        let waterTemp = reading.waterTemperature
        conditions.append(EnvironmentalCondition(
            icon: "thermometer",
            label: "Water Temp",
            value: "\(Int(waterTemp))°F",
            trend: calculateTrend(value: waterTemp, optimal: 75...82),
            isOptimal: (75...82).contains(waterTemp)
        ))
        
        if let oxygen = reading.dissolvedOxygen {
            conditions.append(EnvironmentalCondition(
                icon: "drop.fill",
                label: "Dissolved O₂",
                value: "\(String(format: "%.1f", oxygen)) ppm",
                trend: calculateTrend(value: oxygen, optimal: 2.0...4.0),
                isOptimal: (2.0...4.0).contains(oxygen)
            ))
        }
        
        let windSpeed = reading.windSpeed
        conditions.append(EnvironmentalCondition(
            icon: "wind",
            label: "Wind Speed",
            value: "\(Int(windSpeed)) mph",
            trend: reading.windDirection,
            isOptimal: windSpeed < 10
        ))
        
        let humidity = reading.humidity
        conditions.append(EnvironmentalCondition(
            icon: "humidity.fill",
            label: "Humidity",
            value: "\(Int(humidity))%",
            trend: calculateTrend(value: humidity, optimal: 80...95),
            isOptimal: (80...95).contains(humidity)
        ))
        
        if let waveHeight = reading.waveHeight {
            conditions.append(EnvironmentalCondition(
                icon: "water.waves",
                label: "Wave Height",
                value: "\(String(format: "%.1f", waveHeight)) ft",
                trend: calculateTrend(value: waveHeight, optimal: 0...3),
                isOptimal: waveHeight < 3
            ))
        }
        
        return conditions
    }
    
    private func calculateTrend(value: Double, optimal: ClosedRange<Double>) -> String {
        if optimal.contains(value) {
            return "Optimal range"
        } else if value < optimal.lowerBound {
            return "Below optimal"
        } else {
            return "Above optimal"
        }
    }
    
    private func loadRecentActivities() {
        // Placeholder for real API call
        recentActivities = [
            Activity(id: UUID(), title: "Current conditions updated", subtitle: "\(Int(currentProbability))% probability", type: .prediction),
            Activity(id: UUID(), title: "Environmental data refreshed", subtitle: "\(currentConditions.count) metrics updated", type: .sighting)
        ]
    }
    
    func refreshData() {
        if Config.mockDataEnabled {
            setupMockData()
        } else {
            Task {
                await loadRealTimeData()
            }
        }
    }
}

struct EnvironmentalCondition: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
    let trend: String
    let isOptimal: Bool
}

struct Activity: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: ActivityType
}

enum ActivityType {
    case sighting, prediction, community
}

#Preview {
    DashboardView()
}