import SwiftUI

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    ForumPostCard(post: post)
                }
            }
            .padding()
        }
        .background(Color.jubileeBackground)
    }
}

struct ForumPostCard: View {
    let post: ForumPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text(post.username)
                            .font(.caption)
                            .foregroundColor(.jubileePrimary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(post.timestamp.timeAgoDisplay())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if post.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.jubileeAccent)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(post.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.jubileePrimary.opacity(0.3))
                        )
                }
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(3)
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(.jubileeAccent)
                    Text("\(post.upvotes)")
                        .foregroundColor(.jubileeAccent)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.secondary)
                    Text("\(post.replies.count)")
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.jubileeSecondary)
        )
    }
}

class ForumViewModel: ObservableObject {
    @Published var posts: [ForumPost] = []
    
    init() {
        setupMockPosts()
    }
    
    private func setupMockPosts() {
        posts = [
            ForumPost(
                id: UUID(),
                userId: UUID(),
                username: "FishingPro24",
                title: "Massive jubilee at Spanish Fort!",
                content: "Just witnessed an incredible jubilee event. Hundreds of fish, crabs, and shrimp along the shoreline. Water temp was perfect at 79°F with low dissolved oxygen. Lasted about 2 hours.",
                category: .sighting,
                timestamp: Date().addingTimeInterval(-3600),
                location: Coordinate(latitude: 30.6740, longitude: -87.9211),
                images: nil,
                replies: [],
                upvotes: 15,
                verified: true
            ),
            ForumPost(
                id: UUID(),
                userId: UUID(),
                username: "BayWatcher",
                title: "Best time of day for jubilees?",
                content: "I've been tracking patterns and notice most jubilees happen early morning or late evening. Anyone else notice this trend?",
                category: .question,
                timestamp: Date().addingTimeInterval(-7200),
                location: nil,
                images: nil,
                replies: [
                    ForumReply(
                        id: UUID(),
                        userId: UUID(),
                        username: "SaltWaterSage",
                        content: "Definitely early morning for me. Dawn seems to be prime time.",
                        timestamp: Date().addingTimeInterval(-6000)
                    )
                ],
                upvotes: 8,
                verified: false
            ),
            ForumPost(
                id: UUID(),
                userId: UUID(),
                username: "CoastalBiologist",
                title: "Understanding dissolved oxygen levels",
                content: "For newcomers: Jubilees typically occur when dissolved oxygen drops below 3 ppm. Fish and marine life move to shallow, oxygen-rich waters near shore.",
                category: .tips,
                timestamp: Date().addingTimeInterval(-10800),
                location: nil,
                images: nil,
                replies: [],
                upvotes: 23,
                verified: true
            )
        ]
    }
}

#Preview {
    ForumView()
        .preferredColorScheme(.dark)
}