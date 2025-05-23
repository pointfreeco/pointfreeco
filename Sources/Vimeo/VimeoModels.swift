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

  public let uri: String
  public let createdTime: Date
  public let description: String?
  public let download: [Download]
  public let name: String
  public let pictures: Pictures
  public let type: VideoType

  public init(
    uri: String,
    createdTime: Date,
    description: String?,
    download: [Download],
    name: String,
    pictures: Pictures,
    type: VideoType
  ) {
    self.uri = uri
    self.createdTime = createdTime
    self.description = description
    self.download = download
    self.name = name
    self.pictures = pictures
    self.type = type
  }

  public var id: Int {
    Int(uri.dropFirst(8)) ?? 0
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

  public enum VideoType: String, Decodable {
    case live
    case video
  }
}
