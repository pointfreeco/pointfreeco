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
    publishedAt: .init(timeIntervalSince1970: 1541408400),
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
      bytesLength: 89450273,
      vimeoId: 351174875,
      vimeoSecret: "feca184c7248b4bcaa955a06d06d43fa1b920b20"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Currently Swift does not allow protocol methods to contain arguments with default values. For example, the following protocol is not representable in Swift:

```swift
protocol Service {
  func fetchUser(id: Int, cache: Bool = false) -> User?
}

// 🛑 Default argument not permitted in a protocol method
```

Show how this can be done with a concrete data type representation of `Service`.
"""),
.init(problem: """
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
