import Foundation

extension Episode {
  public static let ep165_navigationLinks = Episode(
    blurb: """
It's time to explore the most complex form of navigation in SwiftUI: links! We'll start with some simpler flavors of `NavigationLink` to see how they work, how they compare with other navigation APIs, and how they interact with the tools we've built in this series.
""",
    codeSampleDirectory: "0165-navigation-pt6",
    exercises: _exercises,
    id: 165,
    length: 39*60 + 20,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1635138000),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 165,
    subtitle: "Links, Part 1",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 0,
      vimeoId: 0,
      vimeoSecret: "TODO"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
