import Foundation

extension Episode {
  public static let ep151_scopePerformance = Episode(
    blurb: """
      Did you know the Composable Architecture's `scope` operation and `ViewStore` are performance tools? We'll explore how to diagnose your app's performance, how `scope` can help, and fix a few long-standing performance issues in the library itself.
      """,
    codeSampleDirectory: "0151-tca-performance",
    exercises: _exercises,
    id: 151,
    length: 45 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_624_856_400),
    references: [
      // TODO
    ],
    sequence: 151,
    subtitle: "View Stores and Scoping",
    title: "Composable Architecture Performance",
    trailerVideo: .init(
      bytesLength: 49_636_137,
      downloadUrls: .s3(
        hd1080: "0151-trailer-1080p-eaf47f7d03094611b10025a0c3c5d7a1",
        hd720: "0151-trailer-720p-02982793d02a4cd7b9189fd48d1764f8",
        sd540: "0151-trailer-540p-957194c6f05349dcb84d710c27233020"
      ),
      vimeoId: 566_667_291
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
