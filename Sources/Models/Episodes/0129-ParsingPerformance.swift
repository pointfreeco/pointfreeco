import Foundation

extension Episode {
  public static let ep129_parsingPerformance = Episode(
    blurb: """
The performance gains we have made with the parser type have already been super impressive, but we can take things even further. We will explore the performance characteristics of closures using the time profiler and make some changes to how we define parsers to unlock even more speed.
""",
    codeSampleDirectory: "0129-parsing-performance-pt3",
    exercises: _exercises,
    id: 129,
    length: 39*60 + 19,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1607925600),
    references: [
      .combineTypes(),
      .fusionPrimer,
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
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
    sequence: 129,
    subtitle: "Protocols",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 36711102,
      downloadUrls: .s3(
        hd1080: "0129-trailer-1080p-db6931b9dda54cebb147891cd1e0f004",
        hd720: "0129-trailer-720p-a1cc94fb029b455f8ccb5757df904c51",
        sd540: "0129-trailer-540p-a150037fb63b4c1c83dc340b9d9fcb5a"
      ),
      vimeoId: 490481881
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
To better understand the difference between the `Parser` struct and `ParserProtocol`, let's take a look at the stack of a deeply-nested parser.

Print out the stack frames (using `Thread.callStackSymbols`) inside both `Parser.int` and `IntParser` and run only the nested benchmarks. You can reduce the number of iterations of a benchmark by passing the `Iterations(1)` option to the suite:

```swift
let protocolSuite = BenchmarkSuite(
  name: "Protocol",
  settings: Iterations(1)
) { suite in
```

How do the stacks compare? How do they differ from the stack when viewed in the debugger and time profiler instrument?
"""#,
    solution: #"""
`Int.parser`'s call stack array contains 27 frames of parsing code. `IntParser`, on the other hand has only 5 parser-specific frames. Quite the difference!

In the debugger and time profiler instrument, `Int.parser`'s parsing-specific stack is 37 frames in the debugger, so we're seeing that Swift was able to optimize 10 frames out. Meanwhile, `IntParser` shows 20 frames in the debugger, which means it optimized _15_ frames out. Pretty impressive!
"""#
  ),
]
