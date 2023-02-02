import Foundation
import Tagged

public struct VimeoVideo: Decodable, Equatable {
  public let created: Date
  public let description: String?
  public let name: String
  public let privacy: Privacy
  public let type: VideoType

  public typealias ID = Tagged<Self, Int>

  public struct Privacy: Decodable, Equatable {
    public let view: View?

    public init(view: View?) {
      self.view = view
    }

    public enum View: String, Decodable {
      case anybody
      case disable
    }
  }

  public enum VideoType: String, Decodable {
    case live
    case video
  }

  public init(
    created: Date,
    description: String?,
    name: String,
    privacy: Privacy,
    type: VideoType
  ) {
    self.created = created
    self.description = description
    self.name = name
    self.privacy = privacy
    self.type = type
  }

  enum CodingKeys: String, CodingKey {
    case created = "created_time"
    case description
    case name
    case privacy
    case type
  }
}
