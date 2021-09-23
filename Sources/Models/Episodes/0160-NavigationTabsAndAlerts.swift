import Foundation

extension Episode {
  public static let ep160_navigationTabsAndAlerts = Episode(
    blurb: """
Navigation is a really, really complex topic, and it's going to take us many episodes go deep into it. We will begin our journey by coming up with a precise definition of what "navigation" is, and by exploring a couple simpler forms of navigation.
""",
    codeSampleDirectory: "0160-navigation-pt1",
    exercises: _exercises,
    id: 160,
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
    ],
    sequence: 160,
    subtitle: "Tabs & Alerts, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 126764402,
      vimeoId: 609414235,
      vimeoSecret: "922d9996b68f5f1760f19c886b8abf9f85dfd035"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
