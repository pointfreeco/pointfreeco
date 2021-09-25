import Foundation

extension Episode {
  public static let ep161_navigationTabsAndAlerts = Episode(
    blurb: """
TODO
""",
    codeSampleDirectory: "0161-navigation-pt2",
    exercises: _exercises,
    id: 161,
    length: 32*60 + 25,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1632718800),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 161,
    subtitle: "Tabs & Alerts, Part 2",
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
