import Foundation

extension Episode {
  public static let ep307_sharing = Episode(
    blurb: """
      `@Shared` is far more than a glorified version of `@AppStorage`: it can be customized with \
      additional persistence strategies, including the file storage strategy that comes with the \
      library, which persists far more complex data than user defaults. We will create a complex, \
      new feature that is powered by the file system.
      """,
    codeSampleDirectory: "0307-sharing-pt3",
    exercises: _exercises,
    id: 307,
    length: 39 * 60 + 46,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2024-12-16")!,
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
    sequence: 307,
    subtitle: "File Storage: Part 1",
    title: "Tour of Sharing",
    trailerVideo: .init(
      bytesLength: 63_500_000,
      downloadUrls: .s3(
        hd1080: "0307-trailer-1080p-9a79b442c39a4bce90a576e89f5cdd17",
        hd720: "0307-trailer-720p-3b25eb50e8954a7595300716ea3dfb15",
        sd540: "0307-trailer-540p-0a72dd40d518495e84c73e89ec286c6f"
      ),
      vimeoId: 1_031_770_871
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
