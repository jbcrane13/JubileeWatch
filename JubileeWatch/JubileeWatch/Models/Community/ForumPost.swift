import Foundation

struct ForumPost: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let title: String
    let content: String
    let category: PostCategory
    let timestamp: Date
    let location: Coordinate?
    let images: [String]?
    let replies: [ForumReply]
    let upvotes: Int
    let verified: Bool
}

struct ForumReply: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let content: String
    let timestamp: Date
}

enum PostCategory: String, Codable, CaseIterable {
    case sighting = "Sighting Report"
    case question = "Question"
    case discussion = "Discussion"
    case tips = "Tips & Advice"
    case photos = "Photos"
}