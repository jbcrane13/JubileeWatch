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
                    
                    // Probability Gauge
                    ProbabilityGaugeView(probability: viewModel.currentProbability)
                        .frame(height: 300)
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
    
    init() {
        setupMockData()
        simulateRealTimeUpdates()
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
            )
        ]
        
        recentActivities = [
            Activity(id: UUID(), title: "New sighting reported", subtitle: "Fairhope Pier - 2 min ago", type: .sighting),
            Activity(id: UUID(), title: "Probability updated", subtitle: "65% → 68%", type: .prediction),
            Activity(id: UUID(), title: "Community alert", subtitle: "High activity reported", type: .community)
        ]
    }
    
    private func simulateRealTimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
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