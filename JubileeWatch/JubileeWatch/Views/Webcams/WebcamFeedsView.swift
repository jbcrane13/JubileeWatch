import SwiftUI
import AVKit

struct WebcamFeedsView: View {
    @StateObject private var viewModel = WebcamFeedsViewModel()
    @State private var selectedWebcam: Webcam?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Live Webcams Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Live Coastal Webcams")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.webcams) { webcam in
                                    WebcamCard(webcam: webcam) {
                                        selectedWebcam = webcam
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Popular Locations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Locations")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.popularLocations) { location in
                                LocationWebcamRow(location: location) {
                                    selectedWebcam = location.primaryWebcam
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Weather Conditions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Conditions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        WebcamConditionsGrid(conditions: viewModel.currentConditions)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.jubileeBackground)
            .navigationTitle("Webcams")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedWebcam) { webcam in
            WebcamDetailView(webcam: webcam)
        }
    }
}

struct WebcamCard: View {
    let webcam: Webcam
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Webcam Thumbnail
            ZStack {
                AsyncImage(url: URL(string: webcam.thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
                .frame(width: 200, height: 150)
                .clipped()
                .cornerRadius(12)
                
                // Live indicator
                if webcam.isLive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            
            Text(webcam.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(webcam.location)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 200)
        .onTapGesture {
            onTap()
        }
    }
}

struct LocationWebcamRow: View {
    let location: WebcamLocation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location Image
                AsyncImage(url: URL(string: location.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 60)
                .clipped()
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.caption2)
                            Text("\(location.webcamCount)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        if location.hasActiveJubilee {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("Active")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.jubileeSecondary)
            )
        }
    }
}

struct WebcamConditionsGrid: View {
    let conditions: [WebcamCondition]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(conditions) { condition in
                HStack(spacing: 12) {
                    Image(systemName: condition.icon)
                        .foregroundColor(.jubileePrimary)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(condition.label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(condition.value)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - View Models and Data Structures

class WebcamFeedsViewModel: ObservableObject {
    @Published var webcams: [Webcam] = []
    @Published var popularLocations: [WebcamLocation] = []
    @Published var currentConditions: [WebcamCondition] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let webcamAPIService = WebcamAPIService()
    
    init() {
        if Config.mockDataEnabled {
            loadMockData()
        } else {
            Task {
                await loadWebcamData()
            }
        }
    }
    
    @MainActor
    private func loadWebcamData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let webcamDataTask = webcamAPIService.fetchWebcams()
            async let locationDataTask = webcamAPIService.fetchWebcamLocations()
            async let conditionDataTask = webcamAPIService.fetchWebcamConditions()
            
            let (webcamData, locationData, conditionData) = try await (webcamDataTask, locationDataTask, conditionDataTask)
            
            // Convert API models to UI models
            webcams = webcamData.map { $0.asWebcam }
            
            // Map locations with their primary webcams
            popularLocations = locationData.compactMap { locationData in
                if let primaryWebcam = webcams.first(where: { $0.id.uuidString == locationData.primaryWebcamId }) {
                    return locationData.asWebcamLocation(with: primaryWebcam)
                }
                return nil
            }
            
            currentConditions = conditionData.map { $0.asWebcamCondition }
            
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to mock data if API fails
            loadMockData()
        }
        
        isLoading = false
    }
    
    func refreshData() {
        Task {
            await loadWebcamData()
        }
    }
    
    private func loadMockData() {
        // Mock webcam data - fallback for when API is unavailable
        webcams = [
            Webcam(
                id: UUID(),
                name: "Fairhope Pier",
                location: "Fairhope, AL",
                thumbnailURL: "https://api.jubileewatch.com/images/fairhope-pier-thumb.jpg",
                streamURL: "https://streams.jubileewatch.com/fairhope-pier.m3u8",
                isLive: true
            ),
            Webcam(
                id: UUID(),
                name: "Mobile Bay Causeway",
                location: "Mobile, AL",
                thumbnailURL: "https://api.jubileewatch.com/images/causeway-thumb.jpg",
                streamURL: "https://streams.jubileewatch.com/causeway.m3u8",
                isLive: true
            ),
            Webcam(
                id: UUID(),
                name: "Dauphin Island Beach",
                location: "Dauphin Island, AL",
                thumbnailURL: "https://api.jubileewatch.com/images/dauphin-island-thumb.jpg",
                streamURL: "https://streams.jubileewatch.com/dauphin-island.m3u8",
                isLive: false
            ),
            Webcam(
                id: UUID(),
                name: "Gulf Shores Beach",
                location: "Gulf Shores, AL",
                thumbnailURL: "https://api.jubileewatch.com/images/gulf-shores-thumb.jpg",
                streamURL: "https://streams.jubileewatch.com/gulf-shores.m3u8",
                isLive: true
            )
        ]
        
        // Popular locations
        popularLocations = [
            WebcamLocation(
                id: UUID(),
                name: "Fairhope Municipal Pier",
                imageURL: "https://api.jubileewatch.com/images/fairhope-location.jpg",
                webcamCount: 3,
                hasActiveJubilee: true,
                primaryWebcam: webcams[0]
            ),
            WebcamLocation(
                id: UUID(),
                name: "Eastern Shore",
                imageURL: "https://api.jubileewatch.com/images/eastern-shore.jpg",
                webcamCount: 5,
                hasActiveJubilee: false,
                primaryWebcam: webcams[1]
            ),
            WebcamLocation(
                id: UUID(),
                name: "Point Clear",
                imageURL: "https://api.jubileewatch.com/images/point-clear.jpg",
                webcamCount: 2,
                hasActiveJubilee: false,
                primaryWebcam: webcams[2]
            )
        ]
        
        // Current conditions
        currentConditions = [
            WebcamCondition(icon: "eye.fill", label: "Visibility", value: "10 miles"),
            WebcamCondition(icon: "cloud.fill", label: "Sky", value: "Partly Cloudy"),
            WebcamCondition(icon: "sunrise.fill", label: "Sunrise", value: "6:42 AM"),
            WebcamCondition(icon: "sunset.fill", label: "Sunset", value: "7:15 PM")
        ]
    }
}

struct Webcam: Identifiable {
    let id: UUID
    let name: String
    let location: String
    let thumbnailURL: String
    let streamURL: String
    let isLive: Bool
}

struct WebcamLocation: Identifiable {
    let id: UUID
    let name: String
    let imageURL: String
    let webcamCount: Int
    let hasActiveJubilee: Bool
    let primaryWebcam: Webcam
}

struct WebcamCondition: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
}

#Preview {
    WebcamFeedsView()
        .preferredColorScheme(.dark)
}