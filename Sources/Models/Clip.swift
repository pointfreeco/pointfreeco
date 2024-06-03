import Foundation
import VimeoClient
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
  public let vimeoID: VimeoVideo.ID

  public typealias ID = Tagged<Self, UUID>

  public init(
    id: ID,
    blurb: String,
    createdAt: Date,
    description: String,
    duration: Seconds<Int>,
    order: Int,
    posterURL: String,
    title: String,
    vimeoID: VimeoVideo.ID
  ) {
    self.id = id
    self.blurb = blurb
    self.createdAt = createdAt
    self.description = description
    self.duration = duration
    self.order = order
    self.posterURL = posterURL
    self.title = title
    self.vimeoID = vimeoID
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
    case vimeoID = "vimeo_id"
  }
}
