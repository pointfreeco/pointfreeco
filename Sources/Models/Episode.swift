import Foundation
import Tagged

public struct Episode {
  public typealias Id = Tagged<Episode, Int>

  public var blurb: String
  public var codeSampleDirectory: String
  public var exercises: [Exercise]
  public var fullVideo: Video
  public var id: Id
  public var image: String
  public var itunesImage: String?
  public var length: Int
  public var permission: Permission
  public var publishedAt: Date
  public var references: [Reference] = []
  public var sequence: Int
  public var title: String
  public var trailerVideo: Video?
  public var transcriptBlocks: [TranscriptBlock]

  public struct Reference {
    public var author: String?
    public var blurb: String?
    public var link: String
    public var publishedAt: Date?
    public var title: String

    public init(
      author: String?,
      blurb: String?,
      link: String,
      publishedAt: Date?,
      title: String
      ) {
      self.author = author
      self.blurb = blurb
      self.link = link
      self.publishedAt = publishedAt
      self.title = title
    }
  }

  public struct Video {
    // TODO: Tagged<Bytes, Int>?
    public var bytesLength: Int
    public var downloadUrl: String
    public var streamingSource: String

    public init(
      bytesLength: Int,
      downloadUrl: String,
      streamingSource: String) {
      self.bytesLength = bytesLength
      self.downloadUrl = downloadUrl
      self.streamingSource = streamingSource
    }
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

  public var slug: String {
    return "ep\(self.sequence)-\(Models.slug(for: self.title))"
  }

  public func isSubscriberOnly(currentDate: Date) -> Bool {
    switch self.permission {
    case .free:
      return false
    case let .freeDuring(dateRange):
      return !dateRange.contains(currentDate)
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
    public var problem: String
    public var solution: String?

    public init(problem: String, solution: String? = nil) {
      self.problem = problem
      self.solution = solution
    }
  }

  public enum Permission {
    case free
    case freeDuring(Range<Date>)
    case subscriberOnly
  }

  public struct TranscriptBlock: Equatable {
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
      case image(src: String, sizing: ImageSizing)
      case paragraph
      case title
      case video(poster: String, sources: [String])

      public static func image(src: String) -> BlockType {
        return .image(src: src, sizing: .fullWidth)
      }

      public enum ImageSizing {
        case fullWidth
        case inset
      }

      public struct CodeLang: Equatable {
        public let identifier: String

        public static let diff = CodeLang(identifier: "diff")
        public static let html = CodeLang(identifier: "html")
        public static let json = CodeLang(identifier: "json")
        public static let plainText = CodeLang(identifier: "txt")
        public static let ruby = CodeLang(identifier: "ruby")
        public static let shell = CodeLang(identifier: "sh")
        public static let sql = CodeLang(identifier: "sql")
        public static let swift = CodeLang(identifier: "swift")
      }
    }
  }
}

func slug(for string: String) -> String {
  return string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}
