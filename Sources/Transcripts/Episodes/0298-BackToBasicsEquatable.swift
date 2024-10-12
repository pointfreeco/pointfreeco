import Foundation

extension Episode {
  public static let ep298_equatable = Episode(
    blurb: """
      While the documentation for `Equatable` requires that conformances "must satisfy three conditions" _and_ be "substitutable," there are conformances in the Standard Library that run afoul, but for pragmatic reasons. Let's explore them and then dive deeper into a related protocol: `Hashable`.
      """,
    codeSampleDirectory: "0298-back-to-basics-equatable-pt2",
    exercises: _exercises,
    id: 298,
    length: 39 * 60 + 49,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-10-14")!,
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
    sequence: 298,
    subtitle: "Hashable",
    title: "Back to Basics",
    trailerVideo: .init(
      bytesLength: 38_300_000,
      downloadUrls: .s3(
        hd1080: "0298-trailer-1080p-e0b2e540fe5f4d5d8a7c6349fbebed8d",
        hd720: "0298-trailer-720p-1c53a0cc6d6c4d3f90230763b3b5274a",
        sd540: "0298-trailer-540p-721011e6161541c19dc9da193d9cf680"
      ),
      vimeoId: 1018714670
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
