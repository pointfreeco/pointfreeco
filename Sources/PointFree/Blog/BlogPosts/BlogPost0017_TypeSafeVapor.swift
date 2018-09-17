import Foundation

let post0017_typeSafeVapor = BlogPost(
  author: .brandon,
  blurb: """
Today we're releasing a Vapor plug-in for rendering type-safe HTML. It provides a Swift compile-time API to
HTML that prevents many of the runtime errors and vulnerabilities of traditional templated HTML rendering.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0017-type-safe-html-with-vapor/poster.jpg")
    ),

    .init(
      content: """
---

> Today we're open sourcing a [plugin](\(gitHubUrl(to: .repo(.htmlVapor)))) for [Vapor](http://vapor.codes)
to render type-safe HTML. It provides a Swift compile-time API to HTML that prevents many of the runtime
errors and vulnerabilities of traditional templated HTML rendering.

---

We’ve spent the past 4 weeks discussing DSLs in Swift, and yesterday it all culminated with the open
sourcing of [swift-html](\(gitHubUrl(to: .repo(.html)))), our new Swift library for building type-safe,
extensible and transformable HTML documents. The design of this library has been battle-tested for the past
year, for it powers every single page on the [Point-Free](/) site. The entire code base of this site is
[open source](\(gitHubUrl(to: .organization))), we built it from scratch in the functional style, and we even
gave a tour of the site on a [recent episode](\(path(to: .episode(.left(ep22.slug))))).

However, we know that most people are not going to adopt all of our techniques in building a Swift web app
(at least not yet 😉), and so we want to make sure that the HTML view layer is accessible to everyone.
That's why today we are open sourcing a new [micro library](\(gitHubUrl(to: .repo(.htmlVapor)))) for bringing
our [swift-html](\(gitHubUrl(to: .repo(.html)))) library into any [Vapor](http://vapor.codes) web
application, one of the most popular server-side Swift frameworks available today!

## Vapor Leaf Templates

Typically a Vapor app renders HTML views through the use of the [Leaf](https://docs.vapor.codes/3.0/leaf/)
templating language. It's design is very similar to that of [Stencil](https://stencil.fuller.li/en/latest/),
which we discussed in our [episode](\(path(to: .episode(.left(ep29.slug))))) comparing DSLs to templating
languages. As an example, we could create a Leaf template by saving the following to a `.leaf` file:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
<ul>
  #for(user in users) {
    <li>#(user.name)</li>
  }
</ul>
""",
      timestamp: nil,
      type: .code(lang: .html)
    ),

    .init(
      content: """
And then from a route you could render this template with an array of users by doing the following:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
router.get("hello") { req in
  return try req.view()
    .render("UsersTemplate", [
      "users": [
        User(name: "Blob"),
        User(name: "Blob Jr."),
        User(name: "Blob Sr.")
      ]
    ]
  )
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This templating language is flexible, easy to use, and great as a starting point. However, it has all of the
same problems that we covered in our last [episode](\(path(to: .episode(.left(ep29.slug))))), including
lack of type-safety, no good tooling support (autocomplete, syntax highlighting, refactoring, debugging, etc.)
and it can be more rigid that what we are used to.

## Using swift-html with Vapor

Luckily Vapor makes it very easy to support other methods of rendering besides Leaf, and that is precisely
what our new library helps with. Simply add the following to your `Package.swift` file:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
.package(url: "https://github.com/pointfreeco/swift-html-vapor.git", from: "0.1.0"),
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And then you can return a `Node` value from a router endpoint and it will automatically be rendered!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import HtmlVaporSupport
import Vapor

let app = try Application()
let router = try app.make(Router.self)

router.get("hello") { _ in
  html([
    body([
      h1(["Type-safe Vapor HTML"]),
      p([\"\"\"
         This is a Vapor plugin that allows you to write type-safe,
         transformable, composable HTML views in a Vapor app!
         \"\"\"])
      ])
    ])
}

try app.run()
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And that's all there is to it!

## Conclusion

If you are building a Swift web app using Vapor we hope that you will consider using our
[swift-html-vapor](\(gitHubUrl(to: .repo(.htmlVapor)))) plugin as way to create your HTML views. We think
you'll be pleasantly surprised how nice it is to code up views in Swift and Xcode, and there are lots
of opportunities for code reuse and composability when building HTML views in this way.
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0017-type-safe-html-with-vapor/poster.jpg",
  id: 17,
  publishedAt: .init(timeIntervalSince1970: 1536818400),
  title: "Type-safe HTML with Vapor"
)
