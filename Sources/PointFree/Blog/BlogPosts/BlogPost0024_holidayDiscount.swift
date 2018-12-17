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
We launched on January 29 of this year, and next month are approaching our one year anniversay. In that time
we have released 41 episodes with over 19 hours of [video](\(url(to: .home))) (9 of which are free for all),
published 24 [blog posts](\(url(to: .blog(.index)))), served over 57,000 unique visitors, and
[open sourced](\(gitHubUrl(to: .organization))) 8 (!) libraries from the topics covered in our episodes!
We're really proud of everything we produced for 2018, so join us for a quick review of some of our favorite
highlights.
      
If you're not a subscriber, then keep reading… You'll find a rare special discount code for 30% off, good
only for a short period of time!

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
## Episodes

We produced 41 episodes this year, about one every 1.2 weeks. We covered a broad set of topics, from the
foundational ideas that somehow come up again-and-again, to the more practical, down-to-earth ideas
that you can immediately bring into your code base _today_. The balance of these two sides is important
because without the practical episodes it is hard to see the forest from the trees, and without the abstract
episodes we'd be stuck in an endless loop of adding superficial niceties to our code that don't
meaningfully improve it in a significant way.

Here's a small selection of some of our favorite episodes from the past year:

### Protocol Witnesses

We ended the year with a bang! We've spent _nine_ whole episodes rethinking the community best-practice of
"protocol-oriented programming". We started our series on "protocol witnesses" by showing how many basic
protocol features and functionality can be implemented using just concrete data types and functions. We even
showed that this translation is completely mechanical: that given any protocol, there is a clear path to
defining a data type equivalent ([part 1](/episodes/ep33-protocol-witnesses-part-1),
[part 2](/episodes/ep34-protocol-witnesses-part-2)).
      
We then dove into some of the more advanced features of protocols
([part 1](/episodes/ep35-advanced-protocol-witnesses-part-1),
[part 2](/episodes/ep36-advanced-protocol-witnesses-part-2)), some of which we only got recently, like
conditional conformance. We saw how these features manifest in the "protocol witness" world as plain ole
functions. With witnesses we we didn't have to wait. We were able to take advantage of conditional
conformance with the very first version of Swift.
      
We wrapped things up with four down-to-earth episodes where we tool a real-world library, abstracted it to
work with protocols ([part 1](/episodes/ep37-protocol-oriented-library-design-part-1),
[part 2](/episodes/ep38-protocol-oriented-library-design-part-2)), reabstracted it
[to work with witnesses](/episodes/ep39-witness-oriented-library-design), and finally
[fixed a problem](/episodes/ep40-async-functional-refactoring) with the libary that prevented it from working
on asynchronous values.

### Zip

We spent several episodes diving deep into the `zip` function. While many of us are aware of `zip` on arrays
and may have even reached for it on occasion, it may be surprising that `zip` appears on structures almost
as often as `map`! The implications are perhaps even more interesting. We saw that `zip` on optionals mirrors
optional sugar that we're used to with `if`-`let` binding. We saw that `zip` on the result type made us
question the structure of the result type itself. And we saw that `zip` on an asynchronous type was a
natural way to think about parallelism.

todo: links
todo: zip in non-empty?
todo: zip in overture
todo: zip in validation

### Tagged

* [Tagged](/episodes/ep12-tagged)

### UIKit Styling

In our [_3rd_](/episodes/ep3-uikit-styling-with-functions) of _41_ episodes we showed that composition was truly applicable to everyday code. It's still one of our most popular episodes to date!

There are many different ways to combine and reuse styling logic for iOS views, but we showed that plain ole functions
are the simplest solution.

TODO: finish

### Environment

We've had several episodes on managing dependencies using `Environment` thus far, and we have more to come. It's one
of the easiest ways to make untestable parts of your code base testable.
      
