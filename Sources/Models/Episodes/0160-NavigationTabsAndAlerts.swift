import Foundation

extension Episode {
  public static let ep160_navigationTabsAndAlerts = Episode(
    blurb: """
Navigation is a really, really complex topic. We will begin our deep dive into the topic by coming up with a precise definition of what "navigation" is, and by exploring a couple simpler forms of navigation.
""",
    codeSampleDirectory: "TODO",
    exercises: _exercises,
    id: 160,
    image: "TODO",
    length: 28*60 + 0,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1632114000),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
      reference(
        forSection: .composableBindings,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/swiftui/composable-bindings"
      ),
    ],
    sequence: 160,
    subtitle: "Tabs & Alerts, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 0, // TODO
      vimeoId: 0, // TODO
      vimeoSecret: "" // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
