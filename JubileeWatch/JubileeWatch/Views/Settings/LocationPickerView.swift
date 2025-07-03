import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 30.5225, longitude: -87.9035)
    @State private var addressSearchText = ""
    @State private var isSearching = false
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedAddress = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Address Search Bar
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search address...", text: $addressSearchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .onSubmit {
                                searchForAddress()
                            }
                        
                        if !addressSearchText.isEmpty {
                            Button(action: {
                                addressSearchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding()
                    
                    // Search Results
                    if !searchResults.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button(action: {
                                        selectSearchResult(item)
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Unknown")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text(formatAddress(item.placemark))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Divider()
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(Color.jubileeSecondary)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                // Map
                Map(coordinateRegion: $region, annotationItems: [LocationPin(coordinate: selectedLocation)]) { pin in
                    MapPin(coordinate: pin.coordinate, tint: .red)
                }
                .onTapGesture { location in
                    // Convert tap location to coordinate
                    selectedLocation = region.center
                    reverseGeocode(coordinate: region.center)
                }
                
                // Location Details
                VStack(spacing: 16) {
                    Text("Selected Location")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if !selectedAddress.isEmpty {
                        Text(selectedAddress)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Text("\(selectedLocation.latitude, specifier: "%.4f")°, \(selectedLocation.longitude, specifier: "%.4f")°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Save Location") {
                        // Save the selected location
                        saveLocation()
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
    
    // MARK: - Geocoding Functions
    
    private func searchForAddress() {
        guard !addressSearchText.isEmpty else { return }
        
        isSearching = true
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = addressSearchText
        searchRequest.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30.5, longitude: -87.9),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            isSearching = false
            
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    private func selectSearchResult(_ mapItem: MKMapItem) {
        if let location = mapItem.placemark.location?.coordinate {
            selectedLocation = location
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            selectedAddress = formatAddress(mapItem.placemark)
        }
        
        searchResults = []
        addressSearchText = ""
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                selectedAddress = formatAddress(MKPlacemark(placemark: placemark))
            }
        }
    }
    
    private func formatAddress(_ placemark: MKPlacemark) -> String {
        var components: [String] = []
        
        if let name = placemark.name {
            components.append(name)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }
        
        return components.joined(separator: ", ")
    }
    
    private func saveLocation() {
        // Save to UserDefaults or your preferred storage
        UserDefaults.standard.set(selectedLocation.latitude, forKey: "homeLocationLatitude")
        UserDefaults.standard.set(selectedLocation.longitude, forKey: "homeLocationLongitude")
        UserDefaults.standard.set(selectedAddress, forKey: "homeLocationAddress")
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