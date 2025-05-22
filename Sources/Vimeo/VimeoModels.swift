import Foundation
import Tagged

public struct VideosEnvelope: Decodable, Equatable {
  public let data: [Video]
  public let page: Int
  public let paging: Paging
  public let perPage: Int
  public let total: Int

  public struct Paging: Decodable, Equatable {
    public let next: String?
    public let previous: String?
    public let first: String
    public let last: String
  }
}

public struct Video: Decodable, Equatable {
  public typealias ID = Tagged<Self, Int>

  public let createdTime: Date
  public let description: String?
  public let download: [Download]
  public let name: String
  public let pictures: Pictures
  public let privacy: Privacy
  public let type: VideoType

  public init(
    createdTime: Date,
    description: String?,
    download: [Download],
    name: String,
    pictures: Pictures,
    privacy: Privacy,
    type: VideoType
  ) {
    self.createdTime = createdTime
    self.description = description
    self.download = download
    self.name = name
    self.privacy = privacy
    self.pictures = pictures
    self.type = type
  }

  public struct Download: Decodable, Equatable {
    public let link: String
    public let rendition: Rendition

    public struct Rendition: Decodable, Equatable, RawRepresentable {
      public static let p1080 = Self(rawValue: "1080p")

      public let rawValue: String

      public init(rawValue: String) {
        self.rawValue = rawValue
      }
    }
  }

  public struct Pictures: Decodable, Equatable {
    public let baseLink: String

    public init(baseLink: String) {
      self.baseLink = baseLink
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
}
