import Foundation
@testable import PointFree

extension Episode {
  public static let mock = paidEpisode
}

private let paidEpisode = Episode(
  blurb: """
  This is a short blurb to give a high-level overview of what the episode is about. It can only be plain
  text, no markdown allowed. Here is some more text just to have some filler.
  """,
  codeSampleDirectory: "ep1-proof-in-functions",
  id: 1,
  exercises: [
    .init(body: "This is an exercise.")
  ],
  image: "",
  length: 1380,
  permission: .subscriberOnly,
  publishedAt: Date(timeIntervalSince1970: 1_482_192_000),
  sequence: 1,
  sourcesFull: [""],
  sourcesTrailer: [""],
  title: "Proof in Functions",
  transcriptBlocks: [
    Episode.TranscriptBlock(
      content: "Introduction",
      timestamp: 0,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
      This is a `paragraph` transcript block. It just contains some markdown text. A paragraph block can
      also have a timestamp associated with it, which is rendered at the beginning of the text. Clicking
      that timestamp jumps the video to that spot.

      You can also break into new paragraphs in the markdown without creating a whole new paragraph block.
      However, you cannot associate a timestamp with this paragraph.
      """,
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      This is a correction for those time we make mistakes… it happens! We can use _markdown_ in this block,
      including code snippets: `map(f >>> g)`.
      """,
      timestamp: nil,
      type: .correction
    ),
    Episode.TranscriptBlock(
      content: """
      Here we have created a whole new transcript block so that we can associate a timestamp with it.
      """,
      timestamp: 30,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      It is also possible to create a `paragraph` block and use `nil` for the timestamp to omit the rendered
      time at the beginning of the text. That’s what we have done here.
      """,
      timestamp: nil,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Title Block",
      timestamp: 60,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
      That block above is called a `title` transcript block. It allows you to break up the transcript into
      chapters. All of the `title` blocks are gathered up and rendered as a “table of contents” under the
      episode video.

      Next up we are going to show off a `code` block. It allows you to render a multiline, syntax
      highlighted snippet of code:
      """,
      timestamp: 60,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
      infix operator |>

      func |> <A, B>(x: A, f: (A) -> B) -> B {
        return f(x)
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),
    Episode.TranscriptBlock(
      content: """
      You can write as much code as you want in that block, and you can specify the language of the code
      so that its syntax is highlighted nicely.
      """,
      timestamp: 90,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Another Title",
      timestamp: 120,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
      That was another title. See how the title create the “table of contents” under the video?

      Here's a block quote with a really long word inside so that we can make sure that word breaking is
      working how we expect:

      > Fatal error: ‘try!’ expression unexpectedly raised an error: Swift.DecodingError.typeMismatch(Swift.Dictionary<Swift.Dictionary<Swift.StringSwift.Dictionary<Swift.String, Any>>>, Swift.DecodingError.Context(codingPath: [_JSONKey(stringValue: “Index 0”, intValue: 0), CodingKeys(stringValue: “email”, intValue: nil)], debugDescription: “Expected to decode Dictionary<String, Any> but found a string/data instead.”, underlyingError: nil))
      """,
      timestamp: 120,
      type: .paragraph
    ),
  ]
)
