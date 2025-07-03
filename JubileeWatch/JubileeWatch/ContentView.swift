import SwiftUI

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

            WebcamView()
                .tabItem {
                    Label("Webcam", systemImage: "video.fill")
                }
                .tag(3)

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .accentColor(.jubileePrimary)
    }
}

#Preview {
    ContentView()
}