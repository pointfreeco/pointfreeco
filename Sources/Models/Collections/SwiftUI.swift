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
      .init(
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
The Binding type is just one of many examples of Swift and its frameworks providing special treatment to structs while leaving enums behind, but structs are no more important than enums, and are in fact two sides of the same coin, both equally important in their own way. In this collection we explore more of these disparities and attempt to bridge the gaps.
"""#,
            content: .collection(.enumsAndStructs)
          ),
        ],
        title: "Composable Bindings",
        whereToGoFromHere: nil
      ),
    ],
    title: "SwiftUI"
  )
}
