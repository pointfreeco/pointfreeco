import Foundation
import Prelude

public struct BlogPost {
  public typealias Id = Tagged<BlogPost, Int>

  public private(set) var blurb: String
  public private(set) var contentBlocks: [Episode.TranscriptBlock]
  public private(set) var coverImage: String
  public private(set) var id: Id
  public private(set) var publishedAt: Date
  public private(set) var title: String
  public private(set) var video: Video?

  public struct Video {
    public private(set) var sources: [String]
  }
}
