import Foundation
import Tagged
import TaggedTime

public struct Episode: Equatable {
  public var blurb: String
  public var codeSampleDirectory: String
  public var exercises: [Exercise]
  private var _fullVideo: Video?
  public var id: Id
  public var image: String
  public var length: Seconds<Int>
  public var permission: Permission
  public var previousEpisodeInCollection: Id?
  public var publishedAt: Date
  public var references: [Reference]
  public var sequence: Sequence
  public var subtitle: String?
  public var title: String
  public var trailerVideo: Video
  private var _transcriptBlocks: [TranscriptBlock]?

  public init(
    blurb: String,
    codeSampleDirectory: String,
    exercises: [Exercise] = [],
    fullVideo: Video? = nil,
    id: Id,
    image: String,
    length: Seconds<Int>,
    permission: Permission,
    previousEpisodeInCollection: Id?,
    publishedAt: Date,
    references: [Reference] = [],
    sequence: Sequence,
    subtitle: String? = nil,
    title: String,
    trailerVideo: Video,
    transcriptBlocks: [TranscriptBlock]? = nil
  ) {
    self.blurb = blurb
    self.codeSampleDirectory = codeSampleDirectory
    self.exercises = exercises
    self._fullVideo = fullVideo
    self.id = id
    self.image = image
    self.length = length
    self.permission = permission
    self.previousEpisodeInCollection = previousEpisodeInCollection
    self.publishedAt = publishedAt
    self.references = references
    self.sequence = sequence
    self.subtitle = subtitle
    self.title = title
    self.trailerVideo = trailerVideo
    self._transcriptBlocks = transcriptBlocks
  }

  public var fullTitle: String {
    self.subtitle.map { "\(self.title): \($0)" } ?? self.title
  }

  public var fullVideo: Video {
    #if OSS
    return self._fullVideo ?? self.trailerVideo
    #else
    let video = self._fullVideo ?? Episode.allPrivateVideos[self.id]
    assert(video != nil, "Missing full video for episode #\(self.id) (\(self.title))!")
    return video!
    #endif
  }

  public var transcriptBlocks: [TranscriptBlock] {
    get {
      #if OSS
      return self._transcriptBlocks ?? []
      #else
      let transcripts = self._transcriptBlocks ?? Episode.allPrivateTranscripts[self.id]
      assert(transcripts != nil, "Missing private transcript for episode #\(self.id) (\(self.title))!")
      return transcripts!
      #endif
    }
    set {
      self._transcriptBlocks = newValue
    }
  }

  public var slug: String {
    return "ep\(self.sequence)-\(Models.slug(for: self.fullTitle))"
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
  public typealias Sequence = Tagged<(sequence: (), Episode), Int>

  public struct Collection: Equatable {
    public var blurb: String
    public var sections: [Section]
    public var title: String

    public init(
      blurb: String,
      sections: [Section],
      title: String
    ) {
      self.blurb = blurb
      self.sections = sections
      self.title = title
    }

    public init(
      section: Section
    ) {
      self.blurb = section.blurb
      self.sections = [section]
      self.title = section.title
    }

    public var length: Seconds<Int> {
      self.sections
        .flatMap { $0.coreLessons.map(\.episode.length) }
        .reduce(into: 0, +=)
    }

    public var slug: Slug {
      .init(rawValue: Models.slug(for: self.title))
    }

    public struct Section: Equatable {
      public var blurb: String
      public var coreLessons: [Lesson]
      public var related: [Related]
      public var title: String
      public var whereToGoFromHere: String?

      public init(
        blurb: String,
        coreLessons: [Lesson],
        related: [Related],
        title: String,
        whereToGoFromHere: String?
      ) {
        self.blurb = blurb
        self.coreLessons = coreLessons
        self.related = related
        self.title = title
        self.whereToGoFromHere = whereToGoFromHere
      }

      public var length: Seconds<Int> {
        self.coreLessons
          .map(\.episode.length)
          .reduce(into: 0, +=)
      }

      public var slug: Slug {
        .init(rawValue: Models.slug(for: self.title))
      }

      public struct Lesson: Equatable {
        public var episode: Episode

        public init(
          episode: Episode
        ) {
          self.episode = episode
        }
      }

      public struct Related: Equatable {
        public var blurb: String
        public var content: Content

        public init(
          blurb: String,
          content: Content
        ) {
          self.blurb = blurb
          self.content = content
        }

        public enum Content: Equatable {
          case episodes(@autoclosure () -> [Episode])
          case collections(@autoclosure () -> [Collection])
          case section(@autoclosure () -> Collection, index: Int)

          public static func episode(_ episode: @escaping @autoclosure() -> Episode) -> Content {
            .episodes([episode()])
          }

          public static func collection(_ collection: @escaping @autoclosure() -> Collection) -> Content {
            .collections([collection()])
          }

          public static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case let (.episodes(lhs), .episodes(rhs)):
              return lhs() == rhs()
            case let (.collections(lhs), .collections(rhs)):
              return lhs() == rhs()
            case let (.section(lhs, lhsIdx), .section(rhs, rhsIdx)):
              return lhs() == rhs() && lhsIdx == rhsIdx
            case (_, .episodes), (_, .collections), (_, .section):
              return false
            }
          }
        }
      }

      public typealias Slug = Tagged<Self, String>
    }

    public typealias Slug = Tagged<Self, String>
  }

  public struct Exercise: Equatable {
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

  public struct Reference: Codable, Equatable {
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
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: decoder.codingPath,
            debugDescription: "Unimplemented"
          )
        )
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
  
  public struct Video: Codable, Equatable {
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
    .replacingOccurrences(of: #"[\W]+"#, with: "-", options: .regularExpression)
    .replacingOccurrences(of: #"\A-|-\z"#, with: "", options: .regularExpression)
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
    title: episode.fullTitle
  )
}
