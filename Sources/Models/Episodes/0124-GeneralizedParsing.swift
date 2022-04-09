import Foundation

extension Episode {
  public static let ep124_generalizedParsing = Episode(
    blurb: """
The parser type we built so far is highly tuned to work on strings, but there are many things out in the world we’d want to parse, not just strings. It’s time to massively generalize parsing so that it can parse any kind of input into any kind of output.
""",
    codeSampleDirectory: "0124-generalized-parsing-pt1",
    exercises: _exercises,
    id: 124,
    length: 33*60 + 14,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1604901600),
    references: [
    ],
    sequence: 124,
    subtitle: "Part 1",
    title: "Generalized Parsing",
    trailerVideo: .init(
      bytesLength: 37998071,
      downloadUrls: .s3(
        hd1080: "0124-trailer-1080p-0e27539234aa4ff4b2159778f486be4d",
        hd720: "0124-trailer-720p-b62c4e65711b42fe9ae3f0185ee93943",
        sd540: "0124-trailer-540p-a8e889af34a14d75a7e3b8dc59375fa8"
      ),
      vimeoId: 475526775
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Generalize `prefix(while:)` to not just work on substrings, but any `Collection`.
"""#,
    solution: #"""
```swift
extension Parser
where
  Input: Collection,
  Input.SubSequence == Input,
  Output == Input
{
  static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
    Self { input in
      let output = input.prefix(while: p)
      input.removeFirst(output.count)
      return output
    }
  }
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Generalize `prefix(upTo:)` and `prefix(through:)` to not just work on substrings, but any `Collection`.
"""#,
    solution: #"""
These are a bit trickier because there is no `range(of:)` operation on `Collection`. We can recover this behavior with a combination of `starts(with:)` and `removeFirst()` to advance the input's start index for each check:

```swift
extension Parser
where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element: Equatable,
  Output == Input
{
  static func prefix(upTo subsequence: Input) -> Self {
    Self { input in
      guard !subsequence.isEmpty else { return subsequence }
      let original = input
      while !input.isEmpty {
        if input.starts(with: subsequence) {
          return original[..<input.startIndex]
        }
        input.removeFirst()
      }
      input = original
      return nil
    }
  }
}
```

Similarly can be done with `prefix(through:)`.

```swift
extension Parser
where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element: Equatable,
  Output == Input
{
  static func prefix(through subsequence: Input) -> Self {
    Self { input in
      guard !subsequence.isEmpty else { return subsequence }
      let original = input
      while !input.isEmpty {
        if input.starts(with: subsequence) {
          let index = input.index(input.startIndex, offsetBy: subsequence.count)
          input = input[index...]
          return original[..<index]
        }
        input.removeFirst()
      }
      input = original
      return nil
    }
  }
}
```
"""#
  ),
//  Episode.Exercise(
//    problem: #"""
//Benchmark your generalizations above using [swift-benchmark](https://github.com/google/swift-benchmark). If the generalizations are slower, what possible changes can be made to improve performance?
//"""#,
//    solution: #"""
//"""#
//  ),
]
