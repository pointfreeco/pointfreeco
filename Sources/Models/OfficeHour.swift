import Cloudflare
import Foundation
import Tagged
import TaggedTime

public struct OfficeHour: Codable, Identifiable {
  public let id: Tagged<Self, UUID>
  public let blurb: String
  public let cloudflareVideoID: Cloudflare.Video.ID?
  public let createdAt: Date
  public let description: String
  public let duration: Seconds<Int>?
  public let isLive: Bool
  public let posterURL: String
  public let scheduledAt: Date?
  public let title: String
  public let transcript: String?
  public let youtubeVideoID: String

  public init(
    id: ID,
    blurb: String = "",
    cloudflareVideoID: Cloudflare.Video.ID? = nil,
    createdAt: Date = Date(timeIntervalSince1970: 0),
    description: String = "",
    duration: Seconds<Int>? = nil,
    isLive: Bool = false,
    posterURL: String = "",
    scheduledAt: Date? = nil,
    title: String = "",
    transcript: String? = nil,
    youtubeVideoID: String = ""
  ) {
    self.id = id
    self.blurb = blurb
    self.cloudflareVideoID = cloudflareVideoID
    self.createdAt = createdAt
    self.description = description
    self.duration = duration
    self.isLive = isLive
    self.posterURL = posterURL
    self.scheduledAt = scheduledAt
    self.title = title
    self.transcript = transcript
    self.youtubeVideoID = youtubeVideoID
  }

  public var isArchived: Bool {
    cloudflareVideoID != nil
  }

  public enum CodingKeys: String, CodingKey {
    case id
    case blurb
    case cloudflareVideoID = "cloudflare_video_id"
    case createdAt = "created_at"
    case description
    case duration
    case isLive = "is_live"
    case posterURL = "poster_url"
    case scheduledAt = "scheduled_at"
    case title
    case transcript
    case youtubeVideoID = "youtube_video_id"
  }
}
