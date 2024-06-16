import Foundation

extension Episode {
  public static let ep285_modernUIKit = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0285-modern-uikit-pt5",
    exercises: _exercises,
    id: 285,
    length: 0 * 60 + 0,  // TODO
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
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0285-trailer-1080p-TODO",
        hd720: "0285-trailer-720p-TODO",
        sd540: "0285-trailer-540p-TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
