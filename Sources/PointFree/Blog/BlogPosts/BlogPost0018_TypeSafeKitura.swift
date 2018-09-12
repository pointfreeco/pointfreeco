import Foundation

let post0018_typeSafeKitura = BlogPost(
  author: .stephen,
  blurb: """
Today we're releasing a [Kitura](https://www.kitura.io) plug-in for rendering type-safe HTML. It provides a Swift compile-time API to HTML that prevents many of the runtime errors and vulnerabilities of traditional templated HTML rendering.
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

> Today we're releasing a [Kitura](https://www.kitura.io) plug-in for rendering type-safe HTML. It provides a Swift compile-time API to HTML that prevents many of the runtime errors and vulnerabilities of traditional templated HTML rendering.

---

Traditional approaches to rendering HTML in Swift involve [templating languages](https://en.wikipedia.org/wiki/Template_processor). While templating languages popular and pragmatic for many runtime languages, Swift's type system gives us a mainstream opportunity to evaluate what it means to render HTML with a compiler that can encode what it means to _be_ HTML at the type level. We've taken this opportunity and open sourced [swift-html](https://github.com/pointfreeco/swift-html), a type-safe HTML DSL for the Swift programming language.

We wanted to make [swift-html](https://github.com/pointfreeco/swift-html) as easy to use as possible with existing server-side Swift solutions, so we're pleased to announce the release of [a Kitura plug-in](https://github.com/pointfreeco/swift-html-kitura) to make it as simple as possible to get started.

Once [swift-html-kitura](https://github.com/pointfreeco/swift-html-kitura) is [added to your project](https://github.com/pointfreeco/swift-html-kitura#installation), you can `import HtmlKituraSupport` and use the full range of [swift-html](https://github.com/pointfreeco/swift-html) functionality!

Merely pass the HTML document you want to render to `response.send`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import HtmlKituraSupport
import Kitura

let router = Router()

router.get("/") { request, response, next in
  response.send(h1(["Hello, type-safe HTML on Kitura!"]))
  next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Our plug-in will handle rendering and setting the response content-type for you.

Do you use [Kitura](https://www.kitura.io/) and want to give [swift-html](https://github.com/pointfreeco/swift-html) a try? [Click here](https://github.com/pointfreeco/swift-html-kitura) to get started!
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "", // TODO
  id: 18, // TODO
  publishedAt: .init(timeIntervalSince1970: 1536811200), 
  title: "Type-safe HTML with Kitura"
)
