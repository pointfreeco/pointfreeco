import Foundation
import VimeoClient
import Tagged

public struct Clip: Codable {
  public let id: ID
  public let createdAt: Date
  public let description: String
  public let posterURL: URL
  public let title: String
  public let vimeoID: VimeoVideo.ID

  public typealias ID = Tagged<Self, UUID>

  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case description
    case posterURL = "poster_url"
    case title
    case vimeoID = "vimeo_id"
  }
}
