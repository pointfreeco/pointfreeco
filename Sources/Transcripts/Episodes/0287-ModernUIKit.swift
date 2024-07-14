import Foundation

extension Episode {
  public static let ep287_modernUIKit = Episode(
    blurb: """
      We have now implemented tree-based navigation in UIKit, driven by the Observation framework, \
      but there is another form of navigation to think about: stack-based navigation, where you \
      drive your navigation from a flat collection of states rather than a heavily-nested type. \
      Let's leverage Observation to build a really nice tool for stack-based navigation.
      """,
    codeSampleDirectory: "0287-modern-uikit-pt7",
    exercises: _exercises,
    id: 287,
    length: 28 * 60 + 26,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-07-15")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
    ],
    sequence: 287,
    subtitle: "Stack Navigation, Part 1",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 55_400_000,
      downloadUrls: .s3(
        hd1080: "0287-trailer-1080p-cf847dc99b75481abf2ac44b8c360988",
        hd720: "0287-trailer-720p-219ba7b4adaa4dfd98c95ce0d7e7caee",
        sd540: "0287-trailer-540p-57ee7b3c669e451dbaaa3148f37bad28"
      ),
      vimeoId: 956_801_601
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
