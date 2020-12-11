import Foundation

extension Episode {
  public static let ep129_parsingPerformance = Episode(
    blurb: """
The performance gains we have made with the parser type have already been super impressive, but we can take things even further. We will explore the performance characteristics of closures using the time profiler and make some changes to how we define parsers to unlock even more speed.
""",
    codeSampleDirectory: "0129-parsing-performance-pt3",
    exercises: _exercises,
    id: 129,
    image: "TODO",
    length: 39*60 + 19,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1607925600),
    references: [
      .swiftBenchmark
    ],
    sequence: 129,
    subtitle: "TODO",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 0, // TODO
      vimeoId: 0, // TODO
      vimeoSecret: "TODO"
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
