import Foundation

struct Video: Codable, Identifiable {
    let videoId: String
    let title: String
    let thumbnailUrl: String
    let url: String
    let videoType: VideoType

    var id: String { videoId }

    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case title
        case thumbnailUrl = "thumbnail_url"
        case url
        case videoType = "video_type"
    }
}

enum VideoType: String, Codable {
    case individual = "individual"
    case team = "team"
    case drill = "drill"

    var displayName: String {
        switch self {
        case .individual: return "Individual Highlights"
        case .team: return "Team Footage"
        case .drill: return "Training Drill"
        }
    }
}

struct VideoSearchResponse: Codable {
    let videos: [Video]
}
