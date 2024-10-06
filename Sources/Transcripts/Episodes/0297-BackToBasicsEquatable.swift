import Foundation

extension Episode {
  public static let ep297_equatable = Episode(
    blurb: """
      In this series we go back to basics with a deep dive into the subject of `Equatable` types. Equatability is a deceptively simple topic. It is a surprisingly tricky protocol that has some very specific semantics that must be upheld baked into it, and there are many misconceptions on how one can or should conform types to this protocol.     
      """,
    codeSampleDirectory: "0297-back-to-basics-equatable-pt1",
    exercises: _exercises,
    id: 297,
    length: 29 * 60 + 23,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-10-07")!,
    references: [
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
      .init(
        author: "Anthony Latsis, Filip Sakel, Suyash Srijan",
        blurb: """
          > This proposal is a preamble to a series of changes aimed at generalizing value-level abstraction (existentials) and improving its interaction with type-level abstraction (generics).
          """,
        link: "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0309-unlock-existential-types-for-all-protocols.md",
        publishedAt: yearMonthDayFormatter.date(from: "2020-09-26")!,
        title: "SE-0309: Unlock existentials for all protocols"
      )
    ],
    sequence: 297,
    subtitle: "Equatable",
    title: "Back to Basics",
    trailerVideo: .init(
      bytesLength: 59_900_000,
      downloadUrls: .s3(
        hd1080: "0297-trailer-1080p-4c17c236e54b4a27b8689c3b51910526",
        hd720: "0297-trailer-720p-4f7680084eea48f9a533173369229d75",
        sd540: "0297-trailer-540p-2faa9c99b8174f7ea9460dcfd5399095"
      ),
      vimeoId: 1016179870
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
