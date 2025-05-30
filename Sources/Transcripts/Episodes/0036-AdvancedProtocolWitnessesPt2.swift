import Foundation

extension Episode {
  static let ep36_advancedProtocolWitnesses_pt2 = Episode(
    blurb: """
      We complete our dictionary for translating Swift protocol concepts into concrete datatypes and functions. This includes protocol inheritance, protocol extensions, default implementations _and_ protocols with associated types. Along the way we will also show how concrete types can express things that are currently impossible with Swift protocols.
      """,
    codeSampleDirectory: "0036-advanced-protocol-witnesses-pt2",
    exercises: _exercises,
    id: 36,
    length: 37 * 60 + 41,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_541_408_400),
    references: [
      .protocolOrientedProgrammingWwdc,
      .modernSwiftApiDesign,
      .pullbackWikipedia,
      .gallagherProtocolsWithAssociatedTypes,
      .protocolOrientedProgrammingIsNotASilverBullet,
      .valueOrientedProgramming,
      .scrapYourTypeClasses,
      .haskellAntipatternExistentialTypeclass,
      .someNewsAboutContramap,
      .contravariance,
      .protocolWitnessesAppBuilders2019,
      .someNewsAboutContramap,
    ],
    sequence: 36,
    title: "Advanced Protocol Witnesses: Part 2",
    trailerVideo: .init(
      bytesLength: 89_450_273,
      downloadUrls: .s3(
        hd1080: "0036-trailer-1080p-24589692f9df4ba59ea41517ab0951d4",
        hd720: "0036-trailer-720p-e882c1812a4942f99035f635c5a200c4",
        sd540: "0036-trailer-540p-b3ac10002e4e4ed6ace604232953fb4d"
      ),
      id: "6b1a6f9d7212d25e97f58f3b7747b0b8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Currently Swift does not allow protocol methods to contain arguments with default values. For example, the following protocol is not representable in Swift:

      ```swift
      protocol Service {
        func fetchUser(id: Int, cache: Bool = false) -> User?
      }

      // 🛑 Default argument not permitted in a protocol method
      ```

      Show how this can be done with a concrete data type representation of `Service`.
      """),
  .init(
    problem: """
      Currently Swift does not allow protocols to extend other protocols, even if you provide all of the extensions requirements. For example, we cannot extend `Numeric` to be combinable even though it is easy to implement the requirement:

      ```swift
      extension Numeric: Combinable {
        func combine(with other: Self) -> Self {
          return self + other
        }
      }

      // 🛑 Extension of protocol 'Numeric' cannot have an inheritance clause
      ```

      Show how this can be done with a concrete data type representation of `Service`.
      """),
]
