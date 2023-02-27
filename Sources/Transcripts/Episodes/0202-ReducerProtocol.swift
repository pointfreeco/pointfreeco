import Foundation

extension Episode {
  public static let ep202_reducerProtocol = Episode(
    blurb: """
      Let's begin to solve a number of the problems with the Composable Architecture by introducing a reducer protocol. We will write some common conformances and operators in the new style, and even refactor a complex demo application.
      """,
    codeSampleDirectory: "0202-reducer-protocol-pt2",
    exercises: _exercises,
    id: 202,
    length: 52 * 60 + 54,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_661_749_200),
    references: [
      // TODO
    ],
    sequence: 202,
    subtitle: "The Solution",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 45_100_000,
      downloadUrls: .s3(
        hd1080: "0202-trailer-1080p-9ad2a51ea0df411abfef21457078b881",
        hd720: "0202-trailer-720p-9044c6654a0c47fa80d95f7059aa4cec",
        sd540: "0202-trailer-540p-7ae2d9c8305043d9ad59d1399678340c"
      ),
      vimeoId: 742_392_148
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
