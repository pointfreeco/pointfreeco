import Foundation

extension Episode {
  public static let ep300_equatable = Episode(
    blurb: """
      We zoom out a bit to get a greater appreciation for how `Equatable` and `Hashable` are used throughout the greater language and ecosystem, including actors, standard library types, SwiftUI, and more.
      """,
    codeSampleDirectory: "0300-back-to-basics-equatable-pt4",
    exercises: _exercises,
    id: 300,
    length: 40 * 60 + 53,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-10-28")!,
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
    sequence: 300,
    subtitle: "Advanced Hashable",
    title: "Back to Basics",
    trailerVideo: .init(
      bytesLength: 37_100_000,
      downloadUrls: .s3(
        hd1080: "0300-trailer-1080p-61577d1f49f84c1aace443e97b14946f",
        hd720: "0300-trailer-720p-4ab03edf041043e7b134700633b37d79",
        sd540: "0300-trailer-540p-caf516ed7ef04228b3e9e81761e7c101"
      ),
      id: "933e167afbfc2703e97118141e8a7c67"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
