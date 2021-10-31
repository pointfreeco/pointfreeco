import Foundation

extension Episode {
  public static let ep166_navigationLinks = Episode(
    blurb: """
Let's explore "tag" and "selection"-based navigation links in SwiftUI. What are they for and how do they compare with the link and link helpers we've used so far? We will then take a step back to compare links with all of the other forms of navigation out there and propose a "Grand Unified Theory of Navigation."
""",
    codeSampleDirectory: "0166-navigation-pt7",
    exercises: _exercises,
    id: 166,
    length: 37*60 + 56,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1635742800),
    references: [
      reference(
        forSection: .derivedBehavior,
        additionalBlurb: #"""
"""#,
        sectionUrl: "https://www.pointfree.co/collections/case-studies/derived-behavior"
      ),
    ],
    sequence: 166,
    subtitle: "Links, Part 2",
    title: "SwiftUI Navigation",
    trailerVideo: .init(
      bytesLength: 27828052,
      vimeoId: 640691264,
      vimeoSecret: "9d30e831ceb3bb334a8385ef874fd48dde8bc8d5"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
