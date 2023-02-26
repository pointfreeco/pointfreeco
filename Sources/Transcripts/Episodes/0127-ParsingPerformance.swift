import Foundation

extension Episode {
  public static let ep127_parsingPerformance = Episode(
    blurb: """
      We want to explore the performance of composable parsers, but to do so we must first take a deep dive into the Swift string API. There are multiple abstractions of strings in Swift, each with its own benefits and performance characteristics. We will benchmark them in order to get a scientific basis for comparison, and will describe how to properly write a benchmark.
      """,
    codeSampleDirectory: "0127-parsing-performance-pt1",
    exercises: _exercises,
    id: 127,
    length: 35 * 60 + 18,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_606_716_000),
    references: [
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
      .swiftsCollectionTypes(
        blurb: """
          In this episode we explored different representations of strings and their subsequences (i.e. `Substring`, `UnicodeScalarView`, and `UTF8View`), but more generally there are collections and slices. This article gives a nice accounting of the zoo of types in Swift's collections API.
          """),
      .init(
        author: "Stephen Celis",
        blurb: """
          While researching the string APIs for this episode we stumbled upon a massive inefficiency in how Swift implements `removeFirst` on certain collections. This PR fixes the problem and turns the method from an `O(n)` operation (where `n` is the length of the array) to an `O(k)` operation (where `k` is the number of elements being removed).
          """,
        link: "https://github.com/apple/swift/pull/32451",
        publishedAt: yearMonthDayFormatter.date(from: "2020-07-28"),
        title: "Improve performance of Collection.removeFirst(_:) where Self == SubSequence"
      ),
    ],
    sequence: 127,
    subtitle: "Strings",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 59_207_692,
      downloadUrls: .s3(
        hd1080: "0127-trailer-1080p-3317996a46184e828d2061c68e39d534",
        hd720: "0127-trailer-720p-f743367d6f024e2d934ca5bebf6e98f1",
        sd540: "0127-trailer-540p-d7c2d9e9cf9c46feab2c94dc460a44cf"
      ),
      vimeoId: 485_209_021
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
