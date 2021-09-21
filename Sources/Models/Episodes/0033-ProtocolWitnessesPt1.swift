import Foundation

extension Episode {
  static let ep33_protocolWitnesses_pt1 = Episode(
    blurb: """
Protocols are a great tool for abstraction, but aren't the only one. This week we begin to explore the tradeoffs of using protocols by highlighting a few areas in which they fall short in order to demonstrate how we can recover from these problems using a different tool and different tradeoffs.
""",
    codeSampleDirectory: "0033-protocol-witnesses-pt1",
    id: 33,
    image: "https://i.vimeocdn.com/video/801301947-033a422f3f421ce122d8a0b1c968a526975777a9b73c8e783580ddd8121150f5-d",
    length: 18*60 + 12,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1539582522),
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
      bytesLength: 58613270,
      vimeoId: 349952461,
      vimeoSecret: "6e0c2e80479f74bce12d5df0b105fd9de2bf0eea"
    )
  )
}
