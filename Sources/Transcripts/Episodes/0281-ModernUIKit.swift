import Foundation

extension Episode {
  public static let ep281_modernUIKit = Episode(
    blurb: """
      As we approach WWDC24 and 5 years of SwiftUI, let's talk about… UIKit! 😜 We love SwiftUI,
      but there will still be times you must drop down to UIKit, and so we want to show what modern
      UIKit development can look like if you put in a little bit of effort to build tools that allow
      you to model your domains as concisely as possible.
      """,
    codeSampleDirectory: "0281-modern-uikit-pt1",
    exercises: _exercises,
    id: 281,
    length: 39 * 60 + 13,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-05-27")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .init(
        blurb: """
          > Bring compositional layouts to your app and simplify updating your user interface with diffable data sources

          The sample code that inspired the code for this episode.
          """,
        link:
          "https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views",
        publishedAt: yearMonthDayFormatter.date(from: "2019-07-03"),
        title: "Implementing Modern Collection Views"
      ),
      .init(
        blurb: """
          > Collection View Layouts make it easy to build rich interactive collections. Learn how to make dynamic and responsive layouts that range in complexity from basic lists to an advanced, multi-dimensional browsing experience.

          The session associated with the original sample code that inspired the code for this episode.
          """,
        link: "https://developer.apple.com/videos/play/wwdc2019/215/",
        publishedAt: yearMonthDayFormatter.date(from: "2019-07-03"),
        title: "Advances in Collection View Layout"
      ),
    ],
    sequence: 281,
    subtitle: "Sneak Peek, Part 1",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 144_900_000,
      downloadUrls: .s3(
        hd1080: "0281-trailer-1080p-a36ce49560994c43911a0b28464bd2cf",
        hd720: "0281-trailer-720p-c2bd4683ef564a9f92ed09d79e630f38",
        sd540: "0281-trailer-540p-06aabed32cf342f3ac871c3ee04d94df"
      ),
      vimeoId: 949_774_069
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
