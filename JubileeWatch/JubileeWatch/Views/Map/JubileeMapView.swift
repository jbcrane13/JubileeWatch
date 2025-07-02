import SwiftUI
import MapKit

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
            .overlay(
                Text("\(Int(zone.probability))%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            )
    }
}

struct MapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Jubilee Probability")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "Low (0-30%)")
                LegendItem(color: .yellow, label: "Moderate (30-75%)")
                LegendItem(color: .red, label: "High (75%+)")
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}

struct JubileeZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let probability: Double
    let radius: Double
}

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var jubileeZones: [JubileeZone] = []
    
    init() {
        setupMockZones()
    }
    
    private func setupMockZones() {
        jubileeZones = [
            JubileeZone(
                coordinate: CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035),
                probability: 75,
                radius: 25
            ),
            JubileeZone(
                coordinate: CLLocationCoordinate2D(latitude: 30.6740, longitude: -87.9211),
                probability: 45,
                radius: 20
            ),
            JubileeZone(
                coordinate: CLLocationCoordinate2D(latitude: 30.4969, longitude: -87.8811),
                probability: 20,
                radius: 15
            )
        ]
    }
}

#Preview {
    JubileeMapView()
        .preferredColorScheme(.dark)
}