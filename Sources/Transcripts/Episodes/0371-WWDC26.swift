import Foundation

extension Episode {
  public static let ep371_wwdc26 = Episode(
    blurb: """
      Another year, another set of UIKit updates, proving that the framework is far from dead! \
      It has adopted more support for the Observation framework, which is nice, but it could go so \
      much further. To see how, we will employ the UIKitNavigation library to show how we can add \
      SwiftUI-like state-driven navigation and controls to a UIKit feature, including animations \
      and even transactions.
      """,
    codeSampleDirectory: "0371-wwdc26-pt2",
    exercises: _exercises,
    id: 371,
    length: 42 * 60 + 33,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-06")!,
    references: [
      Episode.Reference(
        author: "Michael Ochs",
        blurb: """
          > Discover the latest updates to UIKit. 
          """,
        link: "https://developer.apple.com/videos/play/wwdc2026/278/",
        publishedAt: yearMonthDayFormatter.date(from: "2026-06-09")!,
        title: "WWDC26: Modernize your UIKit app"
      ),
      .swiftNavigation,
      .swiftCasePaths,
    ],
    sequence: 371,
    socialImage: nil,
    subtitle: "UIKit",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 48_800_000,
      downloadUrls: .s3(
        hd1080: "0371-trailer-1080p-a0abe5eaad1b449594245651fbd9af98",
        hd720: "0371-trailer-1080p-a0abe5eaad1b449594245651fbd9af98",
        sd540: "0371-trailer-1080p-a0abe5eaad1b449594245651fbd9af98"
      ),
      id: "8f9984f1c99edc9e05bc590633569e5a"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