Stephen gave [a talk this year at NSSpain](https://vimeo.com/291588126)

TODO: finish

---

## Open Source

We knew we wanted to do as much of Point-Free in the open as possible, so this very site has
been [open source](\(gitHubUrl(to: .repo(.pointfreeco)))) from
[the very beginning](https://github.com/pointfreeco/pointfreeco/commit/548dc6bffcb01cb0e0ec07559e5d33dece24c686).
We built this site from first principles in a functional style, writing each component as open source along
the way.

Since our launch, we even open sourced libraries from the content in our episodes: 8 in total! And 4 of these
libraries has a home in the official
[Swift Source Compatibility Suite](https://github.com/apple/swift-source-compat-suite). Each of these
libraries aims to solve a single problem in the simplest way possible in order to minimize the cost of
bringing the dependency into your project.

Our open source work has accrued over 3,800 stars on GitHub! We're so thankful that the community has
expressed such an interest!

### [`swift-snapshot-testing`](\(gitHubUrl(to: .repo(.snapshotTesting))))

Our [most recently](/blog/posts/23-snapshottesting-1-0-delightful-swift-snapshot-testing) open sourced library, [`swift-snapshot-testing`](\(gitHubUrl(to: .repo(.snapshotTesting))), take snapshot testing to the
next level. It allows you to snapshot test any kind of data type into any kind of format. For example, you
can snapshot test `UIView`'s and `UIViewController`'s into an image format, which is typical of these
kinds of libraries, but you can also snapshot those objects into a textual format so that you can see the
whole view hiearchy.

The design of this library was covered in a whopping 8 episodes

* [Protocol Witnesses: Part 1](/episodes/ep33-protocol-witnesses-part-1)
* [Protocol Witnesses: Part 2](/episodes/ep34-protocol-witnesses-part-2)
* [Advanced Protocol Witnesses: Part 1](/episodes/ep35-advanced-protocol-witnesses-part-1)
* [Advanced Protocol Witnesses: Part 2](/episodes/ep36-advanced-protocol-witnesses-part-2)
* [Protocol-Oriented Library Design: Part 1](/episodes/ep37-protocol-oriented-library-design-part-1)
* [Protocol-Oriented Library Design: Part 2](/episodes/ep38-protocol-oriented-library-design-part-2)
* [Witness-Oriented Library Design](/episodes/ep39-witness-oriented-library-design)
* [Async Snapshot Testing](/episodes/ep40-async-functional-refactoring)

### [`swift-html`](\(gitHubUrl(to: .repo(.html))))

Server-side Swift is in its nascent stages, but there have been some promising developments in the field,
such as the [Swift NIO](http://github.com/apple/swift-nio) project. Currently the most popular way to render HTML pages in server-side
Swift is with templating languages, but there are a lot of [problems](/episodes/ep29-dsls-vs-templating-languages) with templates. We
[open sourced](/blog/posts/16-open-sourcing-swift-html-a-type-safe-alternative-to-templating-languages-in-swift) the
[`swift-html`](\(gitHubUrl(to: .repo(.html))) library to remedy these problems by providing a first-class data type to represent
HTML and a way to render that data to an HTML string that can be sent to the browser.

The design of this library was covered in 4 episodes:

* [Domain Specific Languages: Part 1](/episodes/ep26-domain-specific-languages-part-1)
* [Domain Specific Languages: Part 2](/episodes/ep27-domain-specific-languages-part-2)
* [An HTML DSL](/episodes/ep28-an-html-dsl)
* [DSLs vs. Templating Languages](/episodes/ep29-dsls-vs-templating-languages) 🆓

### [`swift-html-kitura`](\(gitHubUrl(to: .repo(.htmlKitura)))), [`swift-html-vapor`](\(gitHubUrl(to: .repo(.htmlVapor))))

The two most popular server-side Swift frameworks are Kitura and Vapor, but both use templating languages
as the default way to render HTML. Luckily each framework provides a way to use your own view layer, and so
both [`swift-html-kitura`](\(gitHubUrl(to: .repo(.htmlKitura)))
and [`swift-html-vapor`](\(gitHubUrl(to: .repo(.htmlVapor))) are small libraries to help you use our
[`swift-html`](\(gitHubUrl(to: .repo(.html))) library in either framework.

### [`swift-overture`](\(gitHubUrl(to: .repo(.overture))))

Functional programming tends to make heavy use of custom operators, and this is because infix notation and
associativity are a powerful way of reducing clutter in an expression and exposing some really interesting
algebraic properties. But, it's not for everyone. So, we open sourced
[`swift-overture`](\(gitHubUrl(to: .repo(.overture))) to be a simple library that gives you access to lots of
interesting function composition tools, without the use of operators. We discussed this idea in the following
episode:

* [Composition without Operators](/episodes/ep11-composition-without-operators)

### [`swift-tagged`](\(gitHubUrl(to: .repo(.tagged))))

The `Tagged` type provides a lightweight wrapper around any type so that you can safely distinguish between,
say, an `Int`-based user id and an `Int`-based blog post id. It uses a phantom generic and some powerful Swift
features, like conditional conformance, to make it easy to make your code safer.

* [Tagged](/episodes/ep12-tagged)

### [`swift-nonempty`](\(gitHubUrl(to: .repo(.nonempty))))

An adage of functional programmers is "make invalid states unrepresentable". This means that states of data
that shouldn't be allowed to happen should actually be provable by the compiler as being impossible. We
achieve this by using concepts from algebraic data types in order to chisel away the invalid values from
our types, and are hopefully only left with the valid states. Our [`swift-nonempty`](\(gitHubUrl(to: .repo(.nonempty))) library applies
these ideas to model a "non-empty collection" type, which allows you to transform any collection type into
a non-empty version of itself. We covered the design of this library in 4 episodes:

* [Algebraic Data Types](/episodes/ep4-algebraic-data-types) 🆓
* [Algebraic Data Types: Exponents](/episodes/ep9-algebraic-data-types-exponents)
* [Algebraic Data Types: Generics and Recursion](/episodes/ep19-algebraic-data-types-generics-and-recursion)
* [NonEmpty](/episodes/ep20-nonempty)

### [`swift-validated`](\(gitHubUrl(to: .repo(.validated))))

Swift error handling is built around `Optional`, `Result`, and `throws`. These constructs allow us to write a sequence
of failable instructions to Swift and return `nil`, `failure`, or `throw` an error to short-circuit things and
bail out of the happy path.

This correspondence between `Optional`, `Result`, and `throws` is interesting on its own, but we spent several episodes
exploring the `zip` function beyond its usualy definition on arrays, and we discovered something interesting: `zip`
gives us the unique ability to accumulate multiple errors when more than one input is invalid, a common thing we want
with form data, and something that short-circuiting `throws` can't do.

To make this functionality available to everyone, we open sourced [Validated](\(gitHubUrl(to: .repo(.validated))), a
Result-like type that can accumulate multiple errors.

* [The Many Faces of Zip: Part 1](/episodes/ep23-the-many-faces-of-zip-part-1)
* [The Many Faces of Zip: Part 2](/episodes/ep24-the-many-faces-of-zip-part-2)
* [The Many Faces of Zip: Part 3](/episodes/ep25-the-many-faces-of-zip-part-3) 🆓

---

## Here's to 2019!

To end 2018 on a high note we're offering a 30% discount to new subscribers for their first year. Just
[sign up](/discounts/point-free-2018) for an individual subscription plan and the discount will be applied
automatically. We hope you'll join us for all of the great material we have planned for 2019.

Until next time!
""",
      timestamp: nil,
      type: .paragraph
    )
    ],
  coverImage: Current.assets.emailHeaderImgSrc,
  id: 24,
  publishedAt: .init(timeIntervalSince1970: 1544518800),
  title: "2018 Year-in-Review"
)
