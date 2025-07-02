import SwiftUI

struct SettingsView: View {
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("highAlertsOnly") private var highAlertsOnly = false
    @AppStorage("darkMode") private var darkMode = true
    @State private var showingLocationPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    HStack {
                        ProfileAvatar(initials: "JD", size: 60)
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Member since June 2024")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Navigate to profile
                    }
                }
                .listRowBackground(Color.jubileeSecondary)
                
                // Location Section
                Section("Home Location") {
                    Button(action: { showingLocationPicker = true }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Fairhope Municipal Pier")
                                    .foregroundColor(.white)
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
                .listRowBackground(Color.jubileeSecondary)
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                        .foregroundColor(.white)
                    
                    Toggle("High Probability Alerts Only", isOn: $highAlertsOnly)
                        .disabled(!pushNotifications)
                        .foregroundColor(.white)
                        
                    if pushNotifications {
                        HStack {
                            Text("Minimum Probability")
                                .foregroundColor(.white)
                            Spacer()
                            Text("60%")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listRowBackground(Color.jubileeSecondary)
                
                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkMode)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.jubileeSecondary)
                
                // Data & Privacy Section
                Section("Data & Privacy") {
                    SettingsRow(
                        title: "Data Usage",
                        subtitle: "Manage offline data",
                        icon: "icloud.and.arrow.down"
                    )
                    
                    SettingsRow(
                        title: "Privacy Settings",
                        subtitle: "Location and data sharing",
                        icon: "hand.raised"
                    )
                }
                .listRowBackground(Color.jubileeSecondary)
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    SettingsRow(
                        title: "Terms of Service",
                        subtitle: nil,
                        icon: "doc.text"
                    )
                    
                    SettingsRow(
                        title: "Privacy Policy",
                        subtitle: nil,
                        icon: "shield"
                    )
                    
                    SettingsRow(
                        title: "Contact Support",
                        subtitle: "Get help with the app",
                        icon: "questionmark.circle"
                    )
                }
                .listRowBackground(Color.jubileeSecondary)
                
                // Sign Out
                Section {
                    Button(action: { /* Sign out */ }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                .listRowBackground(Color.jubileeSecondary)
            }
            .scrollContentBackground(.hidden)
            .background(Color.jubileeBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView()
        }
    }
}

struct ProfileAvatar: View {
    let initials: String
    let size: CGFloat
    
    var body: some View {
        Text(initials)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.jubileePrimary)
            )
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.jubileePrimary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle navigation
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}