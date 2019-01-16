import Foundation
import Optics
import Prelude

extension Episode.Reference {
  static let bonMot = Episode.Reference(
    author: "Zev Eisenberg @ Raizlabs",
    blurb: """
BonMot is an open source library for providing a nicer API to creating attributed strings in Swift. We integrated our [snapshot testing library](http://github.com/pointfreeco/swift-snapshot-testing) into BonMot for an [episode](/episodes/ep41-a-tour-of-snapshot-testing) to show how easy it is to integrate, and how easy it is to create your own snapshot strategies from scratch.
""",
    link: "http://github.com/raizlabs/BonMot/",
    publishedAt: referenceDateFormatter.date(from: "2015-06-17"),
    title: "BonMot"
  )

  static let composableSetters = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen spoke about functional setters at the [Functional Swift Conference](http://funswiftconf.com) if
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

  static let se0235AddResultToTheStandardLibrary = Episode.Reference(
    author: nil,
    blurb: """
The Swift evolution review of the proposal to add a `Result` type to the standard library. It discussed many functional facets of the `Result` type, including which operators to include (including `map` and `flatMap`), and how they should be defined.
""",
    link: "https://forums.swift.org/t/se-0235-add-result-to-the-standard-library/17752",
    publishedAt: Date(timeIntervalSince1970: 1541610000),
    title: "SE-0235 - Add Result to the Standard Library"
  )

  static let howToControlTheWorld = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen gave a talk on our `Environment`-based approach to dependency injection at NSSpain 2018. He starts
with the basics and slowly builds up to controlling more and more complex dependencies.
""",
    link: "https://vimeo.com/291588126",
    publishedAt: Date(timeIntervalSince1970: 1537761600),
    title: "How to Control the World"
  )

  static let iosSnapshotTestCaseGithub = Episode.Reference(
    author: "Uber, previously Facebook",
    blurb: """
Facebook released a snapshot testing framework known as `FBSnapshotTestCase` back in 2013, and many in the
iOS community adopted it. The library gives you an API to assert snapshots of `UIView`'s that will take
a screenshot of your UI and compare it against a reference image in your repo. If a single pixel is off
it will fail the test. Since then Facebook has stopped maintaining it and transfered ownership to Uber.
""",
    link: "https://github.com/uber/ios-snapshot-test-case",
    publishedAt: nil,
    title: "uber/ios-snapshot-test-case"
  )

  static let introduceSequenceCompactMap = Episode.Reference(
    author: "Max Moiseev",
    blurb: """
A Swift evolution proposal to rename a particular overload of `flatMap` to `compactMap`. The overload in
question was subtly different from the `flatMap` that we are familiar with on arrays and optionals, and
was a cause of confusion for those new to functional terms.
""",
    link: "https://github.com/apple/swift-evolution/blob/master/proposals/0187-introduce-filtermap.md",
    publishedAt: Date(timeIntervalSince1970: 1509681600),
    title: "Introduce Sequence.compactMap(_:)"
  )

  static let openSourcingSwiftHtml = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
After developing the ideas of DSLs in a series of episodes (
[part 1](https://www.pointfree.co/episodes/ep26-domain-specific-languages-part-1) and
[part 2](https://www.pointfree.co/episodes/ep27-domain-specific-languages-part-2)), we open sourced
our own DSL library for constructing HTML in Swift. We use this library heavily for building every page
on this very website, and it unlocks a lot of wonderful transformations and opportunities for code reuse.
""",
    link: "https://www.pointfree.co/blog/posts/16-open-sourcing-swift-html-a-type-safe-alternative-to-templating-languages-in-swift",
    publishedAt: Date(timeIntervalSince1970: 1541998800),
    title: "Open sourcing swift-html: A Type-Safe Alternative to Templating Languages in Swift"
  )

