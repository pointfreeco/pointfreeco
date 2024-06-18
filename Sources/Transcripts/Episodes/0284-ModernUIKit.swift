import Foundation

extension Episode {
  public static let ep284_modernUIKit = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0284-modern-uikit-pt4",
    exercises: _exercises,
    id: 284,
    length: 0 * 60 + 0,  // TODO
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-06-24")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 284,
    subtitle: "Basics of Navigation",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "0284-trailer-1080p-TODO",
        hd720: "0284-trailer-720p-TODO",
        sd540: "0284-trailer-540p-TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
