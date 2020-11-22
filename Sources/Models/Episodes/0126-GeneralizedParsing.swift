import Foundation

extension Episode {
  public static let ep126_generalizedParsing = Episode(
    blurb: """
Generalizing the parser type has unlocked some interesting things, like the ability to parse arrays and dictionaries, and even serve as a URL router, but it also introduces some additional complexity. Was it worth the cost? Do the benefits of generalizing stop here?
""",
    codeSampleDirectory: "0126-generalized-parsing-pt3",
    exercises: _exercises,
    id: 126,
    image: "TODO",
    length: 36*60 + 29,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1606111200),
    references: [
    ],
    sequence: 126,
    subtitle: "Part 3",
    title: "Generalized Parsing",
    trailerVideo: .init(
      bytesLength: 0,
      vimeoId: 0,
      vimeoSecret: "TODO"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Implement the following method on `Parser`:

```swift
extension Parser {
  func f<NewOutput>(_ parser: Parser<Output, NewOutput>) -> Parser<Input, NewOutput> {
    fatalError("unimplemented")
  }
}
```

What might this method be useful for?
"""#,
    solution: #"""
```swift
extension Parser {
  func f<NewOutput>(_ parser: Parser<Output, NewOutput>) -> Parser<Input, NewOutput> {
    .init { input in
      let original = input
      guard var output = self.run(&input) else { return nil }
      guard let newOutput = parser.run(&output) else {
        input = original
        return nil
      }
      return newOutput
    }
  }
}
```
"""#
  ),  Episode.Exercise(
    problem: #"""
Swift strings have a lower-level representation called `UnicodeScalarView` that can be more performant to work with. Generalize `Parser.int` to parse `Substring.UnicodeScalarView`:

```swift
extension Parser where Input == Substring.UnicodeScalarView, Output == Int {
  static let int = Self { input in
    fatalError("unimplemented")
  }
}

let string = "123 Hello"
var input = string[...].unicodeScalars
precondition(Parser.int.run(&input) == 123)
precondition(Substring(unicodeScalars) == " Hello")
```

How do the performance characteristics compare with `Substring`?
"""#,
    solution: #"""
Stay tuned for the solution in coming episodes!
"""#
  ),
  Episode.Exercise(
    problem: #"""
Even lower-level than `UnicodeScalarView` is `UTF8View`. Generalize `Parser.int` to parse `Substring.UTF8View`:

```swift
extension Parser where Input == Substring.UTF8View, Output == Int {
  static let int = Self { input in
    fatalError("unimplemented")
  }
}

let string = "123 Hello"
var input = string[...].unicodeScalars
precondition(Parser.int.run(&input) == 123)
precondition(Substring(unicodeScalars) == " Hello")
```

How do the performance characteristics compare with `Substring` and `Substring.UnicodeScalarView`?
"""#,
    solution: #"""
Stay tuned for the solution in coming episodes!
"""#
  ),
]
