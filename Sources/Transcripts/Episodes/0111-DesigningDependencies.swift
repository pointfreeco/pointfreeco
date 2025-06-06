import Foundation

extension Episode {
  public static let ep111_designingDependencies_pt2 = Episode(
    blurb: """
      Let's scrap the protocols for designing our dependencies and just use plain data types. Not only will we gain lots of new benefits that were previously impossible with protocols, but we'll also be able to modularize our application to improve compile times.
      """,
    codeSampleDirectory: "0111-designing-dependencies-pt2",
    exercises: _exercises,
    id: 111,
    length: 34 * 60 + 4,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_596_430_800),
    references: [
      .protocolOrientedProgrammingWwdc,
      reference(
        forCollection: .protocolWitnesses,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/protocol-witnesses"
      ),
    ],
    sequence: 111,
    subtitle: "Modularization",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 5_748_685,
      downloadUrls: .s3(
        hd1080: "0111-trailer-1080p-9d9f4793b47a49a5b37cc29300ebef94",
        hd720: "0111-trailer-720p-51d317b0f6e84bd3a4c8e18b399fda96",
        sd540: "0111-trailer-540p-26186efabd5943739a090e8250dca4ff"
      ),
      id: "e35db5c65efd8017093dce0ad39a0dfa"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
