import Foundation
import Prelude

public struct Episode {
  public private(set) var blurb: String
  public private(set) var codeSampleDirectory: String
  public private(set) var exercises: [Exercise]
  public private(set) var fullVideo: Video
  public private(set) var id: Id
  public private(set) var image: String
  public private(set) var itunesImage: String?
  public private(set) var length: Int
  public private(set) var permission: Permission
  public private(set) var publishedAt: Date
  public private(set) var references: [Reference] = []
  public private(set) var sequence: Int
  public private(set) var title: String
  public private(set) var trailerVideo: Video?
  public private(set) var transcriptBlocks: [TranscriptBlock]

  public struct Reference {
    public private(set) var author: String?
    public private(set) var blurb: String?
    public private(set) var link: String
    public private(set) var publishedAt: Date?
    public private(set) var title: String
  }

  public struct Video {
    public private(set) var bytesLength: Int // TODO: Tagged<Bytes, Int>?
    public private(set) var downloadUrl: String
    public private(set) var streamingSource: String
  }

  public init(
    blurb: String,
    codeSampleDirectory: String,
    exercises: [Exercise],
    fullVideo: Video,
    id: Id,
    image: String,
    itunesImage: String,
    length: Int,
    permission: Permission,
    publishedAt: Date,
    references: [Reference] = [],
    sequence: Int,
    title: String,
    trailerVideo: Video?,
    transcriptBlocks: [TranscriptBlock]) {

    self.blurb = blurb
    self.codeSampleDirectory = codeSampleDirectory
    self.exercises = exercises
    self.fullVideo = fullVideo
    self.id = id
    self.image = image
    self.itunesImage = itunesImage
    self.length = length
    self.permission = permission
    self.publishedAt = publishedAt
    self.references = references
    self.sequence = sequence
    self.title = title
    self.trailerVideo = trailerVideo
    self.transcriptBlocks = transcriptBlocks
  }

  public typealias Id = Tagged<Episode, Int>

  public var slug: String {
    return "ep\(self.sequence)-\(PointFree.slug(for: self.title))"
  }

  public var subscriberOnly: Bool {
    switch self.permission {
    case .free:
      return false
    case let .freeDuring(dateRange):
      return !dateRange.contains(Current.date())
    case .subscriberOnly:
      return true
    }
  }

  public var freeSince: Date? {
    switch self.permission {
    case .free:
      return self.publishedAt
    case let .freeDuring(dateRange):
      return dateRange.lowerBound
    case .subscriberOnly:
      return nil
    }
  }

  public struct Exercise {
    public private(set) var body: String

    public init(body: String) {
      self.body = body
    }
  }

  public enum Permission {
    case free
    case freeDuring(Range<Date>)
    case subscriberOnly
  }

  public struct TranscriptBlock {
    public private(set) var content: String
    public private(set) var timestamp: Int?
    public private(set) var type: BlockType

    public init(content: String, timestamp: Int?, type: BlockType) {
      self.content = content
      self.timestamp = timestamp
      self.type = type
    }

    public enum BlockType: Equatable {
      case code(lang: CodeLang)
      case correction
      case image(src: String)
      case paragraph
      case title
      case video(poster: String, sources: [String])

      public enum CodeLang: Equatable {
        case html
        case other(String)
        case swift

        public var identifier: String {
          switch self {
          case .html:
            return "html"
          case let .other(other):
            return other
          case .swift:
            return "swift"
          }
        }
      }
    }
  }
}
