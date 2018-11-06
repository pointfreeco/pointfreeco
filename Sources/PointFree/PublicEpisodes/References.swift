import Foundation

extension Episode.Reference {
  static let composableSetters = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen gave at the [Functional Swift Conference](http://funswiftconf.com) about functional setters if
you're looking for more material on the topic to reinforce the ideas.
""",
    link: "https://www.youtube.com/watch?v=I23AC09YnHo",
    publishedAt: Date(timeIntervalSince1970: 1506744000),
    title: "Composable Setters"
  )

  static let contravariance = Episode.Reference(
    author: "Julie Moronuki & Chris Martin",
    blurb: """
This article describes the ideas of contravariance using the Haskell language. In many ways exploring
functional programming concepts in Haskell is "easier" because the syntax is sparse and allows you to
focus on just the core ideas.
""",
    link: "https://typeclasses.com/contravariance",
    publishedAt: nil,
    title: "Contravariance"
  )

  static let howToControlTheWorld = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen
""",
    link: "https://vimeo.com/291588126",
    publishedAt: Date(timeIntervalSince1970: 1537761600),
    title: "How to Control the World"
  )

  static let openSourcingSwiftHtml = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
TODO
""",
    link: "https://www.pointfree.co/blog/posts/16-open-sourcing-swift-html-a-type-safe-alternative-to-templating-languages-in-swift",
    publishedAt: Date(timeIntervalSince1970: 1541998800),
    title: "Open sourcing swift-html: A Type-Safe Alternative to Templating Languages in Swift"
  )

  static let overture = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
We open sourced the Overture library to give everyone access to functional compositions, even if you can't
bring operators into your codebase.
""",
    link: "https://github.com/pointfreeco/swift-overture",
    publishedAt: Date(timeIntervalSince1970: 1523246400),
    title: "Swift Overture"
  )

  static let playgroundDrivenDevelopmentAtKickstarter = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
TODO
""",
    link: "https://talk.objc.io/episodes/S01E51-playground-driven-development-at-kickstarter",
    publishedAt: Date(timeIntervalSince1970: 1495166400),
    title: "Playground Driven Development at Kickstarter"
  )

  static let playgroundDrivenDevelopmentFrenchKit = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
TODO
""",
    link: "https://www.youtube.com/watch?v=DrdxSNG-_DE",
    publishedAt: Date(timeIntervalSince1970: 1507262400),
    title: "Playground Driven Development"
  )

  static let protocolOrientedProgrammingIsNotASilverBullet = Episode.Reference(
    author: "Chris Eidhof",
    blurb: """
An old article detailing many of the pitfalls of Swift protocols, and how often you can simplify your code
by just using concrete datatypes and values. Chris walks the reader through an example of some networking
API library code, and shows how abstracting the library with protocols does not give us any tangible
benefits, but does increase the complexity of the code.
""",
    link: "http://chris.eidhof.nl/post/protocol-oriented-programming/",
    publishedAt: Date(timeIntervalSince1970: 1479963600),
    title: "Protocol Oriented Programming is Not a Silver Bullet"
  )

  static let scrapYourTypeClasses = Episode.Reference(
    author: "Gabriel Gonzalez",
    blurb: """
Haskell's notion of protocols are called "type classes," and the designers of Swift have often stated
that Swift's protocols took a lot of inspiration from Haskell. This means that Haskellers run into a lot
of the same problems we do when writing abstractions with type classes. In this article Gabriel Gonzalez
lays down the case for scrapping type classes and just using simple datatypes.
""",
    link: "http://www.haskellforall.com/2012/05/scrap-your-type-classes.html",
    publishedAt: Date(timeIntervalSince1970: 1335931200),
    title: "Scrap your type classes"
  )

  static let semanticEditorCombinators = Episode.Reference(
    author: "Conal Elliott",
    blurb: """
Conal Elliott describes the setter composition we explored in this episode from first principles, using
Haskell. In Haskell, the backwards composition operator `<<<` is written simply as a dot `.`, which means
that `g . f` is the composition of two functions where you apply `f` first and then `g`. This means if had
a nested value of type `([(A, B)], C)` and wanted to create a setter that transform the `B` part, you would
simply write it as `first.map.second`, and that looks eerily similar to how you would field access in
the OOP style!
""",
    link: "http://conal.net/blog/posts/semantic-editor-combinators",
    publishedAt: Date(timeIntervalSince1970: 1227502800),
    title: "Semantic editor combinators"
  )

  static let serverSideSwiftFromScratch = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
TODO
""",
    link: "https://www.skilled.io/u/swiftsummit/server-side-swift-from-scratch",
    publishedAt: Date(timeIntervalSince1970: 1509422400),
    title: "Server-Side Swift from Scratch"
  )

  static let someNewsAboutContramap = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
A few months after releasing our episode on [Contravariance](/episodes/ep14-contravariance) we decided to
rename this fundamental operation. The new name is more friendly, has a long history in mathematics,
and provides some nice intuitions when dealing with such a counterintuitive idea.
""",
    link: "https://www.pointfree.co/blog/posts/22-some-news-about-contramap",
    publishedAt: Date(timeIntervalSince1970: 1540785600),
    title: "Some news about contramap"
  )

  static let typeSafeFilePathsWithPhantomTypes = Episode.Reference(
    author: "Brandon Kase, Chris Eidhof, Florian Kugler",
    blurb: """
In this Swift Talk episode, Florian and special guess [Brandon Kase](https://twitter.com/bkase_) show how
to apply the ideas of phantom types to create a type safe API for dealing with file paths. We've used
phantom types in our episode on [Tagged](/episodes/ep12-tagged) to provide a compile-time mechanism for
distinguishing otherwise indistinguishable types.
""",
    link: "https://talk.objc.io/episodes/S01E71-type-safe-file-paths-with-phantom-types",
    publishedAt: Date(timeIntervalSince1970: 1507176000),
    title: "Type-Safe File Paths with Phantom Types"
  )

  static let valueOrientedProgramming = Episode.Reference(
    author: "Matt Diephouse",
    blurb: """
Matt gives another account of protocol-oriented programming gone awry, this time by breaking down the famous
WWDC talk where a shape library is designed using protocols. By rewriting the library without protocols Matt
ends up with something that can be tested without mocks, can be inspected at runtime, and more flexible.
""",
    link: "https://matt.diephouse.com/2018/08/value-oriented-programming/",
    publishedAt: Date(timeIntervalSince1970: 1532836800),
    title: "Value-Oriented Programming"
  )

}
