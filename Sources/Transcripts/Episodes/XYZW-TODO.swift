import Foundation

extension Episode {
  public static let epN_TODO = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "TODO",
    exercises: _exercises,
    fullVideo: nil,  // Only for free episodes!
    id: 0,  // TODO
    length: 0 * 60 + 0,  // TODO
    permission: .subscriberOnly,
    publishedAt: .distantFuture,  // TODO
    references: [
      // TODO
    ],
    sequence: 0,  // TODO
    subtitle: nil,
    title: "TODO",
    trailerVideo: .init(
      bytesLength: 0,  // TODO
      downloadUrls: .s3(
        hd1080: "TODO",
        hd720: "TODO",
        sd540: "TODO"
      ),
      vimeoId: 0  // TODO
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
