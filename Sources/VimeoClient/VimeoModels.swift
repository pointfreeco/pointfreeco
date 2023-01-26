import Foundation
import Tagged

// TODO: move to Models, or split VimeoClient into VimeoClient+VimeoClientLive
public struct VimeoVideo: Decodable, Equatable {
  public let created: Date
  public let description: String?
  public let name: String
  public let type: VideoType

  public typealias ID = Tagged<Self, Int>

  public enum VideoType: String, Decodable {
    case live
    case video
  }

  public init(
    created: Date,
    description: String?,
    name: String,
    type: VideoType
  ) {
    self.created = created
    self.description = description
    self.name = name
    self.type = type
  }

  enum CodingKeys: String, CodingKey {
    case created = "created_time"
    case description
    case name
    case type
  }
}
