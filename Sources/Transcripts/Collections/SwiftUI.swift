extension Episode.Collection {
  public static let swiftUI = Self(
    blurb: #"""
      SwiftUI is Apple's declarative successor to UIKit and AppKit, and provides a wonderful set of tools for building applications quickly and effectively. It also provides a wonderful opportunity to explore problems around architecture and composition.
      """#,
    sections: [
      .init(
        blurb: #"""
          We take a look at the tools SwiftUI provides to determine what architectural problems Apple attempts to solve, and which problems Apple leaves for us to solve ourselves.
          """#,
        coreLessons: [
          .init(episode: .ep65_swiftuiAndStateManagement_pt1),
          .init(episode: .ep66_swiftuiAndStateManagement_pt2),
          .init(episode: .ep67_swiftuiAndStateManagement_pt3),
        ],
        related: [
          .init(
            blurb: #"""
              These three episodes serve as the introduction to our much longer series on the Composable Architecture, in which we systematically aim to solve the problems we outline here.
              """#,
            content: .collection(.composableArchitecture)
          )
        ],
        title: "State Management",
        whereToGoFromHere: #"""
          After taking a high-level view of the tools SwiftUI provides for building applications, let's take a low-level view of one of its fundamental units: the Binding type. Bindings are crucial for providing communication between your data model and your views, and even come with some composable, transformable operations! We'll examine this tool with a bit more scrutiny to identify where it falls short and how we can improve it.
          """#
      ),

      .composableBindings,

      .swiftUIRedactions(title: "Redactions"),

      .swiftUIAnimations(title: "Animations"),

      .navigation,

      .modernSwiftUI,

      .observation,
    ],
    title: "SwiftUI"
  )
}

extension Episode.Collection.Section {
  public static let composableBindings = Self(
    blurb: #"""
      One of the fundamental units of SwiftUI state management is the Binding type, which connects your data model to your UI. It even comes with composable, transformable operations that make it really nice to use...with structs. Enums, unfortunately, are completely left out of the equation, which can lead us to model our domains in less than ideal ways. We will dissect the problem and build the tools that Apple leaves out of the framework.
      """#,
    coreLessons: [
      .init(episode: .ep107_composableSwiftUIBindings_pt1),
      .init(episode: .ep108_composableSwiftUIBindings_pt2),
      .init(episode: .ep109_composableSwiftUIBindings_pt3),
    ],
    related: [
      .init(
        blurb: #"""
          The `Binding` type is just one of many examples of Swift and its frameworks providing special treatment to structs while leaving enums behind, but structs are no more important than enums. In fact they are two sides of the same coin, both equally important in their own way. In this collection we explore more of these disparities and attempt to bridge the gaps.
          """#,
        content: .collection(.enumsAndStructs)
      ),
      .init(
        blurb: #"""
          Our search for a transformation operator on `Binding` is nothing new for Point-Free. We are _always_ on the lookout for ways to transform generic types into all new generic types because it unlocks all new capabilities from the type. We explore this concept in-depth in our collection discussing the many ways that `map`, `zip` and `flatMap` appear naturally in the code we write everyday.
          """#,
        content: .collection(.mapZipFlatMap)
      ),
    ],
    title: "Composable Bindings",
    whereToGoFromHere: #"""
      Next we will explore another SwiftUI API: ”redacted views.” SwiftUI makes it easy to redact the contents of a view, but unfortunately has less to say about redacting its logic.
      """#
  )

  public static let modernSwiftUI = Self(
    blurb: #"""
      What does it take to build a vanilla SwiftUI application with best, modern practices? We rebuild Apple's [Scrumdinger](https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger) code sample, a decently complex application that tackles real world problems, in a way that can be tested, modularized, and uses all of Swift's powerful domain modeling tools.
      """#,
    coreLessons: [
      .init(episode: .ep214_modernSwiftUI),
      .init(episode: .ep215_modernSwiftUI),
      .init(episode: .ep216_modernSwiftUI),
      .init(episode: .ep217_modernSwiftUI),
      .init(episode: .ep218_modernSwiftUI),
      .init(episode: .ep219_modernSwiftUI),
      .init(episode: .ep220_modernSwiftUI),
    ],
    related: [],
    title: "Modern SwiftUI",
    whereToGoFromHere: nil
  )

  public static let navigation = Self(
    blurb: #"""
      Navigation is a really, really complex topic, and it’s going to take us many episodes go deep into it. We will show at its heart, navigation is really a domain modeling problem, which means we need to discover tools that allow us to transform one domain into another. Once this is accomplished we will see that many seemingly disparate forms of navigation can be unified in a really amazing way.
      """#,
    coreLessons: [
      .init(episode: .ep160_navigationTabsAndAlerts),
      .init(episode: .ep161_navigationTabsAndAlerts),
      .init(episode: .ep162_navigationSheets),
      .init(episode: .ep163_navigationSheets),
      .init(episode: .ep164_navigationSheets),
      .init(episode: .ep165_navigationLinks),
      .init(episode: .ep166_navigationLinks),
      .init(episode: .ep167_navigationLinks),
      .init(episode: .ep168_navigationThePoint),
      .init(episode: .ep211_navStacks),
      .init(episode: .ep212_navStacks),
      .init(episode: .ep213_navStacks),
    ],
    related: [
      .init(
        blurb: #"""
          After building a demo application for showing off the various SwiftUI navigation APIs
          we completely modularized it so that features could be built in isolation without
          building the entire application.
          """#,
        content: .episodes([
          .ep171_modularization,
          .ep172_modularization,
        ])
      ),
      .init(
        blurb: #"""
          A central theme of our series of episodes on SwiftUI navigation is "derived behavior." This is what one needs to do to peel off a small bit of behavior from a parent domain to hand down to a child domain. SwiftUI gives us some tools to accomplish this, but we can go further.
          """#,
        content: .section(.caseStudies, index: 3)
      ),
    ],
    title: "Navigation",
    whereToGoFromHere:
      #"""
      We will tackle an even larger topic: building a SwiftUI application using modern, best practices.
      """#
  )

  public static let observation = Self(
    blurb: #"""
      With the release of Swift 5.9 we have access to a powerful and general purpose Observation
      framwork. It allows one to observe the inner works of a type from the outside and with a
      minimal amount of invasive code. However, it can seem quite mysterious at first, and so we
      de-mystify the new tools by discussing the past, present, future (and gotchas) of observation
      in Swift and Apple's platforms.
      """#,
    coreLessons: [
      .init(episode: .ep252_observation),
      .init(episode: .ep253_observation),
      .init(episode: .ep254_observation),
      .init(episode: .ep255_observation),
    ],
    related: [],
    title: "Observation",
    whereToGoFromHere: nil
  )
}
