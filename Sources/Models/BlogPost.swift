import Dependencies
import Foundation
import Tagged

public struct BlogPost: Equatable, Identifiable {
  public var alternateSlug: String?
  public var author: Author?
  public var blurb: String
  public var coverImage: String?
  public var hidden: Hidden
  public var hideFromSlackRSS: Bool
  public var id: Tagged<Self, Int>
  public var publishedAt: Date
  public var title: String

  public enum Hidden: Equatable {
    case no
    case noUntil(Date)
    case yes
    public func isCurrentlyHidden(date currentDate: Date) -> Bool {
      switch self {
      case .no:
        false
      case let .noUntil(date):
        currentDate >= date
      case .yes:
        true
      }
    }
  }

  public init(
    alternateSlug: String? = nil,
    author: Author?,
    blurb: String,
    coverImage: String?,
    hidden: Hidden = .no,
    hideFromSlackRSS: Bool = false,
    id: ID,
    publishedAt: Date,
    title: String
  ) {
    self.alternateSlug = alternateSlug
    self.author = author
    self.blurb = blurb
    self.coverImage = coverImage
    self.hidden = hidden
    self.hideFromSlackRSS = hideFromSlackRSS
    self.id = id
    self.publishedAt = publishedAt
    self.title = title
  }

  public struct Video: Equatable {
    public var sources: [String]
  }

  public var slug: String {
    return "\(id)-" + (alternateSlug ?? "\(Models.slug(for: title))")
  }

  public enum Author: Equatable {
    case brandon
    case pointfree
    case stephen
  }

  public var content: String? {
    guard
      let resource = Bundle.module.url(
        forResource: "Newsletter-\(id.rawValue)", withExtension: "md")
    else { return nil }
    return try? String(decoding: Data(contentsOf: resource), as: UTF8.self)
  }
}

extension BlogPost: TestDependencyKey {
  public static var testValue = {
    [
      BlogPost(
        author: nil,
        blurb: """
          This is the blurb to a mock blog post. This should just be short and to the point, using \
          only plain text, no markdown.
          """,
        coverImage: nil,
        id: 0,
        publishedAt: .init(timeIntervalSince1970: 1_523_872_623),
        title: "Mock Blog Post"
      )
    ]
  }
}

extension DependencyValues {
  public var blogPosts: () -> [BlogPost] {
    get { self[BlogPost.self] }
    set { self[BlogPost.self] = newValue }
  }
}
