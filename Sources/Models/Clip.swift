import Foundation
import VimeoClient
import Tagged
import TaggedTime

public struct Clip: Codable, Equatable {
  public let id: ID
  public let createdAt: Date
  public let description: String
  public let duration: Seconds<Int>
  public let posterURL: String
  public let title: String
  public let vimeoID: VimeoVideo.ID

  public typealias ID = Tagged<Self, UUID>

  public init(vimeoID: VimeoVideo.ID) {
    self.id = ID(rawValue: UUID())
    self.createdAt = Date(timeIntervalSince1970: 0)
    self.description = ""
    self.duration = 0
    self.posterURL = "image.png"
    self.title = ""
    self.vimeoID = vimeoID
  }

  public init(
    id: ID,
    createdAt: Date,
    description: String,
    duration: Seconds<Int>,
    posterURL: String,
    title: String,
    vimeoID: VimeoVideo.ID
  ) {
    self.id = id
    self.createdAt = createdAt
    self.description = description
    self.duration = duration
    self.posterURL = posterURL
    self.title = title
    self.vimeoID = vimeoID
  }

  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case description
    case duration
    case posterURL = "poster_url"
    case title
    case vimeoID = "vimeo_id"
  }
}
