import Foundation

extension Episode {
  public static let ep203_reducerProtocol = Episode(
    blurb: """
      We are already seeing huge benefits from the reducer protocol, but one aspect is still not ideal, and that is how we compose reducers. We will look to result builders to solve the problem, and a new feature of them introduced in Swift 5.7.
      """,
    codeSampleDirectory: "0203-reducer-protocol-pt3",
    exercises: _exercises,
    id: 203,
    length: 30 * 60 + 44,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_662_354_000),
    references: [
      .se_0348_buildPartialBlock
    ],
    sequence: 203,
    subtitle: "Composition, Part 1",
    title: "Reducer Protocol",
    trailerVideo: .init(
      bytesLength: 31_400_000,
      downloadUrls: .s3(
        hd1080: "0203-trailer-1080p-c7a354f6439740c8bd2036c75348f66d",
        hd720: "0203-trailer-720p-48376fcb78b1469fb8bc9d02afb2b925",
        sd540: "0203-trailer-540p-743593ba4a6745a28bb0c485ef8a2cca"
      ),
      vimeoId: 742_852_856
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
