import Foundation

extension Episode {
  public static let ep299_equatable = Episode(
    blurb: """
      We've studied `Equatable` and `Hashable`, their laws, and saw how value types as simple bags of data easily conform via "structural" equality. What about reference types? Reference types are an amalgamation of data _and_ behavior, and that data can be mutated in place at any time, so how can they reasonably conform to these protocols?
      """,
    codeSampleDirectory: "0299-back-to-basics-equatable-pt3",
    exercises: _exercises,
    id: 299,
    length: 32 * 60 + 42,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-10-21")!,
    references: [
      .init(
        blurb: """
          > A type that can be hashed into a `Hasher` to produce an integer hash value.

          Documentation for the Swift protocol.
          """,
        link: "https://developer.apple.com/documentation/swift/equatable",
        title: "Hashable"
      ),
      .init(
        blurb: """
          > A type that can be compared for value equality.

          Documentation for the Swift protocol.
          """,
        link: "https://developer.apple.com/documentation/swift/equatable",
        title: "Equatable"
      ),
      .init(
        blurb: """
          > In mathematics, an equivalence relation is a binary relation that is reflexive, symmetric and transitive.

          The Wikipedia page defining an "equivalence relation," a mathematical concept underpinning Swift's `Equatable` protocol.
          """,
        link: "https://en.wikipedia.org/wiki/Equivalence_relation",
        title: "Equivalence relation"
      ),
    ],
    sequence: 299,
    subtitle: "Hashable References",
    title: "Back to Basics",
    trailerVideo: .init(
      bytesLength: 65_700_000,
      downloadUrls: .s3(
        hd1080: "0299-trailer-1080p-ce8e3df8d87c4120a13862fce92682b5",
        hd720: "0299-trailer-720p-e25006c9af6f4c54878e0ed7b5446fe0",
        sd540: "0299-trailer-540p-b188837f2608491698bb7f0448c84910"
      ),
      id: "a3fe83a38a296b393a5584fa1e0bd8c6"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
