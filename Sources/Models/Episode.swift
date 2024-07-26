import CasePaths
import Dependencies
import Foundation
import Tagged
import TaggedTime

public struct Episode: Equatable, Identifiable {
  public var alternateSlug: String?
  public var blurb: String
  public var codeSampleDirectory: String?
  public var exercises: [Exercise]
  public var format: Format
  public private(set) var _fullVideo: Video?
  public var id: Tagged<Self, Int>
  public var image: String
  public var length: Seconds<Int>
  public var permission: Permission
  public var publishedAt: Date
  public var questions: [Question]
  public var references: [Reference]
  public var sequence: Sequence
  public var subtitle: String?
  public var title: String
  public var trailerVideo: Video

  public init(
    alternateSlug: String? = nil,
    blurb: String,
    codeSampleDirectory: String? = nil,
    exercises: [Exercise] = [],
    format: Format = .prerecorded,
    fullVideo: Video? = nil,
    id: ID,
    image: String? = nil,
    length: Seconds<Int>,
    permission: Permission,
    publishedAt: Date,
    questions: [Question] = [],
    references: [Reference] = [],
    sequence: Sequence,
    subtitle: String? = nil,
    title: String,
    trailerVideo: Video
  ) {
    self.alternateSlug = alternateSlug
    self.blurb = blurb
    self.codeSampleDirectory = codeSampleDirectory
    self.exercises = exercises
    self.format = format
    self._fullVideo = fullVideo
    self.id = id
    self.image =
      image
      ?? .init(
        format: "https://d3rccdn33rt8ze.cloudfront.net/episodes/%04d.jpeg", sequence.rawValue
      )
    self.length = length
    self.permission = permission
    self.publishedAt = publishedAt
    self.questions = questions
    self.references = references
    self.sequence = sequence
    self.subtitle = subtitle
    self.title = title
    self.trailerVideo = trailerVideo
  }

  public struct Question: Equatable {
    public var answer: String
    public var question: String
    public var timestamp: Int

    public init(answer: String, question: String, timestamp: Int) {
      self.answer = answer
      self.question = question
      self.timestamp = timestamp
    }
  }

  public var fullTitle: String {
    self.subtitle.map { "\(self.title): \($0)" } ?? self.title
  }

  public var slug: String {
    return "ep\(self.sequence)-" + (self.alternateSlug ?? "\(Models.slug(for: self.fullTitle))")
  }

  public func isSubscriberOnly(currentDate: Date, emergencyMode: Bool) -> Bool {
    guard !emergencyMode else { return false }

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

  public typealias Sequence = Tagged<(sequence: (), Self), Int>

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
        .flatMap { $0.coreLessons.map(\.duration) }
        .reduce(into: 0, +=)
    }

    public var numberOfEpisodes: Int {
      self.sections
        .map { $0.coreLessons.count }
        .reduce(into: 0, +=)
    }

    public var slug: Slug {
      .init(rawValue: Models.slug(for: self.title))
    }

    public struct Section: Equatable {
      public var alternateSlug: String?
      public var blurb: String
      public var coreLessons: [Lesson]
      public var isFinished: Bool
      public var isHidden: Bool
      public var related: [Related]
      public var title: String
      public var whereToGoFromHere: String?

      public init(
        alternateSlug: String? = nil,
        blurb: String,
        coreLessons: [Lesson],
        isFinished: Bool = true,
        isHidden: Bool = false,
        related: [Related],
        title: String,
        whereToGoFromHere: String?
      ) {
        self.alternateSlug = alternateSlug
        self.blurb = blurb
        self.coreLessons = coreLessons
        self.isFinished = isFinished
        self.isHidden = isHidden
        self.related = related
        self.title = title
        self.whereToGoFromHere = whereToGoFromHere
      }

      public var length: Seconds<Int> {
        self.coreLessons
          .map(\.duration)
          .reduce(into: 0, +=)
      }

      public var slug: Slug {
        self.alternateSlug.map(Slug.init(rawValue:)) ?? Slug(rawValue: Models.slug(for: self.title))
      }

      @CasePathable
      @dynamicMemberLookup
      public enum Lesson: Equatable {
        case clip(Clip)
        case episode(Episode)

        public init(
          clip: Clip
        ) {
          self = .clip(clip)
        }

        public init(
          episode: Episode
        ) {
          self = .episode(episode)
        }

        public var duration: Seconds<Int> {
          switch self {
          case let .clip(clip):
            clip.duration
          case let .episode(episode):
            episode.length
          }
        }

        public var publishedAt: Date {
          switch self {
          case .clip(let clip):
            clip.createdAt
          case .episode(let episode):
            episode.publishedAt
          }
        }

        public var title: String {
          switch self {
          case .clip(let clip):
            clip.title
          case .episode(let episode):
            episode.fullTitle
          }
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

          public static func episode(_ episode: @escaping @autoclosure () -> Episode) -> Content {
            .episodes([episode()])
          }

          public static func collection(_ collection: @escaping @autoclosure () -> Collection)
            -> Content
          {
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

  public enum Format {
    case prerecorded
    case livestream
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
      author: String? = nil,
      blurb: String? = nil,
      link: String,
      publishedAt: Date? = nil,
      title: String
    ) {
      self.author = author
      self.blurb = blurb
      self.link = link
      self.publishedAt = publishedAt
      self.title = title
    }
  }

  public struct Video: Codable, Equatable {
    public var bytesLength: Int
    public var vimeoId: Int
    public var downloadUrl: DownloadUrls

    public func downloadUrl(_ quality: Quality) -> String {
      switch (self.downloadUrl, quality) {
      case let (.s3(_, filename, _), .hd720), let (.s3(_, _, filename), .sd540):
        return "https://pointfreeco-episodes-processed.s3.amazonaws.com/\(filename).mp4"
      }
    }

    public var streamingSource: String {
      "https://player.vimeo.com/video/\(self.vimeoId)?pip=1"
    }

    public init(
      bytesLength: Int,
      downloadUrls: DownloadUrls,
      vimeoId: Int
    ) {
      self.bytesLength = bytesLength
      self.downloadUrl = downloadUrls
      self.vimeoId = vimeoId
    }

    public enum DownloadUrls: Codable, Equatable {
      case s3(hd1080: String, hd720: String, sd540: String)
    }

    public enum Quality {
      case hd720
      case sd540
    }
  }
}

func slug(for string: String) -> String {
  return
    string
    .lowercased()
    .replacingOccurrences(of: #"[\W]+"#, with: "-", options: .regularExpression)
    .replacingOccurrences(of: #"\A-|-\z"#, with: "", options: .regularExpression)
}

public func reference(
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

public func reference(
  forCollection collection: Episode.Collection,
  additionalBlurb: String,
  collectionUrl: String
) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(collection.blurb)
      """,
    link: collectionUrl,
    publishedAt: nil,
    title: "Collection: \(collection.title)"
  )
}

public func reference(
  forSection section: Episode.Collection.Section,
  additionalBlurb: String,
  sectionUrl: String
) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(section.blurb)
      """,
    link: sectionUrl,
    publishedAt: section.coreLessons.first?.publishedAt,
    title: "Collection: \(section.title)"
  )
}

extension Episode: TestDependencyKey {
  public static let testValue: () -> [Episode] = { [.subscriberOnly, .free] }
}

extension DependencyValues {
  public var episodes: () -> [Episode] {
    get { self[Episode.self] }
    set { self[Episode.self] = newValue }
  }
}
