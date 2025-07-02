// MARK: - SwiftUI Implementation Examples

import SwiftUI
import Charts
import MapKit

// MARK: - Main Tab View

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)
            
            JubileeMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(2)
            
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.jubileePrimary)
    }
}

// MARK: - Dashboard View

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

// MARK: - Probability Gauge View

struct ProbabilityGaugeView: View {
    let probability: Double
    
    private var color: Color {
        switch probability {
        case 0..<30: return .green
        case 30..<60: return .yellow
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private var confidenceText: String {
        switch probability {
        case 0..<30: return "Low"
        case 30..<60: return "Moderate"
        case 60..<80: return "High"
        default: return "Critical"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Jubilee Probability")
                .font(.title2)
                .fontWeight(.semibold)
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: probability / 100)
                    .stroke(
                        AngularGradient(
                            colors: [color.opacity(0.5), color],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: probability)
                
                // Center Text
                VStack {
                    Text("\(Int(probability))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text(confidenceText)
                        .font(.headline)
                        .foregroundColor(color)
                }
            }
            .frame(width: 200, height: 200)
            
            Text("Next update in 5 minutes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.jubileeSecondary)
        )
    }
}

// MARK: - Environmental Conditions Grid

struct EnvironmentalConditionsGrid: View {
    let conditions: [EnvironmentalCondition]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Conditions")
                .font(.title3)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(conditions) { condition in
                    ConditionCard(condition: condition)
                }
            }
        }
    }
}

struct ConditionCard: View {
    let condition: EnvironmentalCondition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: condition.icon)
                    .foregroundColor(.jubileePrimary)
                Spacer()
                if condition.isOptimal {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(condition.label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(condition.value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(condition.trend)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.jubileeSecondary)
        )
    }
}

// MARK: - Community Chat View

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Online Users Banner
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.yellow)
                Text("\(viewModel.onlineUsers) users online")
                    .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.jubileeSecondary)
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id)
                    }
                }
            }
            
            // Input Bar
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.jubileePrimary))
                }
            }
            .padding()
            .background(Color.jubileeSecondary)
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var isCurrentUser: Bool {
        message.userId == AuthManager.shared.currentUserId
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(message.username)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isCurrentUser ? Color.jubileePrimary.opacity(0.2) : Color.gray.opacity(0.2))
                    )
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

// MARK: - Map View

struct JubileeMapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $viewModel.region,
                    annotationItems: viewModel.jubileeZones) { zone in
                    MapAnnotation(coordinate: zone.coordinate) {
                        JubileeZoneAnnotation(zone: zone)
                    }
                }
                .ignoresSafeArea()
                
                // Legend
                VStack {
                    Spacer()
                    HStack {
                        MapLegend()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.jubileeSecondary.opacity(0.9))
                            )
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Jubilee Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct JubileeZoneAnnotation: View {
    let zone: JubileeZone
    
    var color: Color {
        switch zone.probability {
        case 0..<30: return .green
        case 30..<75: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: zone.radius * 2, height: zone.radius * 2)
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
            )
    }
}

// MARK: - Trends View with Charts

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
        }
    }
}

struct ProbabilityTrendChart: View {
    let dataPoints: [DataPoint]
    
    var body: some View {
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
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("highAlertsOnly") private var highAlertsOnly = false
    @AppStorage("darkMode") private var darkMode = true
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    NavigationLink(destination: ProfileView()) {
                        HStack {
                            ProfileAvatar(initials: "JD", size: 60)
                            VStack(alignment: .leading) {
                                Text("John Doe")
                                    .font(.headline)
                                Text("Member since June 2024")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Location Section
                Section("Home Location") {
                    NavigationLink(destination: LocationPickerView()) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Fairhope Municipal Pier")
                                Text("30.5225° N, 87.9035° W")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("Change")
                                .foregroundColor(.jubileePrimary)
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("High Probability Alerts Only", isOn: $highAlertsOnly)
                        .disabled(!pushNotifications)
                }
                
                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("Terms of Service", destination: WebView(url: "https://jubileewatch.com/terms"))
                    NavigationLink("Privacy Policy", destination: WebView(url: "https://jubileewatch.com/privacy"))
                    NavigationLink("Contact Support", destination: SupportView())
                }
                
                // Sign Out
                Section {
                    Button(action: { authManager.signOut() }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Supporting Types

struct EnvironmentalCondition: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
    let trend: String
    let isOptimal: Bool
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum TimeRange: String, CaseIterable, Identifiable {
    case day = "24 Hours"
    case week = "7 Days"
    case month = "30 Days"
    
    var id: String { rawValue }
}

struct JubileeZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let probability: Double
    let radius: Double
}

// MARK: - View Models (Stubbed)

class DashboardViewModel: ObservableObject {
    @Published var currentProbability: Double = 65.0
    @Published var showHighProbabilityAlert = false
    @Published var currentConditions: [EnvironmentalCondition] = []
    @Published var recentActivities: [Activity] = []
    
    init() {
        // Initialize with mock data or fetch from API
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var onlineUsers = 47
    
    func sendMessage(_ text: String) {
        // Send via WebSocket
    }
}

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var jubileeZones: [JubileeZone] = []
}

class TrendsViewModel: ObservableObject {
    @Published var probabilityTrend: [DataPoint] = []
    @Published var environmentalMetrics: [EnvironmentalMetric] = []
    @Published var historicalEvents: [JubileeEvent] = []
}