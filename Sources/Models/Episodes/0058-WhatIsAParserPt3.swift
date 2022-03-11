import Foundation

extension Episode {
  static let ep58_whatIsAParser_pt3 = Episode(
    blurb: """
It's time to ask the all important question: what's the point? We now have a properly defined parser type, one that can parse efficiently and incrementally, but does it give us anything new over existing tools?
""",
    codeSampleDirectory: "0058-what-is-a-parser-pt3",
    exercises: _exercises,
    id: 58,
    length: 20*60 + 0,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1558332000),
    references: [
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
      .swiftStringsAndSubstrings,
      .swiftPitchStringConsumption,
      .difficultiesWithEfficientLargeFileParsing,
      .scannerAppleDocs,
      .nsscannerNsHipster,
    ],
    sequence: 58,
    title: "What Is a Parser?: Part 3",
    trailerVideo: .init(
      bytesLength: 23586284,
      downloadUrls: .s3(
        hd1080: "0058-trailer-1080p-945ae67ff8ba4a57a7f82b6f1c08b489",
        hd720: "0058-trailer-720p-3c28aded19e84d4a88d855fb6d026217",
        sd540: "0058-trailer-540p-97b62b397cc74826b53b60939ad737b2"
      ),
      vimeoId: 348472576
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Right now all of our parsers (`int`, `double`, `literal`, etc.) are defined at the top-level of the file, hence they are defined in the module namespace. While that is completely fine to do in Swift, it can sometimes improve the ergonomics of using these values by storing them as static properties on the `Parser` type itself. We have done this a bunch in previous episodes, such as with our `Gen` type and `Snapshotting` type.

Move all of the parsers we have defined so far to be static properties on the `Parser` type. You will want to suitably constrain the `A` generic in the extension in order to further restrict how these parsers are stored, i.e. you shouldn't be allowed to access the integer parser via `Parser<String>.int`.
"""),
  .init(problem: """
We have previously devoted an entire episode ([here](/episodes/ep13-the-many-faces-of-map)) to the concept of `map`, then 3 entire episodes ([part 1](/episodes/ep23-the-many-faces-of-zip-part-1), [part 2](/episodes/ep24-the-many-faces-of-zip-part-2), [part 3](/episodes/ep25-the-many-faces-of-zip-part-3)) to `zip`, and _then_ 5 (!) entire episodes ([part 1](/episodes/ep42-the-many-faces-of-flat-map-part-1), [part 2](/episodes/ep43-the-many-faces-of-flat-map-part-2), [part 3](/episodes/ep44-the-many-faces-of-flat-map-part-3), [part 4](/episodes/ep45-the-many-faces-of-flat-map-part-4), [part 5](/episodes/ep46-the-many-faces-of-flat-map-part-5)) to `flatMap`. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.

Define `map`, `zip` and `flatMap` on the `Parser` type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume _any_ of the input string if the parser fails.
"""),
  .init(problem: """
Create a parser `end: Parser<Void>` that simply succeeds if the input string is empty, and fails otherwise. This parser is useful to indicate that you do not intend to parse anymore.
"""),
  .init(problem: """
Implement a function that takes a predicate `(Character) -> Bool` as an argument, and returns a parser `Parser<Substring>` that consumes from the front of the input string until the predicate is no longer satisfied. It would have the signature `func pred: ((Character) -> Bool) -> Parser<Substring>`.
"""),
  .init(problem: """
Implement a function that transforms any parser into one that does not consume its input at all. It would have the signature `func nonConsuming: (Parser<A>) -> Parser<A>`.
"""),
  .init(problem: """
Implement a function that transforms a parser into one that runs the parser many times and accumulates the values into an array. It would have the signature `func many: (Parser<A>) -> Parser<[A]>`.
"""),
  .init(problem: """
Implement a function that takes an array of parsers, and returns a new parser that takes the result of the first parser that succeeds. It would have the signature `func choice: (Parser<A>...) -> Parser<A>`.
"""),
  .init(problem: """
Implement a function that takes two parsers, and returns a new parser that returns the result of the first if it succeeds, otherwise it returns the result of the second. It would have the signature `func either: (Parser<A>, Parser<B>) -> Parser<Either<A, B>>` where `Either` is defined:
```
enum Either<A, B> {
  case left(A)
  case right(B)
}
```
"""),
  .init(problem: """
Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the first and discards the second. It would have the signature `func keep(_: Parser<A>, discard: Parser<B>) -> Parser<A>`. Make sure to not consume any of the input string if either of the parsers fail.
"""),
  .init(problem: """
Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the second and discards the first. It would have the signature `func discard(_: Parser<A>, keep: Parser<B>) -> Parser<B>`. Make sure to not consume any of the input string if either of the parsers fail.
"""),
  .init(problem: """
Implement a function that takes two parsers and returns a new parser that returns of the first if it succeeds, otherwise it returns the result of the second. It would have the signature `func choose: (Parser<A>, Parser<A>) -> Parser<A>`. Consume as little of the input string when implementing this function.
"""),
  .init(problem: """
Generalize the previous exercise by implementing a function of the form `func choose: ([Parser<A>]) -> Parser<A>`.
"""),
  .init(problem: """
Right now our parser can only fail in a single way, by returning `nil`. However, it can often be useful to have parsers that return a description of what went wrong when parsing.

Generalize the `Parser` type so that instead of returning an `A?` value it returns a `Result<A, String>` value, which will allow parsers to describe their failures. Update all of our parsers and the ones in the above exercises to work with this new type.
"""),
  .init(problem: """
Right now our parser only works on strings, but there are many other inputs we may want to parse. For example, if we are making a router we would want to parse `URLRequest` values.

Generalize the `Parser` type so that it is generic not only over the type of value it produces, but also the type of values it parses. Update all of our parsers and the ones in the above exercises to work with this new type (you may need to constrain generics to work on specific types instead of all possible input types).
"""),
]
