import Foundation
import Prelude

public struct Episode {
  public private(set) var blurb: String
  public private(set) var codeSampleDirectory: String
  public private(set) var exercises: [Exercise]
  public private(set) var id: Id
  public private(set) var image: String
  public private(set) var length: Int
  public private(set) var permission: Permission
  public private(set) var publishedAt: Date
  public private(set) var sequence: Int
  public private(set) var sourcesFull: [String]
  public private(set) var sourcesTrailer: [String]
  public private(set) var title: String
  public private(set) var transcriptBlocks: [TranscriptBlock]

  public init(
    blurb: String,
    codeSampleDirectory: String,
    id: Id,
    exercises: [Exercise],
    image: String,
    length: Int,
    permission: Permission,
    publishedAt: Date,
    sequence: Int,
    sourcesFull: [String],
    sourcesTrailer: [String],
    title: String,
    transcriptBlocks: [TranscriptBlock]) {

    self.blurb = blurb
    self.codeSampleDirectory = codeSampleDirectory
    self.exercises = exercises
    self.id = id
    self.image = image
    self.length = length
    self.permission = permission
    self.publishedAt = publishedAt
    self.sequence = sequence
    self.sourcesFull = sourcesFull
    self.sourcesTrailer = sourcesTrailer
    self.title = title
    self.transcriptBlocks = transcriptBlocks
  }

  public typealias Id = Tagged<Episode, Int>

  public var slug: String {
    return "ep\(self.sequence)-\(PointFree.slug(for: self.title))"
  }

  public var subscriberOnly: Bool {
    switch self.permission {
    case .free:
      return false
    case let .freeDuring(dateRange):
      return !dateRange.contains(Current.date())
    case .subscriberOnly:
      return true
    }
  }

  public struct Exercise {
    public private(set) var body: String

    public init(body: String) {
      self.body = body
    }
  }

  public enum Permission {
    case free
    case freeDuring(Range<Date>)
    case subscriberOnly
  }

  public struct TranscriptBlock {
    public private(set) var content: String
    public private(set) var timestamp: Int?
    public private(set) var type: BlockType

    public init(content: String, timestamp: Int?, type: BlockType) {
      self.content = content
      self.timestamp = timestamp
      self.type = type
    }

    public enum BlockType: Equatable {
      case code(lang: CodeLang)
      case correction
      case image(src: String)
      case paragraph
      case title
      case video(poster: String, sources: [String])

      public enum CodeLang: Equatable {
        case html
        case other(String)
        case swift

        public var identifier: String {
          switch self {
          case .html:
            return "html"
          case let .other(other):
            return other
          case .swift:
            return "swift"
          }
        }
      }
    }
  }
}

public let typeSafeHtml = Episode(
  blurb:
  """
As server-side Swift becomes more popular and widely adopted, it will be important to re-examine some of the past “best-practices” of web frameworks to see how Swift’s type system can improve upon them.
""",
  codeSampleDirectory: "ep4-type-safe-html",
  id: 4,
  exercises: [],
  image: "https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/poster.jpg",
  length: 1380,
  permission: .subscriberOnly,
  publishedAt: Date(timeIntervalSince1970: 1_497_960_000),
  sequence: 4,
  sourcesFull: ["https://d1hf1soyumxcgv.cloudfront.net/0000-introduction/hls.m3u8"],
  sourcesTrailer: [],
  title: "Type-Safe HTML in Swift",
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