  static let playgroundDrivenDevelopmentAtKickstarter = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
We pioneered playground driven development while we were at Kickstarter, where we replaced the majority of
our use for storyboards with playgrounds. It takes a little bit of work to get started, but once you do
it really pays dividends. In this Swift Talk episode, Brandon sits down with Chris Eidhof to show
the ins and outs of playground driven development.
""",
    link: "https://talk.objc.io/episodes/S01E51-playground-driven-development-at-kickstarter",
    publishedAt: Date(timeIntervalSince1970: 1495166400),
    title: "Playground Driven Development at Kickstarter"
  )

  static let playgroundDrivenDevelopmentFrenchKit = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
Brandon gave an in-depth talk on playground driven development at FrenchKit 2017. In this talk he shows
what it takes to get a codebase into shape for this style of development, and shows off some of the amazing
things you can do once you have it.
""",
    link: "https://www.youtube.com/watch?v=DrdxSNG-_DE",
    publishedAt: Date(timeIntervalSince1970: 1507262400),
    title: "Playground Driven Development"
  )

  static let pointfreeco = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
The entire codebase for this very site is completely written in Swift _and_ open source! Explore the code
by browsing it on GitHub, or join us for a tour of the codebase in a
[Point-Free episode](/episodes/ep22-a-tour-of-point-free).
""",
    link: "https://github.com/pointfreeco/pointfreeco",
    publishedAt: Date(timeIntervalSince1970: 1505620800),
    title: "PointFree.co Open Source"
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

  static let protocolOrientedProgrammingWwdc = Episode.Reference(
    author: "Apple",
    blurb: """
Apple's eponymous WWDC talk on protocol-oriented programming:

> At the heart of Swift's design are two incredibly powerful ideas: protocol-oriented programming and first class value semantics. Each of these concepts benefit predictability, performance, and productivity, but together they can change the way we think about programming. Find out how you can apply these ideas to improve the code you write.
""",
    link: "https://developer.apple.com/videos/play/wwdc2015/408/",
    publishedAt: referenceDateFormatter.date(from: "2015-06-16"),
    title: "Protocol-Oriented Programming in Swift"
  )

  static let railwayOrientedProgramming = Episode.Reference(
    author: "Scott Wlaschin",
    blurb: """
This talk explains a nice metaphor to understand how `flatMap` unlocks stateless error handling.

> When you build real world applications, you are not always on the "happy path". You must deal with validation, logging, network and service errors, and other annoyances. How do you manage all this within a functional paradigm, when you can't use exceptions, or do early returns, and when you have no stateful data?
>
> This talk will demonstrate a common approach to this challenge, using a fun and easy-to-understand "railway oriented programming" analogy. You'll come away with insight into a powerful technique that handles errors in an elegant way using a simple, self-documenting design.
""",
    link: "https://vimeo.com/97344498",
    publishedAt: referenceDateFormatter.date(from: "2014-06-04"),
    title: "Railway Oriented Programming — error handling in functional languages"
  )

  static let randomZalgoGenerator = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
We apply the ideas of composable randomness to build a random Zalgo generator, which is a way to apply
gitchy artifacts to a string by adding strange unicode characters to it. It shows that we can start with
very simple, small pieces and then compose them together to create a really complicated machine.
""",
    link: "https://www.pointfree.co/blog/posts/19-random-zalgo-generator",
    publishedAt: Date(timeIntervalSince1970: 1542690000),
    title: "Random Zalgo Generator"
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
Brandon gave this talk at Swift Summit 2017 to demonstrate how we approach writing websites in Swift.
He gives a description of many of the problems that we have to solve in server-side Swift, and shows how
with Swift's strong type system and a few ideas from functional programming we can create truly composable
and expressive solutions to these problems.
""",
    link: "https://www.skilled.io/u/swiftsummit/server-side-swift-from-scratch",
    publishedAt: Date(timeIntervalSince1970: 1509422400),
    title: "Server-Side Swift from Scratch"
  )

  static let snapshotTestingBlogPost = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen gave an overview of snapshot testing, its benefits, and how one may snapshot Swift data types, walking through a minimal implementation.
""",
    link: "https://www.stephencelis.com/2017/09/snapshot-testing-in-swift",
    publishedAt: Date(timeIntervalSince1970: 1504238400),
    title: "Snapshot Testing in Swift"
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

  static let structureAndInterpretationOfSwiftPrograms = Episode.Reference(
    author: "Colin Barrett",
    blurb: """
[Colin Barrett](https://twitter.com/cbarrett) discussed the problems of dependency injection, the upsides
of singletons, and introduced the `Environment` construct at [Functional Swift 2015](http://2015.funswiftconf.com).
This was the talk that first inspired us to test this construct at Kickstarter and refine it over the years and
many other code bases.
""",
    link: "https://www.youtube.com/watch?v=V-YvI83QdMs",
    publishedAt: Date(timeIntervalSince1970: 1450155600),
    title: "Structure and Interpretation of Swift Programs"
  )

  static let swiftNonEmpty = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
