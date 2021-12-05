import Foundation

extension Episode {
  public static let ep170_uikitNavigation = Episode(
    blurb: """
TODO
""",
    codeSampleDirectory: "0170-uikit-navigation-pt2",
    exercises: _exercises,
    id: 170,
    length: 49*60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1638770400),
    references: [
      reference(
        forSection: .navigation,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/swiftui/navigation"
      ),
    ],
    sequence: 170,
    subtitle: "Part 2",
    title: "UIKit Navigation",
    trailerVideo: .init(
      bytesLength: 19176941,
      vimeoId: 651611406,
      vimeoSecret: "4b357963be48195ccfb8191be8df9b5d0e31a02a"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
]
