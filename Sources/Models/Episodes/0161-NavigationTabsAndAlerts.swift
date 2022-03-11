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
      .swiftUINav,
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
      downloadUrls: .s3(
        hd1080: "0161-trailer-1080p-722f9b51816747df89f644e19c9c26ac",
        hd720: "0161-trailer-720p-c8f45fae0edf4f0587f84d5cbf3b11ae",
        sd540: "0161-trailer-540p-dad35695503441e99cfbb5d846877e46"
      ),
      vimeoId: 613195746
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
