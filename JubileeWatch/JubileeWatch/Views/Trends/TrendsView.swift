import SwiftUI
import Charts

struct TrendsView: View {
    @StateObject private var viewModel = TrendsViewModel()
    @State private var selectedTimeRange = TimeRange.day
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Probability Trend Chart
                    ProbabilityTrendChart(dataPoints: viewModel.probabilityTrend)
                        .frame(height: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.jubileeSecondary)
                        )
                        .padding(.horizontal)
                    
                    // Environmental Metrics
                    EnvironmentalMetricsSection(metrics: viewModel.environmentalMetrics)
                        .padding(.horizontal)
                    
                    // Historical Events
                    HistoricalEventsSection(events: viewModel.historicalEvents)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.jubileeBackground)
            .navigationTitle("Trends & Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProbabilityTrendChart: View {
    let dataPoints: [DataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Probability Trend")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.date),
                    y: .value("Probability", point.value)
                )
                .foregroundStyle(Color.jubileePrimary)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Time", point.date),
                    y: .value("Probability", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.jubileePrimary.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel("\(value.as(Int.self) ?? 0)%")
                }
            }
            .frame(height: 150)
        }
    }
}

struct EnvironmentalMetricsSection: View {
    let metrics: [EnvironmentalMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Environmental Factors")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(metrics) { metric in
                    MetricCard(metric: metric)
                }
            }
        }
    }
}

struct MetricCard: View {
    let metric: EnvironmentalMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(metric.currentValue)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: metric.trend > 0 ? "arrow.up" : "arrow.down")
                    .foregroundColor(metric.trend > 0 ? .jubileeAccent : .jubileeDanger)
                
                Text("\(abs(metric.trend), specifier: "%.1f")%")
                    .foregroundColor(metric.trend > 0 ? .jubileeAccent : .jubileeDanger)
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.jubileeSecondary)
        )
    }
}

struct HistoricalEventsSection: View {
    let events: [JubileeEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Events")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ForEach(events.prefix(3)) { event in
                HistoricalEventCard(event: event)
            }
        }
    }
}

struct HistoricalEventCard: View {
    let event: JubileeEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.startTime.formatted(style: .medium))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(event.actualIntensity.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(intensityColor(event.actualIntensity))
                    )
            }
            
            Text("Peak Probability: \(Int(event.peakProbability))%")
                .font(.subheadline)
                .foregroundColor(.jubileePrimary)
            
            Text("\(event.confirmedSightings.count) confirmed sightings")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.jubileeSecondary)
        )
    }
    
    private func intensityColor(_ intensity: JubileeIntensity) -> Color {
        switch intensity {
        case .minor: return .green
        case .moderate: return .yellow
        case .major: return .orange
        case .exceptional: return .red
        }
    }
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct EnvironmentalMetric: Identifiable {
    let id = UUID()
    let name: String
    let currentValue: String
    let trend: Double // Percentage change
}

enum TimeRange: String, CaseIterable, Identifiable {
    case day = "24 Hours"
    case week = "7 Days"
    case month = "30 Days"
    
    var id: String { rawValue }
}

class TrendsViewModel: ObservableObject {
    @Published var probabilityTrend: [DataPoint] = []
    @Published var environmentalMetrics: [EnvironmentalMetric] = []
    @Published var historicalEvents: [JubileeEvent] = []
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Generate mock probability trend data
        probabilityTrend = (0..<24).map { hours in
            DataPoint(
                date: Date().addingTimeInterval(-Double(hours) * 3600),
                value: Double.random(in: 20...80)
            )
        }.reversed()
        
        environmentalMetrics = [
            EnvironmentalMetric(name: "Water Temperature", currentValue: "78°F", trend: 2.3),
            EnvironmentalMetric(name: "Dissolved Oxygen", currentValue: "3.2 ppm", trend: -5.1),
            EnvironmentalMetric(name: "Wind Speed", currentValue: "3 mph", trend: 1.2),
            EnvironmentalMetric(name: "Humidity", currentValue: "92%", trend: 4.8)
        ]
        
        // Mock historical events would be populated from the data models
        historicalEvents = []
    }
}

#Preview {
    TrendsView()
        .preferredColorScheme(.dark)
}