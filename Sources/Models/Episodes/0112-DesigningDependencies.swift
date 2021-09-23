import Foundation

extension Episode {
  public static let ep112_designingDependencies_pt3 = Episode(
    blurb: """
It's straightforward to design the dependency for interacting with an API client, but sadly most dependencies we work with are not so simple. So let's consider a far more complicated dependency. One that is long living, and involves extra types that we can't even construct ourselves.
""",
    codeSampleDirectory: "0112-designing-dependencies-pt3",
    exercises: _exercises,
    id: 112,
    length: 46*60 + 30,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1597035600),
    references: [
      .protocolOrientedProgrammingWwdc,
      reference(
        forCollection: .protocolWitnesses,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/protocol-witnesses"
      )
    ],
    sequence: 112,
    subtitle: "Reachability",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 75932312,
      vimeoId: 446338843,
      vimeoSecret: "c9975312c2cd9562771f039aa9fd70dbc3711fc2"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
