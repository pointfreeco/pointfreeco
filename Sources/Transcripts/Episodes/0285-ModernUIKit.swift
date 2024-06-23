import Foundation

extension Episode {
  public static let ep285_modernUIKit = Episode(
    blurb: """
      We have built the foundation of powerful new UIKit navigation tools, but they're not quite \
      finished. Let's improve these APIs to handle dismissal by leveraging another SwiftUI tool: \
      bindings. We will see how SwiftUI bindings are (almost) the perfect tool for UIKit \
      navigation, and we will see where they fall short.
      """,
    codeSampleDirectory: "0285-modern-uikit-pt5",
    exercises: _exercises,
    id: 285,
    length: 35 * 60 + 25,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-01")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 285,
    subtitle: "Unified Navigation",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 24_900_000,
      downloadUrls: .s3(
        hd1080: "0285-trailer-1080p-9a468e9486024e6ea51df35a4e715151",
        hd720: "0285-trailer-720p-50a95d1ce71d44b69003a62c8cd4224f",
        sd540: "0285-trailer-540p-e52e39f54dfd47d6adc6e41f82388967"
      ),
      vimeoId: 956_801_482
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
