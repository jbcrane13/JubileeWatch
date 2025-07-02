import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let content: String
    let timestamp: Date
    let location: Coordinate?
    let attachments: [Attachment]?
}

struct Attachment: Codable {
    let type: AttachmentType
    let url: String
    let thumbnail: String?
}

enum AttachmentType: String, Codable {
    case image
    case video
}