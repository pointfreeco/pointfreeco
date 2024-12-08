import Foundation

extension Episode {
  public static let ep306_sharing = Episode(
    blurb: """
      We show how the `@Shared` property wrapper, unlike `@AppStorage`, can be used _anywhere_, \
      not just SwiftUI views. And we show how `@Shared` has some extra bells and whistles that \
      make it easier to write maintainable Xcode previews and avoid potential bugs around \
      "string-ly" typed keys and default values.
      """,
    codeSampleDirectory: "0306-sharing-pt2",
    exercises: _exercises,
    id: 306,
    length: 26 * 60 + 34,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-09")!,
    references: [
      .init(
        author: "Point-Free",
        blurb: """
          Instantly share state among your app's features and external persistence layers, \
          including user defaults, the file system, and more.
          """,
        link: "https://github.com/pointfreeco/swift-sharing",
        title: "Sharing"
      )
    ],
    sequence: 306,
    subtitle: "App Storage, Part 2",
    title: "Tour of Sharing",
    trailerVideo: .init(
      bytesLength: 34_600_000,
      downloadUrls: .s3(
        hd1080: "0306-trailer-1080p-30b9960096d7435d815ccf5a14c2a640",
        hd720: "0306-trailer-720p-c1b2d6048a9d481da95269a8970f8d98",
        sd540: "0306-trailer-540p-4c0b6366ccb548b7bee61a561e37f749"
      ),
      vimeoId: 1031752969
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
