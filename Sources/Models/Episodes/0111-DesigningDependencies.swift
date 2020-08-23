import Foundation

extension Episode {
  public static let ep111_designingDependencies_pt2 = Episode(
    blurb: """
Let's scrap the protocols for designing our dependencies and just use plain data types. Not only will we gain lots of new benefits that were previously impossible with protocols, but we'll also be able to modularize our application to improve compile times.
""",
    codeSampleDirectory: "0111-designing-dependencies-pt2",
    exercises: _exercises,
    id: 111,
    image: "https://i.vimeocdn.com/video/930420393.jpg",
    length: 34*60 + 4,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1596430800),
    references: [
      .protocolOrientedProgrammingWwdc,
      reference(
        forCollection: .protocolWitnesses, additionalBlurb: #"""
"""#,
        collectionUrl: "https://www.pointfree.co/collections/protocol-witnesses"
      )
    ],
    sequence: 111,
    subtitle: "Modularization",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 5748685,
      vimeoId: 441578541,
      vimeoSecret: "8b460fa5dcbec3ceef85d7a2458f9f9a6d06f7d8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
