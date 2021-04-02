extension Episode.Collection {
  public static let caseStudies = Self(
    blurb: """
      The Composable Architecture can help build large, complex applications in a consistent, modular and testable manner, but it can still be difficult to figure out how to solve certain common problems. This case studies collection will analyze some common, real life problems and show how to approach them in the Composable Architecture.
      """,
    sections: [
      .swiftUIRedactions(),

      .init(
        blurb: """
          Forms and settings screens in applications display lots of editable data at once, but due to how the Composable Architecture is designed this can lead to some boilerplate. We show how to fix this deficiency and make the Composable Architecture as concise as vanilla SwiftUI applications.
          """,
        coreLessons: [
          .init(episode: .ep131_conciseForms),
          .init(episode: .ep132_conciseForms),
          .init(episode: .ep133_conciseForms),
          .init(episode: .ep134_conciseForms),
        ],
        related: [
          .init(
            blurb: """
              For more on the Composable Architecture, be sure to check out the entire collection \
              where we break down the problems of application architecture to build a solution \
              from first principles.
              """,
            content: .collections([
              .composableArchitecture
            ])
          )
        ],
        title: "Concise Forms",
        whereToGoFromHere: nil
      ),

      .swiftUIAnimations()
    ],
    title: "Case Studies"
  )
}

extension Episode.Collection.Section {
  public static func swiftUIRedactions(title: String = "SwiftUI Redactions") -> Self {
    Self(
      blurb: #"""
SwiftUI has introduced the concept of “redacted views”, which gives you a really nice way to redact the a view's content. This is really powerful, but just because the view has been redacted it doesn’t mean the logic has been. We will demonstrate this problem and show how the Composable Architecture offers a really nice solution.
"""#,
      coreLessons: [
        .init(episode: .ep115_redactions_pt1),
        .init(episode: .ep116_redactions_pt2),
        .init(episode: .ep117_redactions_pt3),
        .init(episode: .ep118_redactions_pt4),
      ],
      related: [
        .init(
          blurb: #"""
For more on the Composable Architecture, be sure to check out the entire collection where we break down the problems of application architecture to build a solution from first principles.
"""#,
          content: .collection(.composableArchitecture)
        )
      ],
      title: "Redactions",
      whereToGoFromHere: nil
    )
  }

  public static func swiftUIAnimations(title: String = "SwiftUI Animations") -> Self {
    Self(
      blurb: """
        Animations are one of the most impressive features of SwiftUI. With very little work you can
        animate almost any aspect of a SwiftUI application. We take a deep-dive into the various
        flavors of animations (implicit versus explicit), and show that a surprising transformation
        of Combine schedulers allows us to animate asynchronous data flow in a seamless manner,
        which is applicable to both vanilla SwiftUI applications and Composable Architecture
        applications.
        """,
      coreLessons: [
        .init(episode: .ep135_animations),
        .init(episode: .ep136_animations),
        .init(episode: .ep137_animations),
      ],
      related: [
        .init(
          blurb: """
            For more on the Composable Architecture, be sure to check out the entire collection \
            where we break down the problems of application architecture to build a solution from \
            first principles.
            """,
          content: .collections([
            .composableArchitecture
          ])
        )
      ],
      title: title,
      whereToGoFromHere: nil
    )
  }
}
