import Foundation

extension Episode {
  public static let ep305_sharing = Episode(
    blurb: """
      "Sharing" is a brand new library for sharing state throughout your application and to external
      systems like user defaults, the file system, and more. We start our tour of the library by
      comparing it to a tool that inspired its design: SwiftUI's `@AppStorage`.
      """,
    codeSampleDirectory: "0305-sharing-pt1",
    exercises: _exercises,
    id: 305,
    length: 38 * 60 + 3,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-02")!,
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
    sequence: 305,
    subtitle: "App Storage, Part 1",
    title: "Tour of Sharing",
    trailerVideo: .init(
      bytesLength: 55_200_000,
      downloadUrls: .s3(
        hd1080: "0305-trailer-1080p-457196495e484c1898921d6d2c2a230c",
        hd720: "0305-trailer-720p-2c2a22e9c6944397bb6cffcbaa5cd1d6",
        sd540: "0305-trailer-540p-bfe7d38d947a468d9d7c7805fb1aa4f6"
      ),
      vimeoId: 1_031_752_507
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
