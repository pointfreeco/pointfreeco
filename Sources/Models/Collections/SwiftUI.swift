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
          ),
        ],
        title: "State Management",
        whereToGoFromHere: #"""
After taking a high-level view of the tools SwiftUI provides for building applications, let's take a low-level view of one of its fundamental units: the Binding type. Bindings are crucial for providing communication between your data model and your views, and even come with some composable, transformable operations! We'll examine this tool with a bit more scrutiny to identify where it falls short and how we can improve it.
"""#
      ),

      .composableBindings,

      .swiftUIRedactions(title: "Redactions"),

      .swiftUIAnimations(title: "Animations"),

      .init(
        blurb: #"""
TODO: Navigation is a really, really complex topic, and it’s going to take us many episodes go deep into it. We will begin our journey by coming up with a precise definition of what “navigation” is, and by exploring a couple simpler forms of navigation.
"""#,
        coreLessons: [
          .init(episode: .ep160_navigationTabsAndAlerts),
          .init(episode: .ep161_navigationTabsAndAlerts),
          .init(episode: .ep162_navigationSheets),
          .init(episode: .ep163_navigationSheets),
        ],
        isFinished: false,
        related: [
          .init(
            blurb: #"""
A central theme of our series of episodes on SwiftUI navigation is "derived behavior." This is what one needs to do to peel off a small bit of behavior from a parent domain to hand down to a child domain. SwiftUI gives us some tools to accomplish this, but we can go further.
"""#,
            content: .section(.caseStudies, index: 3)
          ),
        ],
        title: "Navigation",
        whereToGoFromHere: nil
      ),
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
      )
    ],
    title: "Composable Bindings",
    whereToGoFromHere: #"""
Next we will explore another SwiftUI API: ”redacted views.” SwiftUI makes it easy to redact the contents of a view, but unfortunately has less to say about redacting its logic.
"""#
  )
}
