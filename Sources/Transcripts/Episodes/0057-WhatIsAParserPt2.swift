import Foundation

extension Episode {
  static let ep57_whatIsAParser_pt2 = Episode(
    blurb: """
      Now that we've looked at a bunch of parsers that are at our disposal, let's ask ourselves what a parser really is from the perspective of functional programming and functions. We'll take a multi-step journey and optimize using Swift language features.
      """,
    codeSampleDirectory: "0057-what-is-a-parser-pt2",
    exercises: _exercises,
    id: 57,
    length: 20 * 60 + 36,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1_557_727_200),
    references: [
      .parseDontValidate,
      .ledgeMacAppParsingTechniques,
      .swiftStringsAndSubstrings,
      .swiftPitchStringConsumption,
      .difficultiesWithEfficientLargeFileParsing,
    ],
    sequence: 57,
    title: "What Is a Parser?: Part 2",
    trailerVideo: .init(
      bytesLength: 38_834_749,
      downloadUrls: .s3(
        hd1080: "0057-trailer-1080p-a6872fe62c8a43b081397fe8149d12b8",
        hd720: "0057-trailer-720p-35a5a19f04544bc3af56c86d73653650",
        sd540: "0057-trailer-540p-a5d208643b1e40dd90e90551802c5443"
      ),
      id: "479e407309d3150214695a813c9ebab9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Create a parser `char: Parser<Character>` that will parser a single character off the front of the input string.
      """),
  .init(
    problem: """
      Create a parser `whitespace: Parser<Void>` that consumes all of the whitespace from the front of the input string. Note that this parser is of type `Void` because we probably don't care about the actual whitespace we consumed, we just want it consumed.
      """),
  .init(
    problem: """
      Right now our `int` parser doesn't work for negative numbers, for example `int.run("-123")` will fail. Fix this deficiency in `int`.
      """),
  .init(
    problem: """
      Create a parser `double: Parser<Double>` that consumes a double from the front of the input string.
      """),
  .init(
    problem: """
      Define a function `literal: (String) -> Parser<Void>` that takes a string, and returns a parser which will parse that string from the beginning of the input. This exercise shows how you can build complex parsers: you can use a function to take some up-front configuration, and then use that data in the definition of the parser.
      """),
  .init(
    problem: """
      In this episode we mentioned that there is a correspondence between functions of the form `(A) -> A` and functions `(inout A) -> Void`. We even covered this in a previous episode, but it is instructive to write it out again. So, define two functions `toInout` and `fromInout` that will transform functions of the form `(A) -> A` to functions `(inout A) -> Void`, and vice-versa.
      """),
]
