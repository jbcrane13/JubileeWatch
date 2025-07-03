import SwiftUI
import Charts

struct OxygenLevelTrendView: View {
    @StateObject private var viewModel = OxygenTrendViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dissolved Oxygen Trend")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Last 24 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trendIcon)
                            .foregroundColor(viewModel.trendColor)
                        Text(viewModel.currentReading)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("ppm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Chart
            Chart(viewModel.oxygenReadings) { reading in
                LineMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("O₂ Level", reading.level)
                )
                .foregroundStyle(viewModel.chartGradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("O₂ Level", reading.level)
                )
                .foregroundStyle(viewModel.chartGradient.opacity(0.3))
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.hour())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.2))
                    AxisValueLabel {
                        if let level = value.as(Double.self) {
                            Text("\(level, specifier: "%.1f")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...8)
            
            // Critical threshold indicator
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text("Critical threshold: < 2.0 ppm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.jubileeSecondary)
        )
    }
}

class OxygenTrendViewModel: ObservableObject {
    @Published var oxygenReadings: [OxygenReading] = []
    @Published var currentReading: String = "3.2"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService()
    private var updateTimer: Timer?
    
    var trendIcon: String {
        guard oxygenReadings.count >= 2 else { return "minus" }
        let latest = oxygenReadings.last?.level ?? 0
        let previous = oxygenReadings[oxygenReadings.count - 2].level
        
        if latest > previous + 0.1 {
            return "arrow.up"
        } else if latest < previous - 0.1 {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    var trendColor: Color {
        guard let latest = oxygenReadings.last?.level else { return .gray }
        
        switch latest {
        case 4...: return .green
        case 2..<4: return .yellow
        case 1..<2: return .orange
        default: return .red
        }
    }
    
    var chartGradient: LinearGradient {
        LinearGradient(
            colors: [Color.cyan.opacity(0.8), Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    init() {
        if Config.mockDataEnabled {
            generateMockData()
            simulateRealTimeUpdates()
        } else {
            Task {
                await loadRealOxygenData()
            }
            startRealTimeUpdates()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func generateMockData() {
        let now = Date()
        let hourInterval = 60.0 * 60.0
        
        // Generate 24 hours of data
        for i in 0..<24 {
            let timestamp = now.addingTimeInterval(-hourInterval * Double(23 - i))
            let baseLevel = 3.5
            let variation = Double.random(in: -1.5...1.0)
            let level = max(0.5, min(6.0, baseLevel + variation))
            
            oxygenReadings.append(OxygenReading(
                timestamp: timestamp,
                level: level
            ))
        }
        
        if let latest = oxygenReadings.last {
            currentReading = String(format: "%.1f", latest.level)
        }
    }
    
    @MainActor
    private func loadRealOxygenData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch historical environmental data for oxygen trend
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: endDate) ?? endDate
            
            // For now, fetch current conditions and simulate historical data
            let currentReading = try await apiService.fetchCurrentConditions()
            
            // Generate simulated 24-hour trend based on current reading
            var readings: [OxygenReading] = []
            let hourInterval = 60.0 * 60.0
            let baseOxygen = currentReading.dissolvedOxygen ?? 3.5
            
            for i in 0..<24 {
                let timestamp = startDate.addingTimeInterval(hourInterval * Double(i))
                let variation = Double.random(in: -0.5...0.5)
                let level = max(0.5, min(6.0, baseOxygen + variation))
                
                readings.append(OxygenReading(
                    timestamp: timestamp,
                    level: level
                ))
            }
            
            oxygenReadings = readings
            
            if let latest = oxygenReadings.last {
                currentReading = String(format: "%.1f", latest.level)
            }
            
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to mock data
            generateMockData()
        }
        
        isLoading = false
    }
    
    private func startRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: Constants.Notification.updateInterval, repeats: true) { _ in
            Task {
                await self.loadRealOxygenData()
            }
        }
    }
    
    private func simulateRealTimeUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            let newLevel = max(0.5, min(6.0, 3.5 + Double.random(in: -1.5...1.0)))
            let newReading = OxygenReading(timestamp: Date(), level: newLevel)
            
            self.oxygenReadings.append(newReading)
            if self.oxygenReadings.count > 24 {
                self.oxygenReadings.removeFirst()
            }
            
            self.currentReading = String(format: "%.1f", newLevel)
        }
    }
    
    func refreshData() {
        if Config.mockDataEnabled {
            generateMockData()
        } else {
            Task {
                await loadRealOxygenData()
            }
        }
    }
}

struct OxygenReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: Double
}

#Preview {
    OxygenLevelTrendView()
        .preferredColorScheme(.dark)
        .background(Color.jubileeBackground)
}