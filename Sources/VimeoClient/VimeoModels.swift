import Foundation
import Tagged
import TaggedTime

public struct VimeoVideo: Decodable, Equatable {
  public let created: Date
  public let description: String
  public let duration: Seconds<Int>
  public let name: String
  public let pictures: Pictures
  public let privacy: Privacy
  public let type: VideoType
  public let uri: String

  public typealias ID = Tagged<Self, Int>

  public var id: ID? {
    uri.split(separator: "/").last
      .flatMap { Int(String($0)) }
      .map { ID(rawValue: $0) }
  }

  public struct Pictures: Decodable, Equatable {
    public var baseLink: String
    private enum CodingKeys: String, CodingKey {
      case baseLink = "base_link"
    }
  }

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
    description: String,
    duration: Seconds<Int>,
    name: String,
    pictures: Pictures,
    privacy: Privacy,
    type: VideoType,
    uri: String
  ) {
    self.created = created
    self.description = description
    self.duration = duration
    self.name = name
    self.pictures = pictures
    self.privacy = privacy
    self.type = type
    self.uri = uri
  }

  private enum CodingKeys: String, CodingKey {
    case created = "created_time"
    case description
    case duration
    case name
    case pictures
    case privacy
    case type
    case uri
  }
}
