import Foundation

extension Episode.Reference {

  public static let aLittleRespectForAnySequence = Episode.Reference(
    author: "Rob Napier",
    blurb: "This blog post explores the need for `AnySequence` in Swift as a pattern for working around some of the shortcomings of protocols in Swift.",
    link: "http://robnapier.net/erasure",
    publishedAt: Date(timeIntervalSince1970: 1438660800),
    title: "A Little Respect for AnySequence"
  )

  public static let allowErrorToConformToItself = Episode.Reference(
    author: "John McCall",
    blurb: "Swift 5.0 finally introduced the `Result` type to the standard library, and with it a patch that conforms `Error` to itself, allowing Result's `Failure` parameter to be constrained to `Error` in an ergonomic fashion. While this conformance is a special case, Swift may automatically conform certain protocols to themselves in the future.",
    link: "https://github.com/apple/swift/pull/20629",
    publishedAt: Date(timeIntervalSince1970: 1543986000),
    title: "Allow Error to conform to itself"
  )

  public static let bonMot = Episode.Reference(
    author: "Zev Eisenberg @ Raizlabs",
    blurb: """
BonMot is an open source library for providing a nicer API to creating attributed strings in Swift. We integrated our [snapshot testing library](http://github.com/pointfreeco/swift-snapshot-testing) into BonMot for an [episode](/episodes/ep41-a-tour-of-snapshot-testing) to show how easy it is to integrate, and how easy it is to create your own snapshot strategies from scratch.
""",
    link: "http://github.com/raizlabs/BonMot/",
    publishedAt: referenceDateFormatter.date(from: "2015-06-17"),
    title: "BonMot"
  )

  public static let composableSetters = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen spoke about functional setters at the [Functional Swift Conference](http://funswiftconf.com) if
you're looking for more material on the topic to reinforce the ideas.
""",
    link: "https://www.youtube.com/watch?v=I23AC09YnHo",
    publishedAt: Date(timeIntervalSince1970: 1506744000),
    title: "Composable Setters"
  )

  public static let contravariance = Episode.Reference(
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

  public static let difficultiesWithEfficientLargeFileParsing = Episode.Reference(
    author: "Ezekiel Elin et al.",
    blurb: """
This question on the Swift forums brings up an interesting discussion on how to best handle large files (hundreds of megabytes and millions of lines) in Swift. The thread contains lots of interesting tips on how to improve performance, and contains some hope of future standard library changes that may help too.
""",
    link: "https://forums.swift.org/t/difficulties-with-efficient-large-file-parsing/23660",
    publishedAt: referenceDateFormatter.date(from: "2019-04-25"),
    title: "Difficulties With Efficient Large File Parsing"
  )

  public static let elmHomepage = Episode.Reference(
    author: nil,
    blurb: """
Elm is both a pure functional language and framework for creating web applications in a declarative fashion. It was instrumental in pushing functional programming ideas into the mainstream, and demonstrating how an application could be represented by a simple pure function from state and actions to state.
""",
    link: "https://elm-lang.org",
    publishedAt: nil,
    title: "Elm: A delightful language for reliable webapps"
  )

  public static let everythingsAFunction = Episode.Reference(
    author: "Eitan Chatav",
    blurb: """
This short article explains how everything can be seen to be a function, even values and function application. Eitan coins the term `zurry` to describe the act of currying a zero-argument function.
""",
    link: "https://tangledw3b.wordpress.com/2013/01/18/cartesian-closed-categories/",
    publishedAt: referenceDateFormatter.date(from: "2013-01-18"),
    title: "Everything’s a Function."
  )

  public static let se0235AddResultToTheStandardLibrary = Episode.Reference(
    author: nil,
    blurb: """
The Swift evolution review of the proposal to add a `Result` type to the standard library. It discussed many functional facets of the `Result` type, including which operators to include (including `map` and `flatMap`), and how they should be defined.
""",
    link: "https://forums.swift.org/t/se-0235-add-result-to-the-standard-library/17752",
    publishedAt: Date(timeIntervalSince1970: 1541610000),
    title: "SE-0235 - Add Result to the Standard Library"
  )

  public static let se0249KeyPathExpressionsAsFunctions = Episode.Reference(
    author: "Stephen Celis & Greg Titus",
    blurb: """
A proposal has been accepted in the Swift evolution process that would allow key paths to be automatically promoted to getter functions. This would allow using key paths in much the same way you would use functions, but perhaps more succinctly: `users.map(\\.name)`.
""",
    link: "https://forums.swift.org/t/se-0249-key-path-expressions-as-functions/21780",
    publishedAt: Date(timeIntervalSince1970: 1553004000),
    title: "SE-0249 - Key Path Expressions as Functions"
  )

  public static let haskellUnderstandingMonadsState = Episode.Reference(
      author: "Wikibooks contributors",
      blurb: "A concise description of the state monad from the perspective of Haskell. Uses an example of a random dice roll as motiviation for how state can evolve in a program.",
      link: "https://en.wikibooks.org/wiki/Haskell/Understanding_monads/State",
      publishedAt: referenceDateFormatter.date(from: "2019-02-27"),
      title: "Haskell/Understanding monads/State"
  )

  public static let howToControlTheWorld = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen gave a talk on our `Environment`-based approach to dependency injection at NSSpain 2018. He starts
with the basics and slowly builds up to controlling more and more complex dependencies.
""",
    link: "https://vimeo.com/291588126",
    publishedAt: Date(timeIntervalSince1970: 1537761600),
    title: "How to Control the World"
  )

