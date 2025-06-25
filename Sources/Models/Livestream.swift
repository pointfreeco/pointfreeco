import Foundation
import Tagged

public struct Livestream: Codable, Identifiable {
  public let id: Tagged<Self, UUID>
  public let description: String
  public let isActive: Bool
  public let isLive: Bool
  public let liveDescription: String?
  public let scheduledAt: Date?
  public let title: String
  public let videoID: String

  public init(
    id: ID,
    description: String = "",
    isActive: Bool,
    isLive: Bool,
    liveDescription: String? = nil,
    scheduledAt: Date? = nil,
    title: String = "",
    videoID: String
  ) {
    self.id = id
    self.description = description
    self.isActive = isActive
    self.isLive = isLive
    self.liveDescription = liveDescription
    self.scheduledAt = scheduledAt
    self.title = title
    self.videoID = videoID
  }

  public enum CodingKeys: String, CodingKey {
    case id
    case description
    case isActive = "is_active"
    case isLive = "is_live"
    case liveDescription = "live_description"
    case scheduledAt = "scheduled_at"
    case title
    case videoID = "video_id"
  }
}
