import Foundation

extension Episode {
  public static let ep308_sharing = Episode(
    blurb: """
      We close out our tour of the Sharing library by showing how easy it is to test code that uses
      the `@Shared` property wrapper without worrying about values bleeding between tests and the
      simulator. And we'll take the "in-memory" shared key for a spin by building one final feature.
      """,
    codeSampleDirectory: "0308-sharing-pt4",
    exercises: _exercises,
    id: 308,
    length: 28 * 60 + 37,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-18")!,
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
    sequence: 308,
    subtitle: "File Storage: Part 2",
    title: "Tour of Sharing",
    trailerVideo: .init(
      bytesLength: 37_400_000,
      downloadUrls: .s3(
        hd1080: "0308-trailer-1080p-76d02888c37d407e8533e9d70f7ef49e",
        hd720: "0308-trailer-720p-ca4e6908ce684da591a84bac156d40fd",
        sd540: "0308-trailer-540p-82631668efe846e3b25903738c2c829f"
      ),
      vimeoId: 1_031_771_200
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
