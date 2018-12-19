import Foundation
import Optics
import Prelude
@testable import PointFree

extension Episode {
  public static let mock = subscriberOnlyEpisode

  public static let free = freeEpisode
  public static let subscriberOnly = subscriberOnlyEpisode
}

extension Episode.Reference {
  public static let mock = Episode.Reference(
    author: "Blob",
    blurb: "Blob uses functional programming to impress all of their friends.",
    link: "https://www.pointfree.co",
    publishedAt: Date(timeIntervalSince1970: 1234567890),
    title: "Functional Programming is Fun!"
  )
}

extension Episode.Exercise {
  public static let mock = Episode.Exercise(
    body: "Show that every simply-connected, 3-dimensional manifold is homeomorphic to the 3-sphere."
  )
}

private let subscriberOnlyEpisode = Episode(
  blurb: """
  This is a short blurb to give a high-level overview of what the episode is about. It can only be plain
  text, no markdown allowed. Here is some more text just to have some filler.
  """,
  codeSampleDirectory: "ep2-proof-in-functions",
  exercises: [
    .init(body: "This is an exercise.")
  ],
  fullVideo: .init(
    bytesLength: 500_000_000,
    downloadUrl: "https://s3.amazonaws.com/pointfreeco/video.mp4",
    streamingSource: "https://s3.amazonaws.com/pointfreeco/video.m3u8"
  ),
  id: 2,
  image: "",
  itunesImage: "https://s3.amazonaws.com/itunes.jpg",
  length: 1380,
  permission: .subscriberOnly,
  publishedAt: Date(timeIntervalSince1970: 1_482_192_000),
  sequence: 2,
  title: "Proof in Functions",
  trailerVideo: .init(
    bytesLength: 5_000_000,
    downloadUrl: "https://s3.amazonaws.com/pointfreeco/trailer.mp4",
    streamingSource: "https://s3.amazonaws.com/pointfreeco/trailer.m3u8"
  ),
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
     """,
      timestamp: 0,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Title",
      timestamp: 0,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
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

private let freeEpisode = Episode(
  blurb: """
As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them.
""",
  codeSampleDirectory: "ep1-type-safe-html",
  exercises: [],
  fullVideo: .init(
    bytesLength: 500_000_000,
    downloadUrl: "https://s3.amazonaws.com/pointfreeco/video.mp4",
    streamingSource: "https://s3.amazonaws.com/pointfreeco/video.m3u8"
  ),
  id: 1,
  image: "",
  itunesImage: "https://s3.amazonaws.com/itunes.jpg",
  length: 1380,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_497_960_000),
  sequence: 1,
  title: "Type-Safe HTML in Swift",
  trailerVideo: .init(
    bytesLength: 5_000_000,
    downloadUrl: "https://s3.amazonaws.com/pointfreeco/trailer.mp4",
    streamingSource: "https://s3.amazonaws.com/pointfreeco/trailer.m3u8"
  ),
  transcriptBlocks: [
    Episode.TranscriptBlock(
      content: """
As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them. One important job of a web server is to produce the HTML that will be served up to the browser. We claim that by using types and pure functions, we can enhance this part of the web request lifecycle.
""",
      timestamp: 1,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Template Languages",
      timestamp: 0,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
A popular method for generating HTML is using so-called “templating languages”, for example Mustache and Handlebars. There is even one written in Swift for use with the Vapor web framework called Leaf. These libraries ingest plain text that you provide and interpolate values into it using tokens. For example, here is a Mustache (and Handlebar) template:
""",
      timestamp: 2,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>{{title}}</h1>",
      timestamp: 3,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: "and here is a Leaf template:",
      timestamp: 4,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>#(title)</h1>",
      timestamp: 5,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
You can then render these templates by providing a dictionary of key/value pairs to interpolate, e.g. ["title": "Hello World!"], and then it will generate HTML that can be sent to the browser:
""",
      timestamp: 6,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "<h1>Hello World!</h1>",
      timestamp: 7,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
Templating languages will also provide simple constructs for injecting small amounts of logic into the templates. For example, an if statement can be used to conditionally show some elements:
""",
      timestamp: 8,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content:
      """
{{#if show}}
  <span>I’m here!</span>
{{/if}}
""",
      timestamp: 9,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content:
      """
#if(show) {
  <span>I’m here!</span>
}
""",
      timestamp: 10,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: """
The advantages of approaching views like this is that you get support for all that HTML has to offer out of the gate, and focus on building a small language for interpolating values into the templates. Some claim also that these templates lead to “logic-less” views, though confusingly they all support plenty of constructs for logic such as “if” statements and loops. A more accurate description might be “less logic” views since you are necessarily constricted by what logic you can use by the language.
""",
      timestamp: 11,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
The downsides, however, far outweigh the ups. Most errors in templating languages appear at runtime since they are usually not compiled. One can adopt a linting tool to find some (but not all) errors, but that is also an extra dependency that you need to manage. Some templating languages are compiled (like HAML), but even then the tooling is basic and can return confusing error messages. In general, it is on you to make these languages safe for you to deploy with confidence.
""",
      timestamp: 12,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
Furthermore, a templating language is just that: a language! It needs to be robust enough to handle what most users what to do with a language. That means it should support expressions, logical flow, loops, IDE autocomplete, IDE syntax highlighting, and more. It also needs to solve all of the new problems that appear, like escaping characters that are ambiguous with respect to HTML and the template language.
""",
      timestamp: 13,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
We claim that rather than embracing “logic-less” templates, and instead embracing pure functions and types, we will get a far more expressive, safer and composable view layer that can be compiled directly in Swift with no extra tooling or dependencies.
""",
      timestamp: 14,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Embedded Domain Specific Language",
      timestamp: 3,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
An alternative approach to views is using “embedded domain specific languages” (EDSLs). In this approach we use an existing programming language (e.g. Swift), to build a system of types and functions that models the structure of the domain we are modeling (e.g. HTML). Let’s take a fragment of HTML that we will use as inspiration to build in an EDSL:
""",
      timestamp: 15,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content:
      """
<header>
  <h1 id="welcome">Welcome!</h1>
  <p>
    Welcome to you, who has come here. See <a href="/more">more</a>.
  </p>
</header>
""",
      timestamp: 2,
      type: .code(lang: .html)
    ),
    Episode.TranscriptBlock(
      content: "Making the EDSL easier to use",
      timestamp: 7,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
Currently our EDSL is not super friendly to work with. It’s a bit more verbose than the plain HTML, and it’s hard to see the underlying HTML from looking at the code. Fortunately, these problems are fixed with a couple of helper functions and some nice features of Swift!
""",
      timestamp: 3,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: "Safer Attributes",
      timestamp: 9,
      type: .title
    ),
    Episode.TranscriptBlock(
      content: """
Right now our Attribute type is just a pair of strings representing the key and value. This allows for non-sensical pairs, such as width="foo". We can encode the fact that attributes require specific types of values into the type system, and get additional safety on this aspect.
""",
      timestamp: 4,
      type: .paragraph
    ),
    Episode.TranscriptBlock(
      content: """
We start by creating a type specifically to model keys that can be used in attributes. This type has two parts: the name of the key as a string (e.g. "id", "href", etc…), and the type of value this key is allowed to hold. There is a wonderful way to encode this latter requirement into the type system: you make the key’s type a generic parameter, but you don’t actually use it! Such a type is called a phantom type. We define our type as such:
""",
      timestamp: 6,
      type: .paragraph
    ),
    ]
)
