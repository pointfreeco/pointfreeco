import Foundation

public let post0037_2019YearInReview = BlogPost(
  author: .brandon,
  blurb: """
    Random number generators, parsers, SwiftUI, composable architecture and more! Join us for a review of everything we accomplished in 2019!
    """,
  contentBlocks: [
    .init(
      content: #"""
        It’s the end of the year [again](/blog/posts/25-2018-year-in-review), and we’re feeling nostalgic 😊. We’re really proud of everything we produced for 2019, so join us for a quick review of some of our favorite highlights.

        We are also offering [**30% off** the first year](/discounts/holiday-2019) for first-time subscribers. If you've been on the fence on whether or not to subscribe, [now](/discounts/holiday-2019) is the time!

        ## Episodes

        In 2018, we spread our attention across many important topics in functional programming so that we could get a firm foundation in the tools that functional thinking gives us. Things like [functions](/episodes/ep1-functions), [algebraic data types](/episodes/ep4-algebraic-data-types), [`map`](/episodes/ep13-the-many-faces-of-map), [contravariance](/episodes/ep14-contravariance), [`zip`](/episodes/ep23-the-many-faces-of-zip-part-1), [protocol witnesses](/episodes/ep33-protocol-witnesses-part-1) and more. This set the stage for 2019.

        This year we produced 45 episodes (12 of them free!) for a total of 19 hours of video, and we focused on fewer topics and spent more time diving really deep into the concepts. We ended up leveraging almost everything we covered in 2018 in some shape or form. The basic units of composition from 2018 just kept appearing over and over again.

        Here’s a summary of the broad topics we explored:

        ### `FlatMap`

        We started the year out with a 5-part series on `flatMap`. Last year we saw that the [`map`](/episodes/ep13-the-many-faces-of-map) and [`zip`](/episodes/ep23-the-many-faces-of-zip-part-1) operations were powerful and universal, and that many types support these operations, not just arrays and optionals. The `map` operation allows us to access the value inside any generic context and apply a transformation to it. On the other hand, `zip` allows us to do something similar, except when you want to apply a transformation to many generic contexts at once.

        Those transformations are powerful, and allow us to express many things, but there are still things we want to do with certain types that `map` and `zip` alone cannot do. This is what motivates  `flatMap`! It is precisely the operation that allows us to chain together computations, whether it be computations on optionals, results, arrays or async values.

        - [Part 1](/episodes/ep42-the-many-faces-of-flat-map-part-1)
        - [Part 2](/episodes/ep43-the-many-faces-of-flat-map-part-2)
        - [Part 3](/episodes/ep44-the-many-faces-of-flat-map-part-3)
        - [Part 4](/episodes/ep45-the-many-faces-of-flat-map-part-4)
        - [Part 5](/episodes/ep46-the-many-faces-of-flat-map-part-5)

        ### Random Number Generators

        Last year we set the foundation for the atomic unit of randomness, `Gen`, from which more complex randomness can be derived ([part 1](/episodes/ep30-composable-randomness), [part 2](/episodes/ep31-decodable-randomness-part-1), [part 3](/episodes/ep32-decodable-randomness-part-2)), but this year we took it to the next level. By making a very small change to the definition of our `Gen` type, we are able to gain testability in our randomness, and we spent 2 🆓 episodes exploring how to make generative art with the `Gen` type:

        - Predictable Randomness
            - [Part 1](/episodes/ep47-predictable-randomness-part-1)
            - [Part 2](/episodes/ep48-predictable-randomness-part-2)
        - Generative Art
            - 🆓 [Part 1](/episodes/ep49-generative-art-part-1)
            - 🆓 [Part 2](/episodes/ep50-generative-art-part-2)

        ### Enum Properties

        Although structs and enums have first class treatment in Swift and are awesome to use, structs tend to have nicer ergonomics than enums. We explored what it would look like for enums to get many of the affordances that structs have, and we built a CLI tool (with SwiftSyntax!) to generate a friendlier API for enums.

        - [Structs 🤝 Enums](/episodes/ep51-structs-enums)
        - [Enum Properties](/episodes/ep52-enum-properties)
        - [Swift Syntax Enum Properties](/episodes/ep53-swift-syntax-enum-properties)
        - [Advanced Swift Syntax Enum Properties](/episodes/ep54-advanced-swift-syntax-enum-properties)
        - 🆓 [Swift Syntax Command Line Tool](/episodes/ep55-swift-syntax-command-line-tool)

        ### Parsers

        We explored what functional programming has to say about parsers, and it turns out it has quite a bit to say! After exploring various API’s for parsers that we interact with in the Apple ecosystem, we distilled the essence of parsing into a single function signature. That signature led us to discover many amazing composability properties, and we demonstrated how lots of tiny parsers could be pieced together to form very complex parsers.

        - What is a parser?
            - [Part 1](/episodes/ep56-what-is-a-parser-part-1)
            - [Part 2](/episodes/ep57-what-is-a-parser-part-2)
            - [Part 3](/episodes/ep58-what-is-a-parser-part-3)
        - Composable Parsing
            - [Map](/episodes/ep59-composable-parsing-map)
            - [FlatMap](/episodes/ep60-composable-parsing-flat-map)
            - [Zip](/episodes/ep61-composable-parsing-zip)
        - Parser Combinators
            - [Part 1](/episodes/ep62-parser-combinators-part-1)
            - [Part 2](/episodes/ep63-parser-combinators-part-2)
            - [Part 3](/episodes/ep64-parser-combinators-part-3)

        ### SwiftUI

        We were very excited when SwiftUI was announced at WWDC. Its core ideas are rooted in some concepts that are well-supported by functional programming, such as view functions and declarative programming, and we knew we’d have a lot to say about it.

        We started off by exploring what SwiftUI gives us out of the box so that we could understand what areas of application development it excels at, and where there is room for improvement. We released 3 free episodes showing how SwiftUI approaches the problems of state management, as well as a later free episode for how to do snapshot testing in a SwiftUI application.

        - SwiftUI and State Management
            - 🆓 [Part 1](/episodes/ep65-swiftui-and-state-management-part-1)
            - 🆓 [Part 2](/episodes/ep66-swiftui-and-state-management-part-2)
            - 🆓 [Part 3](/episodes/ep67-swiftui-and-state-management-part-3)
        - 🆓 [SwiftUI Snapshot Testing](/episodes/ep86-swiftui-snapshot-testing)

        ### Composable Architecture

        Although SwiftUI solves some of the most complex problems we face building applications, it doesn’t solve all of them. We turned to functional programming to develop an architecture that attempts to solve 5 precise problems that every application faces, and that we feel every architecture story must account for:

        1. How to model the architecture using value types
        1. How to break down large features into smaller pieces
        1. How to isolate parts of the app into their own modules so that they don’t depend on each other
        1. How to model side effects in the architecture
        1. And how to test the architecture.

        It took us a whopping 19 (‼️) episodes to accomplish this, and the results have been amazing.

        - Composable State Management
            - [Reducers](/episodes/ep68-composable-state-management-reducers)
            - [State Pullbacks](/episodes/ep69-composable-state-management-state-pullbacks)
            - [Action Pullbacks](/episodes/ep70-composable-state-management-action-pullbacks)
            - [Higher-Order Reducers](/episodes/ep71-composable-state-management-higher-order-reducers)
        - Modular State Management
            - [Reducers](/episodes/ep72-modular-state-management-reducers)
            - [View State](/episodes/ep73-modular-state-management-view-state)
            - [View Actions](/episodes/ep74-modular-state-management-view-actions)
            - [What’s the point?](/episodes/ep75-modular-state-management-the-point)
        - Effectful State Management
            - [Synchronous effects](/episodes/ep76-effectful-state-management-synchronous-effects)
            - [Unidirectional effects](/episodes/ep77-effectful-state-management-unidirectional-effects)
            - [Asynchronous effects](/episodes/ep78-effectful-state-management-asynchronous-effects)
            - [What’s the point?](/episodes/ep79-effectful-state-management-the-point)
        - The Combine Framework and Effects
            - 🆓 [Part 1](/episodes/ep80-the-combine-framework-and-effects-part-1)
            - 🆓 [Part 2](/episodes/ep81-the-combine-framework-and-effects-part-2)
        - Testable State Management
            - [Reducers](/episodes/ep82-testable-state-management-reducers)
            - [Effects](/episodes/ep83-testable-state-management-effects)
            - [Ergonomics](/episodes/ep84-testable-state-management-ergonomics)
            - [What’s the point?](/episodes/ep85-testable-state-management-the-point)
        - 🆓 [SwiftUI Snapshot Testing](/episodes/ep86-swiftui-snapshot-testing)

        <!--
        Open Source

        We weren’t quite as active with new open source projects as we were last year, but there was still some interesting activity.

        Enum properties

        We [open sourced](blog link) a command line tool for generating [“enum properties”](TODO) for all of the enums in your code base. This gives you struct-like access to the data inside your enums, which can be more ergonomic than using `switch`, `if case let` or `guard case let`.

        SnapshotTesting

        Our popular snapshot testing library

        Html
        -->

        ## 🎉 2020 🎉

        It was an incredible year, and thanks to all of our subscribers for supporting us and helping us create this content. We have a lot of great things planned for 2020: we have a few more things to discuss about the Composable Architecture, we have a few more advanced parser topics we want to cover, as well as some completely new topics and an exciting new project to announce!

        To celebrate the end of the year we are also offering [**30% off** the first year](/discounts/holiday-2019) for first-time subscribers. If you've been on the fence on whether or not to subscribe, [now](/discounts/holiday-2019) is the time!

        See you in 2020!
        """#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 37,
  publishedAt: Date(timeIntervalSince1970: 1_577_685_600),
  title: "2019 Year-in-review"
)
