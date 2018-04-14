import Foundation
import Prelude

struct Blog {
  public typealias Id = Tagged<Blog, Int>

  public private(set) var title: String
  public private(set) var publishedAt: Date
  public private(set) var blurb: String
  public private(set) var id: Id
  public private(set) var video: Video?
  public private(set) var content: String

  public struct Video {
    public private(set) var sources: [String]
  }
}