`NonEmpty` is one of our open source projects for expressing a type safe, compiler proven non-empty
collection of values.
""",
    link: "https://github.com/pointfreeco/swift-nonempty",
    publishedAt: Date(timeIntervalSince1970: 1532491200),
    title: "NonEmpty"
  )

  static let swiftOverture = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
We open sourced the Overture library to give everyone access to functional compositions, even if you can't
bring operators into your codebase.
""",
    link: "https://github.com/pointfreeco/swift-overture",
    publishedAt: Date(timeIntervalSince1970: 1523246400),
    title: "Swift Overture"
  )

  static let swiftSnapshotTesting = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
A delightful snapshot testing library that we designed over the course of many Point-Free episodes. It
allows you to snapshot any type into any format, comes with many snapshot strategies out of the box, and
allows you to define your own custom, domain-specific snapshot strategies for your types.
""",
    link: "https://github.com/pointfreeco/swift-snapshot-testing",
    publishedAt: referenceDateFormatter.date(from: "2018-12-03"),
    title: "pointfreeco/swift-snapshot-testing"
  )

  static let swiftTagged = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
`Tagged` is one of our open source projects for expressing a way to distinguish otherwise indistinguishable
types at compile time.
""",
    link: "https://github.com/pointfreeco/swift-tagged",
    publishedAt: Date(timeIntervalSince1970: 1523851200),
    title: "Tagged"
  )

  static let swiftValidated = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
`Validated` is one of our open source projects that provides a `Result`-like type, which supports a `zip`
operation. This means you can combine multiple validated values into a single one and accumulate all of
their errors.
""",
    link: "https://github.com/pointfreeco/swift-validated",
    publishedAt: Date(timeIntervalSince1970: 1534478400),
    title: "Validated"
  )

  static let taggedSecondsAndMilliseconds = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
In this blog post we use the [`Tagged`](/episodes/ep12-tagged) type to provide a type safe way for
interacting with seconds and milliseconds values. We are able to prove to ourselves that we do not misuse
or mix up these values at compile time by using the tagged wrappers.
""",
    link: "https://www.pointfree.co/blog/posts/6-tagged-seconds-and-milliseconds",
    publishedAt: Date(timeIntervalSince1970: 1531886400),
    title: "Tagged Seconds and Milliseconds"
  )

  static let theoremsForFree = Episode.Reference(
    author: "Philip Wadler",
    blurb: """
This famous paper describes "theorems for free", in which if you write down a generic function
signature, you can derive theorems that the function satisfies. This works in any language that has
parametric polymorphism, as Swift does.
""",
    link: "https://people.mpi-sws.org/~dreyer/tor/papers/wadler.pdf",
    publishedAt: Date(timeIntervalSince1970: 615268800),
    title: "Theorems for Free"
  )

  static let typeSafeFilePathsWithPhantomTypes = Episode.Reference(
    author: "Brandon Kase, Chris Eidhof, Florian Kugler",
    blurb: """
In this Swift Talk episode, Florian and special guest [Brandon Kase](https://twitter.com/bkase_) show how
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
ends up with something that can be tested without mocks, can be inspected at runtime, and is more flexible in
general.
""",
    link: "https://matt.diephouse.com/2018/08/value-oriented-programming/",
    publishedAt: Date(timeIntervalSince1970: 1532836800),
    title: "Value-Oriented Programming"
  )

}

private let referenceDateFormatter = DateFormatter()
  |> \.dateFormat .~ "yyyy-MM-dd"
