import Foundation

let post0016_announcingSwiftHtml = BlogPost(
  author: .brandon,
  blurb: """
Today we are open sourcing a new library for building HTML documents in Swift. It's extensible, transformable,
type-safe, and provides many benefits over templating languages.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0016-announcing-swift-html/poster.jpg")
    ),

    .init(
      content: """
---

> Today we are [open sourcing](https://www.github.com/pointfreeco/swift-html) a new library for building HTML
documents in Swift. It's extensible, transformable, type-safe, and provides many benefits over templating
languages.

---

The entire [Point-Free](https://www.pointfree.co) website is built using server-side Swift, and the code
base has been [open source](https://www.github.com/pointfreeco/pointfreeco) from day one. When we set out
to build the site we wanted to rethink a lot of industry best practices when it came to how to build a
web framework, and we started with the view layer. So, today we are excited to announce an official release
of [`swift-html`](https://www.github.com/pointfreeco/swift-html), an HTML library written in
Swift and perfect for building HTML views for websites that are powered by Swift.

Before we show off the library, we must first show our motivation to create the library in the first place.
And that has to do with templating languages…

## Templating Languages

The current best practice for rendering HTML views is to use templating languages. Some popular examples
are Stencil, Mustache, Handlebars, and Leaf. These are languages that are embedded in a plain text document
and provide various tokens for interpolating values into the document, and some basic logical and looping
constructs. You can think of it as a fancier version of Swift's multi-line string literals with
interpolations, e.g. `"Hello \\(name)"`.

Templating languages are very flexible, easy to get started with, and used by many in the community.
However, they are not without their downsides:

### Stringy APIs

Templating languages are always stringly typed because you provide your template as a big ole string, and
then at runtime the values are interpolated and logic is executed. This means things we take for granted
in Swift, like the compiler catching typos and type mismatches, will go unnoticed until you run the code.

### Incomplete language

Templating languages are just that: programming languages. That means you should expect from these
languages all of the niceties you get from other fully-fledged languages like Swift. That includes syntax
highlighting, IDE autocompletion, static analysis, refactoring tools, breakpoints, debugger, and a whole
slew of features that make Swift powerful like let-bindings, conditionals, loops and more. However, the
reality is that no templating language supports all of these features.

### Rigid

Templating languages are rigid in that they do not allow the types of compositions and transformations
we are used to performing on data structures in Swift. It is not possible to succinctly traverse over the
documents you build, and inspect or transform the nodes you visit. This capability has many applications,
such as being able to pretty print or minify your HTML output, or writing a transformation that allows you
to inline a CSS stylesheet into an HTML node. There are entire worlds closed off to you due to how
templating languages work.

## HTML DSL

Now that we understand why we are searching for a better solution to HTML views than what templating
languages can offer us, what is the solution?

The solution is to use Swift, not a whole new programming language!

The library we are [open sourcing](https://www.github.com/pointfreeco/swift-html) today is written in the
DSL style that we have been covering on Point-Free ([part 1](/episodes/ep26-domain-specific-languages-part-1),
[part 2](/episodes/ep27-domain-specific-languages-part-2), [part 3](/episodes/ep28-an-html-dsl)), which means
you construct HTML documents by just building up plain Swift data types. It all begins with the `Node` type,
which is an `enum` that decides whether you want an element node (such as `<header>`, `<div>`, etc.) or a
text node. You can use it like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let doc = Node.element("header", [], [
  .element("h1", [], [.text("Point-Free")]),
  .element("p", [("id", "blurb")], [
    .text("Functional programming in Swift. "),
    .element("a", [("href", "/about")], [.text("Learn more")]),
    .text("!")
    ]),
  .element("img", [("src", "/logo.png"), ("width", "64"), ("height", "64")], []),
  ])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That may look kinda messy, but we can also employ a wide variety of Swift features to clean it up. Things
like `ExpressibleByStringLiteral`, free functions and function overloads can help us rewrite this document
like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let document = header([
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
And this looks pretty similar to how the HTML would look if coded by hand.

## Rendering HTML

Representing HTML documents as Swift types is only half the story. You still need to be able to render the
value out to a string so that it can actually be displayed in a browser. The library comes with a `render`
function to render any HTML document into a string:

""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
render(document)
// <header><h1>Point-Free</h1><p id="blurb">Functional programming in Swift. <a href="/about">Learn more</a>!</p><img src="logo.png" width="64" height="64"/></header>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
You will notice that this string isn't formatted in a particularly nice way. However, it's valid HTML and
is in its minimal form so takes up the least number of bytes. It's possible to create additional interpreters
of this DSL for pretty printing, and even markdown or plain text printing, but we'll release that soon
in another library.

## Type safety

Because we are embedding our DSL in Swift we can take advantage of some advanced Swift features to add an
extra layer of safety when constructing HTML documents. For a simple example, we can strengthen many HTML
APIs to force their true types rather than just relying on strings.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
img([src("cat.jpg"), width(400), height(300)])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Here the `src` attribute takes a string, but the `width` and `height` attributes take integers as it is
invalid to put anything else in those attributes.

For a more advanced example, `<li>` tags can only be placed inside `<ol>` and `<ul>` tags, and we can
represent this fact so that it's impossible to construct an invalid document:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
ul([
  li(["Cat"]),
  li(["Dog"]),
  li(["Rabbit"])
  ]) // ✅ Compiles!

div([
  li(["Cat"]),
  li(["Dog"]),
  li(["Rabbit"])
  ]) // 🛑 Compile error
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """

## Transforming HTML

Since we are modeling HTML as a DSL with simple Swift data types, it is very easy to do fun transformations
on documents. To cook up a function `(Node) -> Node` you just have to `switch` over the input node and
handle the various cases of the enum. Doing so leads you into recursively traversing the entire document and
enabling you to transform any part of the DOM tree.

As a silly example, we can write a function that redacts all of the text nodes of a document, i.e. we'll
replace every non-space character with "█". It might look something like this:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// First a helper function to redacting a raw string.
func redacted(string: String) -> String {
  return string
    .split(separator: " ")
    .map { String.init(repeating: "█", count: $0.count )}
    .joined(separator: " ")
}

// Then a function for redacting all of the comment, text
// and raw text nodes in a Node.
func redacted(node: Node) -> Node {
  switch node {
  case let .comment(string):
    return .comment(redacted(string: string))

  case .doctype:
    return node

  case let .element(tag, attrs, children):
    return .element(tag, attrs, children.map(redacted(node:)))

  case let .raw(string):
    return .raw(redacted(string: string))

  case let .text(string):
    return .text(redacted(string: string))
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now if we run our document through this function, and then render it, we will see a fully redacted HTML
fragment:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
render(redacted(node: document))

<header>
  <h1>██████████</h1>
  <p id="blurb">
    ██████████ ███████████ ██ ██████<a href="/about">█████ ████</a>█
  </p>
  <img src="/logo.png" width="64" height="64">
</header>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
It is absolutely striking that we were able to perform such a high level transformation in so few lines
of code, and better yet the code is very straightforward and readable.

And these kinds of transformations are not possible at all with templating languages. Instead, you have to
bring in _another_ dependency that can parse your HTML into a data structure so that you can perform the
transformation and then re-render it back out to a string. It may seem surprising, but it's actually quite
popular for people to that kind of round trip parsing and printing in practice.

## Conclusion

The DSL style of modeling HTML in Swift is very powerful, and has many advantages over the traditional
style of templating languages. In this article we have demonstrated numerous wonderful things the DSL
can accomplish, and how it can add safety and expressivity to HTML views built in Swift. However, this
is only the beginning. There is still so much more to say about the `Node` type.

We'll have to save that for another time, but until then please check out
[`swift-html`](https://www.github.com/pointfreeco/swift-html), our brand new open source library for
building HTML in Swift.
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0016-announcing-swift-html/poster.jpg",
  id: 16,
  publishedAt: Date(timeIntervalSince1970: 1536731824 + 60*60*2),
  title: "Open sourcing swift-html: A Type-Safe Alternative to Templating Languages in Swift" 
)
