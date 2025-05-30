import Foundation

extension Episode {
  public static let ep112_designingDependencies_pt3 = Episode(
    blurb: """
      It's straightforward to design the dependency for interacting with an API client, but sadly most dependencies we work with are not so simple. So let's consider a far more complicated dependency. One that is long living, and involves extra types that we can't even construct ourselves.
      """,
    codeSampleDirectory: "0112-designing-dependencies-pt3",
    exercises: _exercises,
    id: 112,
    length: 46 * 60 + 30,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_597_035_600),
    references: [
      .protocolOrientedProgrammingWwdc,
      reference(
        forCollection: .protocolWitnesses,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/protocol-witnesses"
      ),
    ],
    sequence: 112,
    subtitle: "Reachability",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 75_932_312,
      downloadUrls: .s3(
        hd1080: "0112-trailer-1080p-e1d040683d2b4e7b9d3404402b926b28",
        hd720: "0112-trailer-720p-1e2147394c134368996b3754a4978414",
        sd540: "0112-trailer-540p-3a620a3d08df4b1aa83d37bcef94dfcd"
      ),
      id: "898d872a3f5837c55dbf30f5a1fb528c"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
