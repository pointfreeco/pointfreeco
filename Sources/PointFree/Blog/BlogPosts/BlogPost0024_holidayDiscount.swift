import Foundation

let post0024_holidayDiscount = BlogPost(
  author: .stephen,
  blurb: """
We're rounding out 2018 with some of our favorite episodes, and giving out a rare special: 30% savings
on a Point-Free subscription.
""",
  contentBlocks: [
    .init(
      content: """
We launched on January 29 of this year, and so we've been live for just under a year. In that time we have
released 41 episodes with over 19 hours of [video](\(url(to: .home))), published 24
[blog posts](\(url(to: .blog(.index)))), had 57 thousand unique visitors, and
[open sourced](\(gitHubUrl(to: .organization))) 8 (!) libraries from the topics covered in our episodes.

We're really proud of everything we produced for 2018, and hope that 2019 will be even better. And if you're
not a subscriber, then keep reading and you'll find a rare special discount code for 30% off, good only for
a short period of time!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
## Episodes

todo

## Open Source

We open sourced many libraries from the content in our episodes, 8 libraries in total. Each of these libraries
aims to solve a single problem in the simplest way possible in order to minimize the cost of bringing
the dependency into your project.

---

### `swift-snapshot-testing`

Our [most recently](todo) open sourced library, [`swift-snapshot-testing`](todo), take snapshot testing to the
next level. It allows you to snapshot test any kind of data type into any kind of format. For example, you
can snapshot test `UIView`'s and `UIViewController`'s into an image format, which is typical of these
kinds of libraries, but you can also snapshot those objects into a textual format so that you can see the
whole view hiearchy.

The design of this library was covered in a whopping 9 episodes

* [Protocol Witnesses: Part 1](todo), [Part 2](todo)
* [Advanced Protocol Witnesses: Part 1](todo), [Part 2](todo)
* [Protocol-Oriented Library Design: Part 1](todo), [Part 2](todo)
* [Witness-Oriented Library Design](todo)
* [Async Snapshot Testing](todo)
* [A Tour of Snapshot Testing](todo) (free)

---

### `swift-html`

Server-side Swift is in its nascent stages, but there have been some promising developments in the field,
such as the [Swift NIO](todo) project. Currently the most popular way to render HTML pages in server-side
Swift is with templating languages, but there are a lot of [problems](todo) with templates. The
[`swift-html`](todo) library aims to remedy these problems by providing a first-class data type to represent
HTML and a way to render that data to an HTML string that can be sent to the browser.

The design of this library was covered in 4 episodes:

* [Domain Specific Languages: Part 1](todo), [Part 2](todo)
* [An HTML DSL](todo)
* [DSLs vs. Templating Languages](todo) (free)

---

### `swift-html-kitura`, `swift-html-vapor`

The two most popular server-side Swift frameworks are Kitura and Vapor, but both use templating languages
as the default way to render HTML. Luckily each framework gives a way to use your own view layer, and so
both [`swift-html-kitura`](todo) and [`swift-html-vapor`](todo) are small libraries to help you use our
`swift-html` library in either framework.

---

### `swift-overture`

Functional programming tends to make heavy use of custom operators, and this is because infix notation and
associativity are a powerful way of reducing clutter in an expression and exposing some really interesting
algebraic properties. But, it's not for everyone. So, we open sourced [`swift-overture`](todo) to be a
simple library that gives you access to lots of interesting function composition tools, without the use
of operators. We discussed this idea in the following episode:

* [Composition without Operators](todo)

---

### `swift-tagged`

todo

* [Tagged](todo)

---

### `swift-nonempty`

An adage of functional programmers is "make invalid states unrepresentable". This means that states of data
that shouldn't be allowed to happen should actually be provable by the compiler as being impossible. We
achieve this by using concepts from algebraic data types in order to chisel away the invalid values from
our types, and are hopefully only left with the valid states. Our [`swift-nonempty`](todo) library applies
these ideas to model a "non-empty collection" type, which allows you to transform any collection type into
a non-empty version of itself. We covered the design of this library in 4 episodes:

* [Algebraic Data Types](todo) (free)
* [Algebraic Data Types: Exponents](todo)
* [Algebraic Data Types: Generics and Recursion](todo)
* [NonEmpty](todo)

---

### `swift-validated`

todo

* [The Many Faces of Zip: Part 1](todo)
* [The Many Faces of Zip: Part 2](todo)
* [The Many Faces of Zip: Part 3](todo) (free)

---

## Here's to 2019!

todo: discount code
""",
      timestamp: nil,
      type: .paragraph
    )
    ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.",
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1544432400),
  title: "2018 Year-in-Review"
)
