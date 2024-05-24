import Foundation

extension Episode {
  public static let ep282_modernUIKit = Episode(
    blurb: """
      We finish building a modern UIKit application with brand new state-driven tools, including a
      complex collection view that can navigate to two child features. And we will see that, thanks
      to our back-port of Swift's observation tools, we will be able to deploy our app all the way
      back to iOS 13.
      """,
    codeSampleDirectory: "0282-modern-uikit-pt2",
    exercises: _exercises,
    id: 282,
    length: 31 * 60 + 10,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-06-03")!,
    references: [
      .modernSwiftUI(),
      .swiftUINav,
      .swiftUINavigation,
      .swiftCasePaths,
      .swiftPerception,
      .init(
        blurb: """
          > Bring compositional layouts to your app and simplify updating your user interface with diffable data sources

          The sample code that inspired the code for this episode.
          """,
        link: "https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views",
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
      )
    ],
    sequence: 282,
    subtitle: "Sneak Peek, Part 2",
    title: "Modern UIKit",
    trailerVideo: .init(
      bytesLength: 37_700_000,
      downloadUrls: .s3(
        hd1080: "0282-trailer-1080p-ed065da22fd9484b8159562f99a5687a",
        hd720: "0282-trailer-720p-a1d8e08abae24ed68edb3fa9640c6cb3",
        sd540: "0282-trailer-540p-bca92b1cd39440c5a14bfa21a754ebe0"
      ),
      vimeoId: 949782298
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

