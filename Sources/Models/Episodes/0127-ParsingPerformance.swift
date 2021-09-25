import Foundation

extension Episode {
  public static let ep127_parsingPerformance = Episode(
    blurb: """
We want to explore the performance of composable parsers, but to do so we must first take a deep dive into the Swift string API. There are multiple abstractions of strings in Swift, each with its own benefits and performance characteristics. We will benchmark them in order to get a scientific basis for comparison, and will describe how to properly write a benchmark.
""",
    codeSampleDirectory: "0127-parsing-performance-pt1",
    exercises: _exercises,
    id: 127,
    length: 35*60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1606716000),
    references: [
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
      .swiftsCollectionTypes(blurb: """
        In this episode we explored different representations of strings and their subsequences (i.e. `Substring`, `UnicodeScalarView`, and `UTF8View`), but more generally there are collections and slices. This article gives a nice accounting of the zoo of types in Swift's collections API.
        """),
      .init(
        author: "Stephen Celis",
        blurb: """
        While researching the string APIs for this episode we stumbled upon a massive inefficiency in how Swift implements `removeFirst` on certain collections. This PR fixes the problem and turns the method from an `O(n)` operation (where `n` is the length of the array) to an `O(k)` operation (where `k` is the number of elements being removed).
        """,
        link: "https://github.com/apple/swift/pull/32451",
        publishedAt: referenceDateFormatter.date(from: "2020-07-28"),
        title: "Improve performance of Collection.removeFirst(_:) where Self == SubSequence"
      )
    ],
    sequence: 127,
    subtitle: "Strings",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 59207692,
      vimeoId: 485209021,
      vimeoSecret: "5e4fb1ff00a978976ecdf2873ae3b59d454c68d4"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
