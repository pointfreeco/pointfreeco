import Foundation
import Tagged

public struct BlogPost: Equatable {
  public var author: Author?
  public var blurb: String
  public var contentBlocks: [Episode.TranscriptBlock]
  public var coverImage: String?
  public var id: Id
  public var publishedAt: Date
  public var title: String

  public init(
    author: Author?,
    blurb: String,
    contentBlocks: [Episode.TranscriptBlock],
    coverImage: String?,
    id: Id,
    publishedAt: Date,
    title: String) {
    self.author = author
    self.blurb = blurb
    self.contentBlocks = contentBlocks
    self.coverImage = coverImage
    self.id = id
    self.publishedAt = publishedAt
    self.title = title
  }

  public typealias Id = Tagged<BlogPost, Int>

  public struct Video: Equatable {
    public var sources: [String]
  }

  public var slug: String {
    return "\(self.id)-\(Models.slug(for: self.title))"
  }

  public enum Author: Equatable {
    case brandon
    case pointfree
    case stephen
  }
}
