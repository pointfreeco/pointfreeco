import Foundation
import Tagged

public struct Episode {
  public var blurb: String
  public var codeSampleDirectory: String
  public var exercises: [Exercise]
  public var fullVideo: Video
  public var id: Id
  public var image: String
  public var itunesImage: String?
  public var length: Int
  public var permission: Permission
  public var previousEpisodeInCollection: Id?
  public var publishedAt: Date
  public var references: [Reference] = []
  public var sequence: Int
  public var title: String
  public var trailerVideo: Video?
  public var transcriptBlocks: [TranscriptBlock]

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
    previousEpisodeInCollection: Id?,
    publishedAt: Date,
    references: [Reference] = [],
    sequence: Int,
    title: String,
    trailerVideo: Video?,
    transcriptBlocks: [TranscriptBlock]
    ) {
    self.blurb = blurb
    self.codeSampleDirectory = codeSampleDirectory
    self.exercises = exercises
    self.fullVideo = fullVideo
    self.id = id
    self.image = image
    self.itunesImage = itunesImage
    self.length = length
    self.permission = permission
    self.previousEpisodeInCollection = previousEpisodeInCollection
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

  public typealias Id = Tagged<Episode, Int>

  public struct Exercise {
    public var problem: String
    public var solution: String?

    public init(problem: String, solution: String? = nil) {
      self.problem = problem
      self.solution = solution
    }
  }

  public enum Permission: Equatable {
    case free
    case freeDuring(Range<Date>)
    case subscriberOnly
  }

  public struct Reference: Codable {
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

  public struct TranscriptBlock: Codable, Equatable {
    public var content: String
    public var timestamp: Int?
    public var type: BlockType

    public init(content: String, timestamp: Int?, type: BlockType) {
      self.content = content
      self.timestamp = timestamp
      self.type = type
    }

    public enum BlockType: Codable, Equatable {
      case code(lang: CodeLang)
      case correction
      case image(src: String, sizing: ImageSizing)
      case paragraph
      case title
      case video(poster: String, sources: [String])

      private enum CodingKeys: CodingKey {
        case lang
        case poster
        case sizing
        case sources
        case src
        case type
      }

      public func encode(to encoder: Encoder) throws {
        switch self {
        case let .code(lang):
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("code", forKey: .type)
          try container.encode(lang, forKey: .lang)
        case .correction:
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("correction", forKey: .type)
        case let .image(src, sizing):
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("image", forKey: .type)
          try container.encode(sizing, forKey: .sizing)
          try container.encode(src, forKey: .src)
        case .paragraph:
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("paragraph", forKey: .type)
        case .title:
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("title", forKey: .type)
        case let .video(poster, sources):
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode("video", forKey: .type)
          try container.encode(poster, forKey: .poster)
          try container.encode(sources, forKey: .sources)
        }
      }

      public init(from decoder: Decoder) throws {
        fatalError() // TODO
      }

      public static func image(src: String) -> BlockType {
        return .image(src: src, sizing: .fullWidth)
      }

      public enum ImageSizing: String, Codable {
        case fullWidth
        case inset
      }

      public struct CodeLang: Codable, Equatable {
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
  
  public struct Video: Codable{
    // TODO: Tagged<Bytes, Int>?
    public var bytesLength: Int
    public var downloadUrl: String
    public var streamingSource: String

    public init(
      bytesLength: Int,
      downloadUrl: String,
      streamingSource: String
      ) {
      self.bytesLength = bytesLength
      self.downloadUrl = downloadUrl
      self.streamingSource = streamingSource
    }
  }
}

func slug(for string: String) -> String {
  return string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}

func reference(
  forEpisode episode: Episode,
  additionalBlurb: String,
  episodeUrl: String
  ) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
    \(additionalBlurb)

    > \(episode.blurb)
    """,
    link: episodeUrl,
    publishedAt: episode.publishedAt,
    title: episode.title
  )
}
