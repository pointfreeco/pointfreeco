import Foundation

public let post0071_ParserBuilders = BlogPost(
  author: .pointfree,
  blurb: """
Today we are releasing 0.5.0 of our swift-parsing library, which leverages result builders for creating complex parsers with a minimal amount of syntactic noise. Learn how in this week's blog post, and give the library a spin today!
""",
  contentBlocks: [
    .init(
      content: #"""
We are excited to release [0.5.0](https://github.com/pointfreeco/swift-parsing/releases/tag/0.5.0) of [swift-parsing](https://swiftpackageindex.com/pointfreeco/swift-parsing), our library for turning nebulous data into well-structured data, with a focus on composition, performance, and generality. This release brings a new level of ergonomics to the library by using Swift’s `@resultBuilder` machinery, allowing you to express complex parsers with a minimal amount of syntactic noise.

## Parsing before today

Up to today, the parsing library leveraged a method-chaining, fluent style of parsing by using `.take` and `.skip` operators for running one parser after another and choosing whether you want to keep a parser’s output or discard it. For example, suppose we wanted to parse a string of data representing users:

```swift
let input = """
  1,Blob,true
  2,Blob Jr.,false
  3,Blob Sr.,true
  """
```

And we wanted to parse that data into a more structured Swift data type, such as an array of user structs:

```swift
struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
}
```

We could construct a `User` parser from some of the parsers the library comes with by piecing them together using `.take` and `.skip`. For example, we can consume an integer from the beginning of the string, then consume a comma and discard its output using `.skip`, then consume everything up until the next comma (for the name) using `.take`, then consume a comma again, and then finally consume a boolean. Once the integer, string, and boolean have been extracted from the string we can `.map` on the parser to bundle it up into a `User` struct:

```swift
let user = Int.parser()
  .skip(",")
  .take(Prefix { $0 != "," })
  .skip(",")
  .take(Bool.parser())
  .map { User(id: $0, name: String($1), isAdmin: $2) }
```

And then finally we can use the the `Many` parser combinator for running the `user` parser as many times as possible in order to accumulate the users into an array:

```swift
let users = Many(user, separator: "\n")
```

Running this parser on the input string produces an array of users and consumes the entire input, leaving only an empty string:

```swift
users.parse(&input) // [User(id: 1, name: "Blob", admin: true), ...]
input // ""
```

## Parsing with builders

The introduction of `@resultBuilders` to the library does not fundamentally change how you approach your parsing problems, but it does improve the ergonomics and allow you to explore all new API design spaces that were previously impossible.

To parse in the parser builder style you simply start with the `Parse` parser as an entry point into builder syntax, and then list all of your parsers inside:

```swift
let user = Parse {
  Int.parser()
  ","
  Prefix { $0 != "," }
  ","
  Bool.parser()
}
```

This represents a parser that runs each parser from top to bottom, one after another, and then collects all the outputs into a tuple. You will notice that there is no `.take` and `.skip` noise in this parser, and that’s because the parser builders automatically figure out which parsers have `Void` output (such as the `","` parser), and automatically discards their values.

We could then `.map` on this parser to bundle the tuple of integer, string and boolean into a `User` struct:

```swift
let user = Parse {
  Int.parser()
  ","
  Prefix { $0 != "," }
  ","
  Bool.parser()
}
.map { User(id: $0, name: String($1), isAdmin: $2) }
```

Or even better we can move that transform to the `Parse` entry point to make it upfront and clear what we are trying to parse:

```swift
let user = Parse(User.init) {
  Int.parser()
  ","
  Prefix { $0 != "," }.map(String.init)
  ","
  Bool.parser()
}
```

Further, the `Many` parser combinator is now built with parser builders in mind, so specifying the element parser and separator parser can be done using builder syntax:

```swift
let users = Many {
  user
} separator: {
  "\n"
}
```

And everything works exactly as it did before:

```swift
users.parse(&input) // => [User(id: 1, name: "Blob", isAdmin: true), ...]
input // => ""
```

## Case study

The usage of `@resultBuilders` in our parsing library goes well beyond just simple ergonomic improvements. It also allows us to explore all new API designs that can make parsers simpler and more correct.

For example, in the library’s repo we have some demo parsers, one of which is a URL router. It is capable of turning nebulous URL requests into a well-structured enumeration of routes that are recognized by a client or server application:

```swift
enum AppRoute: Equatable {
  case home
  case contactUs
  case episodes
  case episode(id: Int)
  case episodeComments(id: Int)
}
```

Using custom parsers that work specifically on URL request data we can piece them together to form a complex parser that transforms requests into an enum value. It does so by chaining together many parsers using the `.orElse` operator, which allows you to run a bunch of parsers on an input and choose the first one that succeeds:

```swift
let router = Method("GET") // "/"
  .skip(PathEnd())
  .map { AppRoute.home }
  .orElse( // "/contact-us"
    Method("GET")
      .skip(Path("contact-us".utf8))
      .skip(PathEnd())
      .map { AppRoute.contactUs }
  )
  .orElse(   // "/episodes"
    Method("GET")
      .skip(Path("episodes".utf8))
      .skip(PathEnd())
      .map { AppRoute.episodes }
  )
  .orElse( // "/episodes/:id"
    Method("GET")
      .skip(Path("episodes".utf8))
      .take(Path(Int.parser()))
      .skip(PathEnd())
      .map(AppRoute.episode(id:))
  )
  .orElse( // "/episodes/:id/comments"
    Method("GET")
      .skip(Path("episodes".utf8))
      .take(Path(Int.parser()))
      .skip(Path("comments".utf8))
      .skip(PathEnd())
      .map(AppRoute.episodeComments(id:))
  )
```

There is a lot of noise in this parser, such as the repeated `.take` and `.skip`, but also `.orElse`. Parser builders help eliminate this:

```swift
let router = OneOf {
  // "/"
  Parse(AppRoute.home) {
    Method("GET")
    PathEnd()
  }

  // "/contact-us"
  Parse(AppRoute.contactUs) {
    Method("GET")
    Path("contact-us".utf8)
    PathEnd()
  }

  // "/episodes/:id"
  Parse(AppRoute.episodes) {
    Method("GET")
    Path("episodes".utf8)
    PathEnd()
  }

  // "/episodes/:id"
  Parse(AppRoute.episode(id:)) {
    Method("GET")
    Path("episodes".utf8)
    Path(Int.parser())
    PathEnd()
  }

  // "/episodes/:id/comments"
  Parse(AppRoute.episodeComments(id:)) {
    Method("GET")
    Path("episodes".utf8)
    Path(Int.parser())
    Path("comments".utf8)
    PathEnd()
  }
}
```

Now all routes are on the same indentation level, and it is easier to focus on each route.

But, there is still repeated noise since every single parser must specify `Method("GET")` and something called `PathEnd()`. The `Method` parser simply verifies that the incoming request has the correct HTTP method so that you don’t try something silly like fetching data when actually data is being posted to the server.

The `PathEnd` is also important, but subtler. It verifies that there is no more left to parse from the path of the URL. Without this parser an incoming request such as:

```swift
/episodes/42/comments?count=10
```

Would be recognized by a parser like this:

```swift
Parse {
  Method("GET")
  Path("episodes")
}
```

Even though clearly the incoming request is trying to access a deeper piece of content: the comments for a particular episode.

It is possible to cook up a domain-specific parser, just for routing URL requests, that bakes in the path end logic, and even defaults to a `GET` method if no method is specified. Using such a custom parser we can massively clean up the router:

```swift
let router = OneOf {
  // "/"
  Route(AppRoute.home)

  // "/contact-us"
  Route(AppRoute.contactUs) {
    Path("contact-us".utf8)
  }

  // "/episodes"
  Route(AppRoute.episodes) {
    Path("episodes".utf8)
  }

  // "/episodes/:id"
  Route(AppRoute.episode(id:)) {
    Path("episodes".utf8)
    Path(Int.parser())
  }

  // "/episodes/:id/comments"
  Route(AppRoute.episodeComments(id:)) {
    Path("episodes".utf8)
    Path(Int.parser())
    Path("comments".utf8)
  }
}
```

30 lines of router code has become 22 lines and everything is much easier to read.

## Try it today

We think this release of [swift-parsing](https://github.com/pointfreeco/swift-parsing) will make constructing parsers easier than ever, and hope you consider it for your parsing needs!
"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0071-parser-builders/poster.png",
  id: 71,
  publishedAt: Date(timeIntervalSince1970: 1643004000),
  title: "Introducing Parser Builders"
)
