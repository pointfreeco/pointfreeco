import Foundation

extension Episode {
  static let ep33_protocolWitnesses_pt1 = Episode(
    blurb: """
      Protocols are a great tool for abstraction, but aren't the only one. This week we begin to explore the tradeoffs of using protocols by highlighting a few areas in which they fall short in order to demonstrate how we can recover from these problems using a different tool and different tradeoffs.
      """,
    codeSampleDirectory: "0033-protocol-witnesses-pt1",
    id: 33,
    length: 18 * 60 + 12,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_539_582_522),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .gallagherProtocolsWithAssociatedTypes,
      .protocolOrientedProgrammingIsNotASilverBullet,
      .valueOrientedProgramming,
      .scrapYourTypeClasses,
      .haskellAntipatternExistentialTypeclass,
      .protocolWitnessesAppBuilders2019,
    ],
    sequence: 33,
    title: "Protocol Witnesses: Part 1",
    trailerVideo: .init(
      bytesLength: 58_613_270,
      downloadUrls: .s3(
        hd1080: "0033-trailer-1080p-d8ea7bb61aeb4fc583e22d0f02b1e9d4",
        hd720: "0033-trailer-720p-027cb017879f4c31a76f749fd851acfe",
        sd540: "0033-trailer-540p-e45569c64fd54c1fae67761d9eecc2e4"
      ),
      vimeoId: 349_952_461
    )
  )
}
