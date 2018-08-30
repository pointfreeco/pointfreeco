import Foundation

let post0016_announcingSwiftHtml = BlogPost(
  author: .stephen,
  blurb: """
Today we are open sourcing our Swift HTML library //todo
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "") // todo
    ),

    .init(
      content: """
---

> Today we are open sourcing `swift-html`, an HTML DSL written in Swift for building... //todo

---

The entire [Point-Free](https://www.pointfree.co) website is built using server-side Swift, and the code
base has been [open source](https://www.github.com/pointfreeco/pointfreeco) from day one. When we set out
to build the site we wanted to rethink a lot of industry best practices when it came to how to build a
web framework, and we started with the view layer. So, today we are excited to announce an official release
of [`swift-html`](https://www.github.com/pointfreeco/swift-html), an HTML library written in
Swift and perfect for building HTML views for websites that are powered by Swift.

### HTML DSL

The library is written in the DSL style that we have been covering on Point-Free ([part 1](todo) and
[part 2](todo)), which means you construct HTML DOM by just building up plain Swift data types. It all
begins with the `Node` type, which is an `enum` that decides whether you want an element node (such as
`<header>`, `<div>`, etc.) or a text node. You can use it like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let doc = Node.el("header", [], [
  .el("h1", [], [.text("Point-Free")]),
  .el("p", [("id", "blurb")], [
    .text("Functional programming in Swift. "),
    .el("a", [("href", "/about")], [.text("Learn more")]),
    .text("!")
    ]),
  .el("img", [("src", "/logo.png"), ("width", "64"), ("height", "64")], []),
  ])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That may look kinda messy, but we have also employed a wide variety of Swift features to clean it up. Things
like `ExpressibleByStringLiteral`, free functions and function overloads can help us rewrite this document
like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
header([
  h1(["Point-Free"]),
  p([id("blurb")], [
    "Functional programming in Swift. ", a([href("/about")], ["Learn more"]), "!"
    ]),
  img([src("/logo.png"), width(64), height(64)]),
  ])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And now this looks pretty similar to how the HTML would look if coded by hand.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
### Rendering HTML



### Transforming HTML

Since we are modeling HTML as a DSL with simple Swift data types, it is very easy to do fun transformations
of a document. To cook up a function `(Node) -> Node` you just have to `switch` over the input node and
handle the element and text node cases. Doing so leads you into traversing the entire document and enabling
you to transform any part of the DOM tree.

As a silly example, we can write a function that reverses all of the nodes in a document:

todo: do reverse code

### Conclusion

todo

""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  // todo
  coverImage: "",
  id: 16,
  publishedAt: Date.distantFuture, // next weds: 1536127024
  title: "Announcing swift-html: A Swift HTML DSL" // todo
)




