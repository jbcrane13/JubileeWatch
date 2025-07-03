import Foundation

struct WebcamAPIResponse: Codable {
    let webcams: [WebcamData]
    let locations: [WebcamLocationData]
    let conditions: [WebcamConditionData]
}

struct WebcamData: Codable, Identifiable {
    let id: String
    let name: String
    let location: String
    let description: String?
    let thumbnailURL: String
    let streamURL: String
    let isLive: Bool
    let quality: String
    let viewCount: Int
    let lastUpdated: Date
    let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, description
        case thumbnailURL = "thumbnail_url"
        case streamURL = "stream_url"
        case isLive = "is_live"
        case quality
        case viewCount = "view_count"
        case lastUpdated = "last_updated"
        case coordinates
    }
}

struct WebcamLocationData: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let imageURL: String
    let webcamCount: Int
    let hasActiveJubilee: Bool
    let primaryWebcamId: String
    let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case imageURL = "image_url"
        case webcamCount = "webcam_count"
        case hasActiveJubilee = "has_active_jubilee"
        case primaryWebcamId = "primary_webcam_id"
        case coordinates
    }
}

struct WebcamConditionData: Codable, Identifiable {
    let id: String
    let icon: String
    let label: String
    let value: String
    let unit: String?
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, icon, label, value, unit
        case lastUpdated = "last_updated"
    }
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

// Legacy support models for UI
extension WebcamData {
    var asWebcam: Webcam {
        return Webcam(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            location: location,
            thumbnailURL: thumbnailURL,
            streamURL: streamURL,
            isLive: isLive
        )
    }
}

extension WebcamLocationData {
    func asWebcamLocation(with webcam: Webcam) -> WebcamLocation {
        return WebcamLocation(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            imageURL: imageURL,
            webcamCount: webcamCount,
            hasActiveJubilee: hasActiveJubilee,
            primaryWebcam: webcam
        )
    }
}

extension WebcamConditionData {
    var asWebcamCondition: WebcamCondition {
        return WebcamCondition(
            icon: icon,
            label: label,
            value: value
        )
    }
}