  public static let iosSnapshotTestCaseGithub = Episode.Reference(
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

  public static let insideSwiftUIAboutState = Episode.Reference(
    author: "kateinoigaku",
    blurb: """
Not a lot is currently known how `@State` really works under the hood. Sometimes it almost seems like magic! This article explores how `@State` might be implemented internally, and it seems that most likely SwiftUI is using the rich set of metadata available to the runtime (which the author of this article has also explored deeply [here](https://kateinoigakukun.hatenablog.com/entry/2019/03/22/184356)).
""",
    link: "https://kateinoigakukun.hatenablog.com/entry/2019/06/09/081831",
    publishedAt: referenceDateFormatter.date(from: "2019-06-09"),
    title: "Inside SwiftUI (About @State)"
  )

  public static let introduceSequenceCompactMap = Episode.Reference(
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

  public static let learningParserCombinatorsWithRust = Episode.Reference(
    author: "Bodil Stokke",
    blurb: """
A wonderful article that explains parser combinators from start to finish. The article assumes you are already familiar with Rust, but it is possible to look past the syntax and see that there are many shapes in the code that are similar to what we have covered in our episodes on parsers.
""",
    link: "https://bodil.lol/parser-combinators/",
    publishedAt: referenceDateFormatter.date(from: "2019-04-18"),
    title: "Learning Parser Combinators With Rust"
  )

  public static let ledgeMacAppParsingTechniques = Episode.Reference(
    author: "Chris Eidhof & Florian Kugler",
    blurb: """
  In this free episode of Swift talk, Chris and Florian discuss various techniques for parsing strings as a means to process a ledger file. It contains a good overview of various parsing techniques, including parser grammars.
  """,
    link: "https://talk.objc.io/episodes/S01E13-parsing-techniques",
    publishedAt: referenceDateFormatter.date(from: "2016-08-26"),
    title: "Ledger Mac App: Parsing Techniques"
  )

  public static let makingIllegalStatesUnrepresentable = Episode.Reference(
    author: "Ole Begemann",
    blurb: """
Ole discusses the concept of "illegal states" in data types, and how to leverage the type-system to make those states completely impossible to construct. His article was inspired by a mistake we made in our episode on algebraic data types, which shows just how subtle this problem can be!
""",
    link: "https://oleb.net/blog/2018/03/making-illegal-states-unrepresentable/",
    publishedAt: referenceDateFormatter.date(from: "2018-04-26"),
    title: "Making illegal states unrepresentable"
  )
  
  public static let nioRenameThenToFlatMap = Episode.Reference(
    author: "Apple",
    blurb: """
Apple's Swift NIO project has a type `EventLoopFuture` that can be thought of as a super charged version of the `Parallel` type we've used many times on this series. It comes with a method that has the same signature as `flatMap`, but originally it was named `then`. This pull-request renames the method to `flatMap`, which brings it inline with the naming for `Optional`, `Array` _and_ `Result` in the standard libary.
""",
    link: "https://github.com/apple/swift-nio/pull/760",
    publishedAt: referenceDateFormatter.date(from: "2019-01-21"),
    title: "rename ELF.then to ELF.flatMap"
  )

  public static let nsscannerNsHipster = Episode.Reference(
    author: "Nate Cook",
    blurb: """
  A nice, concise article covering the `Scanner` type, including a tip of how to extend the `Scanner` so that it is a bit more "Swifty". Take note that this article was written before `NSScanner` was renamed to just `Scanner` in Swift 3.
  """,
    link: "https://nshipster.com/nsscanner/",
    publishedAt: referenceDateFormatter.date(from: "2015-03-02"),
    title: "NSScanner"
  )

  public static let openSourcingSwiftHtml = Episode.Reference(
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

  public static let playgroundDrivenDevelopmentAtKickstarter = Episode.Reference(
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

  public static let playgroundDrivenDevelopmentFrenchKit = Episode.Reference(
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

  public static let pointfreeco = Episode.Reference(
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

  public static let protocolOrientedProgrammingIsNotASilverBullet = Episode.Reference(
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

  public static let protocolOrientedProgrammingWwdc = Episode.Reference(
    author: "Apple",
    blurb: """
Apple's eponymous WWDC talk on protocol-oriented programming:

> At the heart of Swift's design are two incredibly powerful ideas: protocol-oriented programming and first class value semantics. Each of these concepts benefit predictability, performance, and productivity, but together they can change the way we think about programming. Find out how you can apply these ideas to improve the code you write.
""",
    link: "https://developer.apple.com/videos/play/wwdc2015/408/",
    publishedAt: referenceDateFormatter.date(from: "2015-06-16"),
    title: "Protocol-Oriented Programming in Swift"
  )

  public static let railwayOrientedProgramming = Episode.Reference(
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

  public static let randomUnification = Episode.Reference(
    author: "Alejandro Alonso",
    blurb: """
This Swift Evolution proposal to create a unified random API, and a secure random API for all platforms, was accepted and implemented in Swift 4.2.
""",
    link: "https://github.com/apple/swift-evolution/blob/master/proposals/0202-random-unification.md",
    publishedAt: Date(timeIntervalSince1970: 1504889520),
    title: "SE-0202: Random Unification"
  )

  public static let randomZalgoGenerator = Episode.Reference(
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

  public static let reduceWithInout = Episode.Reference(
    author: "Chris Eidhof",
    blurb: """
The Swift standard library comes with two versions of `reduce`: one that takes accumulation functions of the form `(Result, Value) -> Result`, and another that accumulates with functions of the form `(inout Result, Value) -> Void`. Both versions are equivalent, but the latter can be more efficient when reducing into large data structures.
""",
    link: "https://forums.swift.org/t/reduce-with-inout/4897",
    publishedAt: referenceDateFormatter.date(from: "2017-01-16"),
    title: "Reduce with inout"
  )

  public static let reduxHomepage = Episode.Reference(
    author: nil,
    blurb: """
The idea of modeling an application's architecture on simple reducer functions was popularized by Redux, a state management library for React, which in turn took a lot of inspiration from [Elm](https://elm-lang.org).
""",
    link: "https://redux.js.org",
    publishedAt: nil,
    title: "Redux: A predictable state container for JavaScript apps."
  )

  public static let scannerAppleDocs = Episode.Reference(
    author: "Apple",
    blurb: """
  Official documentation for the `Scanner` type by Apple. Although the type hasn't (yet) been updated to take advantage of Swift's modern features, it is still a very powerful API that is capable of parsing complex text formats.
  """,
    link: "https://developer.apple.com/documentation/foundation/scanner",
    publishedAt: nil,
    title: "Scanner"
  )

  public static let scrapYourTypeClasses = Episode.Reference(
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

  public static let semanticEditorCombinators = Episode.Reference(
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

  public static let serverSideSwiftFromScratch = Episode.Reference(
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

  public static let snapshotTestingBlogPost = Episode.Reference(
    author: "Stephen Celis",
    blurb: """
Stephen gave an overview of snapshot testing, its benefits, and how one may snapshot Swift data types, walking through a minimal implementation.
""",
    link: "https://www.stephencelis.com/2017/09/snapshot-testing-in-swift",
    publishedAt: Date(timeIntervalSince1970: 1504238400),
    title: "Snapshot Testing in Swift"
  )

  public static let sparse = Episode.Reference(
    author: "John Patrick Morgan",
    blurb: """
A parser library built in Swift that uses many of the concepts we cover in our series of episodes on parsers.

> Sparse is a simple parser-combinator library written in Swift.
""",
    link: "https://github.com/johnpatrickmorgan/Sparse",
    publishedAt: referenceDateFormatter.date(from: "2017-01-12"),
    title: "Sparse"
  )

  public static let stateMonadTutorialForTheConfused = Episode.Reference(
    author: "Brandon Simmons",
    blurb: "The `Gen` type has a more general shape in the functional programming world as the `State` monad. In this post Brandon Simmons introduces the type and how it works compared to other flat-mappable types.",
    link: "http://brandon.si/code/the-state-monad-a-tutorial-for-the-confused/",
    publishedAt: Date(timeIntervalSince1970: 1256357760),
    title: "The State Monad: A Tutorial for the Confused?"
  )

  public static let someNewsAboutContramap = Episode.Reference(
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

  public static let structureAndInterpretationOfSwiftPrograms = Episode.Reference(
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

  public static let swiftNonEmpty = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
`NonEmpty` is one of our open source projects for expressing a type safe, compiler proven non-empty
collection of values.
""",
    link: "https://github.com/pointfreeco/swift-nonempty",
    publishedAt: Date(timeIntervalSince1970: 1532491200),
    title: "NonEmpty"
  )

  public static let swiftOverture = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
We open sourced the Overture library to give everyone access to functional compositions, even if you can't
bring operators into your codebase.
""",
    link: "https://github.com/pointfreeco/swift-overture",
    publishedAt: Date(timeIntervalSince1970: 1523246400),
    title: "Swift Overture"
  )

  public static let swiftPitchStringConsumption = Episode.Reference(
    author: "Michael Ilseman et al.",
    blurb: """
Swift contributor [Michael Ilseman](https://twitter.com/ilseman) lays out some potential future directions for Swift's string consumption API. This could be seen as a "Swiftier" way of doing what the `Scanner` type does today, but possibly even more powerful.
""",
    link: "https://forums.swift.org/t/string-consumption/21907",
    publishedAt: referenceDateFormatter.date(from: "2019-03-03"),
    title: "Swift Pitch: String Consumption"
  )

  public static let swiftPitchStringParsing = Episode.Reference(
    author: "Chris Eidhof et al.",
    blurb: """
Chris Eidhof strikes up a conversation on the Swift forums about how string parser helpers could be defined on `Substring` in the standard library. A lot of interesting ideas are shared on which is the correct type to define these helpers, and what is the correct API to expose to the user.
""",
    link: "https://forums.swift.org/t/string-parsing/10219",
    publishedAt: referenceDateFormatter.date(from: "2018-02-22"),
    title: "Swift Pitch: String Parsing"
  )
  public static let swiftSnapshotTesting = Episode.Reference(
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

  public static let swiftStringsAndSubstrings = Episode.Reference(
    author: "Chris Eidhof & Florian Kugler",
    blurb: """
In this free episode of Swift talk, Chris and Florian discuss how to efficiently use Swift strings, and in particular how to use the `Substring` type to prevent unnecessary copies of large strings.

> We write a simple CSV parser as an example demonstrating how to work with Swift's String and Substring types.
""",
    link: "https://talk.objc.io/episodes/S01E78-swift-strings-and-substrings",
    publishedAt: referenceDateFormatter.date(from: "2017-12-01"),
    title: "Swift Strings and Substrings"
  )
  public static let swiftTagged = Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
`Tagged` is one of our open source projects for expressing a way to distinguish otherwise indistinguishable
types at compile time.
""",
    link: "https://github.com/pointfreeco/swift-tagged",
    publishedAt: Date(timeIntervalSince1970: 1523851200),
    title: "Tagged"
  )

  public static let swiftUiTutorials = Episode.Reference(
    author: "Apple",
    blurb: "With the introduction of SwiftUI and Combine, Apple has released a set of high-quality, interactive tutorials to explore some of the new concepts.",
    link: "https://developer.apple.com/tutorials/swiftui/tutorials",
    publishedAt: nil,
    title: "SwiftUI Tutorials"
  )

  public static let swiftValidated = Episode.Reference(
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

  public static let parsec = Episode.Reference(
    author: "Daan Leijen, Paolo Martini, Antoine Latter",
    blurb: """
Parsec is one of the first and most widely used parsing libraries, built in Haskell. It's built on many of the same ideas we have covered in our series of episodes on parsers, but using some of Haskell's most powerful type-level features.
""",
    link: "http://hackage.haskell.org/package/parsec",
    publishedAt: nil,
    title: "parsec"
  )
  
  public static let parserCombinatorsInSwift = Episode.Reference(
    author: "Yasuhiro Inami",
    blurb: """
In the first ever [try! Swift](http://tryswift.co) conference, Yasuhiro Inami gives a broad overview of parsers and parser combinators, and shows how they can accomplish very complex parsing.

> Parser combinators are one of the most awesome functional techniques for parsing strings into trees, like constructing JSON. In this talk from try! Swift, Yasuhiro Inami describes how they work by combining small parsers together to form more complex and practical ones.
""",
    link: "https://academy.realm.io/posts/tryswift-yasuhiro-inami-parser-combinator/",
    publishedAt: referenceDateFormatter.date(from: "2016-05-02"),
    title: "Parser Combinators in Swift"
  )

  public static let taggedSecondsAndMilliseconds = Episode.Reference(
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

  public static let theoremsForFree = Episode.Reference(
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

  public static let typeErasureInSwift = Episode.Reference(
    author: "Mike Ash",
    blurb: "This edition of Friday Q&A shows how type erasure can manifest itself in many different ways. While you can wrap the functionality of a protocol in a concrete data type, as we explored in our series on [protocol witnesses](/episodes/ep33-protocol-witnesses-part-1), you can also use subclasses and plain ole functions.",
    link: "https://www.mikeash.com/pyblog/friday-qa-2017-12-08-type-erasure-in-swift.html",
    publishedAt: Date(timeIntervalSince1970: 1512709200),
    title: "Type Erasure in Swift"
  )
  
  public static let typeSafeFilePathsWithPhantomTypes = Episode.Reference(
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

  public static let unknownPleasures = Episode.Reference(
    author: "Wikipedia contributors",
    blurb: """
The artwork used as inspiration in this episode comes from the album cover from the band Joy Division.
""",
    link: "https://en.wikipedia.org/wiki/Unknown_Pleasures#Artwork_and_packaging",
    publishedAt: referenceDateFormatter.date(from: "2019-01-02"),
    title: "Unknown Pleasures – Artwork and packaging"
  )

  public static let valueOrientedProgramming = Episode.Reference(
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

  public static let wikipediaMonad = Episode.Reference(
    author: nil,
    blurb: """
The Wikipedia entry for monads.
""",
    link: "https://en.wikipedia.org/wiki/Monad_(functional_programming)",
    publishedAt: nil,
    title: "Monad (functional programming)"
  )

  public static let composableReducers = Episode.Reference(
    author: "Brandon Williams",
    blurb: """
A talk that Brandon gave at the 2017 Functional Swift conference in Berlin. The talk contains a brief account of many of the ideas covered in our series of episodes on "Composable State Management".
""",
    link: "https://www.youtube.com/watch?v=QOIigosUNGU",
    publishedAt: referenceDateFormatter.date(from: "2017-10-10"),
    title: "Composable Reducers"
  )

}

let referenceDateFormatter = { () -> DateFormatter in
  let df = DateFormatter()
  df.dateFormat = "yyyy-MM-dd"
  return df
}()
