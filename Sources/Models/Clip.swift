import Foundation
import Tagged
import TaggedTime

public struct Clip: Codable, Equatable {
  public let id: ID
  public var blurb: String
  public let createdAt: Date
  public let description: String
  public let duration: Seconds<Int>
  public let order: Int
  public let posterURL: String
  public let title: String
  public let vimeoVideoID: VimeoVideo.ID

  public typealias ID = Tagged<Self, UUID>

  public init(
    vimeoVideoID: VimeoVideo.ID
  ) {
    self.id = ID(rawValue: UUID())
    self.blurb = ""
    self.createdAt = Date(timeIntervalSince1970: 0)
    self.description = ""
    self.duration = 0
    self.order = 0
    self.posterURL = "image.png"
    self.title = ""
    self.vimeoVideoID = vimeoVideoID
  }

  public init(
    id: ID,
    blurb: String,
    createdAt: Date,
    description: String,
    duration: Seconds<Int>,
    order: Int,
    posterURL: String,
    title: String,
    vimeoVideoID: VimeoVideo.ID
  ) {
    self.id = id
    self.blurb = blurb
    self.createdAt = createdAt
    self.description = description
    self.duration = duration
    self.order = order
    self.posterURL = posterURL
    self.title = title
    self.vimeoVideoID = vimeoVideoID
  }

  enum CodingKeys: String, CodingKey {
    case id
    case blurb
    case createdAt = "created_at"
    case description
    case duration
    case order
    case posterURL = "poster_url"
    case title
    case vimeoVideoID = "vimeo_video_id"
  }
}
