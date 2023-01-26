import Foundation
import Tagged

// TODO: move to Models, or split VimeoClient into VimeoClient+VimeoClientLive
public struct VimeoVideo: Decodable, Equatable {
  public let created: Date
  public let description: String
  public let name: String

  public typealias ID = Tagged<Self, Int>

  public init(
    created: Date,
    description: String,
    name: String
  ) {
    self.created = created
    self.description = description
    self.name = name
  }

  enum CodingKeys: String, CodingKey {
    case created = "created_time"
    case description
    case name
  }
}
