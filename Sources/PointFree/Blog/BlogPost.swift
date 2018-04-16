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

let post0000_mock = BlogPost(
  blurb: """
This is the blurb to a mock blog post. This should just be short and to the point, using only plain
text, no markdown.
""",
  contentBlocks: [
    .init(
      content: """
      This is the main content of the blog post. Each paragraph can use markdown, but titles code snippets
      should be broken out into separate content blocks so that we can use the JS syntax highlighting
      library. For example, here is some code:
      """,
      timestamp: nil,
      type: .paragraph
    ),
    .init(
      content: """
      struct PredicateSet<A> {
        let contains: (A) -> Bool
      }

      func contramap<A, B>(_ f: @escaping (B) -> A) -> (PredicateSet<A>) -> PredicateSet<B> {
        return { set in PredicateSet(contains: f >>> set.contains) }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    .init(
      content: """
      Cool stuff right? 
      """,
      timestamp: nil,
      type: .paragraph
    ),
    ],
  coverImage: "",
  id: 0,
  publishedAt: .init(timeIntervalSince1970: 1_523_872_623),
  title: "Mock Blog Post",
  video: nil
)
