import Foundation

extension Episode {
  public static let ep160_navigationTabsAndAlerts = Episode(
    blurb: """
Navigation is a really, really complex topic, and it's going to take us many episodes go deep into it. We will begin our journey by coming up with a precise definition of what "navigation" is, and by exploring a couple simpler forms of navigation.
""",
    codeSampleDirectory: "TODO",
    exercises: _exercises,
    id: 160,
    image: "https://i.vimeocdn.com/video/1246096458-90742d78eb8e3e0c8eebd9ac7f94066075d84238b67345c0957a08b9e871d5d8-d?mw=1600&mh=900&q=70",
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
