import SwiftUI
import AVKit

struct WebcamView: View {
    private let streamURL = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
    @State private var player: AVPlayer? = nil

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView("Loading Webcam…")
                    .task {
                        player = AVPlayer(url: streamURL)
                    }
            }
        }
        .navigationTitle("Live Webcam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WebcamView()
}
