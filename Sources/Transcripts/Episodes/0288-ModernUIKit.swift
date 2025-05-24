import Foundation

extension Episode {
  public static let ep288_modernUIKit = Episode(
    blurb: """
      We round out our stack navigation tools with support for an `@Environment`-like feature for \
      holding onto the stack's path, a `NavigationLink`-like feature for pushing features onto the \
      stack from anywhere, and we'll handle every corner case from deep-linking to user dismissal.
      """,
    codeSampleDirectory: "0288-modern-uikit-pt8",
    exercises: _exercises,
    id: 288,
    length: 28 * 60 + 30,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-22")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 288,
    subtitle: "Stack Navigation, Part 2",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 46_600_000,
      downloadUrls: .s3(
        hd1080: "0288-trailer-1080p-7c57871940194c1e88948842d0205ff4",
        hd720: "0288-trailer-720p-fbd5e3631b724763ae3e7aaeedc48901",
        sd540: "0288-trailer-540p-21097bea25d34469af400aaf543cbd27"
      ),
      id: "d3d2cfd1ee92e7d867edb0c7e7bd5004"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
