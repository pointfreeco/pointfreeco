import Foundation

extension Episode {
  public static let ep206_reducerProtocol = Episode(
    blurb: """
      We now have a SwiftUI-inspired system for plucking dependencies out of thin air to provide them to reducers, but we can’t control them or separate interface from implementation. Once we do, we’ll have something far better than ever before.
      """,
    codeSampleDirectory: "0206-reducer-protocol-pt6",
    exercises: _exercises,
    id: 206,
    length: 34 * 60 + 29,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_664_168_400),
    references: [
      // TODO
    ],
    sequence: 206,
    subtitle: "Dependencies, Part 2",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 44_200_000,
      downloadUrls: .s3(
        hd1080: "0206-trailer-1080p-5f6c9934c3f04088862b38bf399f2f53",
        hd720: "0206-trailer-720p-bd866f27ae984dfba333506368029018",
        sd540: "0206-trailer-540p-ef0c54c05926483c9e6eb9de1ce9d0a0"
      ),
      vimeoId: 747_451_567
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
