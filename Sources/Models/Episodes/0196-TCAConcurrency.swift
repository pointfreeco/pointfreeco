import Foundation

extension Episode {
  public static let ep196_tcaConcurrency = Episode(
    blurb: """
      This week we start fixing the problems we outlined last week. We build the tools necessary to start using concurrency tasks directly in reducers, and along the way we open Pandora's box of existential types to solve some mind-bending type issues.
      """,
    codeSampleDirectory: "0196-tca-concurrency-pt2",
    exercises: _exercises,
    id: 196,
    length: 52 * 60 + 58,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_657_515_600),
    references: [
      reference(
        forCollection: .concurrency,
        additionalBlurb: "",
        collectionUrl: "http://pointfree.co/collections/concurrency"
      )
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
