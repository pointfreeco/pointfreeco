import Foundation

let postXYZW_typeSafeKitura = BlogPost(
  author: .stephen,
  blurb: """
Today we're releasing a [Kitura](https://www.kitura.io) plug-in for rendering type-safe HTML. It provides a Swift compile-time API to HTML that avoids many of the runtime errors and vulnerabilities of traditional templated HTML rendering.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "") // TODO
    ),

    .init(
      content: """
---

> Today we're releasing a [Kitura](https://www.kitura.io) plug-in for rendering type-safe HTML. It provides a Swift compile-time API to HTML that avoids many of the runtime errors and vulnerabilities of traditional templated HTML rendering.

---

Traditional approaches to rendering HTML in Swift involve [templating languages](https://en.wikipedia.org/wiki/Template_processor). While templating languages popular and pragmatic for many runtime languages, Swift's type system gives us a mainstream opportunity to evaluate what it means to render HTML with a compiler that can encode what it means to _be_ HTML at the type level.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """

""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "", // TODO
  id: 9999, // TODO
  publishedAt: .init(timeIntervalSince1970: 1536897600), // TODO
  title: "Type-safe HTML with Kitura"
)
