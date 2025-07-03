import SwiftUI
import AVKit

struct WebcamDetailView: View {
    let webcam: Webcam
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(16/9, contentMode: .fit)
                        .background(Color.black)
                } else {
                    // Placeholder while loading
                    ZStack {
                        Color.black
                            .aspectRatio(16/9, contentMode: .fit)
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                            
                            Text("Loading stream...")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                }
                
                // Webcam Info
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(webcam.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                if webcam.isLive {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                        Text("LIVE")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                Text(webcam.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Share Button
                        Button(action: shareWebcam) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.jubileePrimary)
                                .font(.title3)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Quick Stats
                    HStack(spacing: 30) {
                        WebcamStat(icon: "eye", label: "Views", value: "1.2K")
                        WebcamStat(icon: "clock", label: "Updated", value: "2 min ago")
                        WebcamStat(icon: "camera", label: "Quality", value: "HD")
                    }
                    
                    // Description
                    Text("This webcam provides a live view of the \(webcam.location) area. Monitor real-time conditions and watch for jubilee activity along the coastline.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: toggleFullscreen) {
                            Label("Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.jubileePrimary)
                                )
                        }
                        
                        Button(action: reportIssue) {
                            Label("Report Issue", systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(Color.jubileeBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.jubileePrimary)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: webcam.streamURL) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }
    
    private func shareWebcam() {
        // Implement share functionality
    }
    
    private func toggleFullscreen() {
        // Implement fullscreen toggle
    }
    
    private func reportIssue() {
        // Implement issue reporting
    }
}

struct WebcamStat: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.jubileePrimary)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WebcamDetailView(webcam: Webcam(
        id: UUID(),
        name: "Fairhope Pier",
        location: "Fairhope, AL",
        thumbnailURL: "https://example.com/thumb.jpg",
        streamURL: "https://example.com/stream.m3u8",
        isLive: true
    ))
    .preferredColorScheme(.dark)
}