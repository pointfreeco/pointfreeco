import Foundation

extension Episode {
  public static let ep196_tcaConcurrency = Episode(
    blurb: """
      This week we fix the problems created by using concurrency tasks directly in our reducers, and along the way we open Pandora's box of existential types in order to solve some mind bending type issues.
      """,
    codeSampleDirectory: "0196-tca-concurrency-pt2",
    exercises: _exercises,
    fullVideo: .ep196_tcaConcurrency,
    id: 196,
    length: 52 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_657_515_600),
    references: [
      // TODO
    ],
    sequence: 196,
    subtitle: "Tasks",
    title: "Async Composable Architecture",
    trailerVideo: .init(
      bytesLength: 58_400_000,
      downloadUrls: .s3(
        hd1080: "0196-trailer-1080p-a13f29dc1abb4ed4ababb897e2682758",
        hd720: "0196-trailer-720p-f11778124d6a448e830082b26ad7a107",
        sd540: "0196-trailer-540p-a121744c5dcc46e8a5236102d3f0bf21"
      ),
      vimeoId: 726_512_066
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Is `Any` a subtype or supertype of all types?
      """#,
    solution: nil
  ),
  Episode.Exercise(
    problem: #"""
      Is `All` a subtype or supertype of all types?
      """#,
    solution: nil
  ),
]
