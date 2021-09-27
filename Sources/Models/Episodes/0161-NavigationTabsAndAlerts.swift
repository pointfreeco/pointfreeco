import Foundation

extension Episode {
  public static let ep161_navigationTabsAndAlerts = Episode(
    blurb: """
We continue our journey exploring navigation with an examination of alerts and action sheets. We'll compare their original APIs in SwiftUI to the ones that replace them in the SDK that just shipped, and do a domain modeling exercise to recover what was lost.
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
      bytesLength: 37014026,
      vimeoId: 613195746,
      vimeoSecret: "002b1ec9a0fbe122b2e64bfaf1dfdb651d9dc2a6"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
