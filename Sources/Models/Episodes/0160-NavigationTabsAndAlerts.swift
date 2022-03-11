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
      .swiftUINav,
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
      downloadUrls: .s3(
        hd1080: "0160-trailer-1080p-97fe1f1d9898425e95704fed43c29b65",
        hd720: "0160-trailer-720p-20b2d610d35f47b0953161e6474844c2",
        sd540: "0160-trailer-540p-7caffa15bca14f7f895d4e653b53806d"
      ),
      vimeoId: 609414235
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
