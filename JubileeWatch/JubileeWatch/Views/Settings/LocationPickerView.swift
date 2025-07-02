import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035)
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, annotationItems: [LocationPin(coordinate: selectedLocation)]) { pin in
                    MapPin(coordinate: pin.coordinate, tint: .red)
                }
                .onTapGesture { location in
                    // Convert tap location to coordinate
                    selectedLocation = region.center
                }
                
                VStack(spacing: 16) {
                    Text("Selected Location")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(selectedLocation.latitude, specifier: "%.4f")°, \(selectedLocation.longitude, specifier: "%.4f")°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Save Location") {
                        // Save the selected location
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .background(Color.jubileeSecondary)
            }
            .background(Color.jubileeBackground)
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.jubileePrimary)
                }
            }
        }
    }
}

struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.jubileePrimary)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
    }
}

#Preview {
    LocationPickerView()
        .preferredColorScheme(.dark)
}