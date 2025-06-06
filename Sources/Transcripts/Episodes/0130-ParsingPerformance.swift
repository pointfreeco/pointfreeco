import Foundation

extension Episode {
  public static let ep130_parsingPerformance = Episode(
    blurb: """
      It is well accepted that hand-rolled, imperative parsers are vastly more performant than parsers built with combinators. However, we show that by employing all of our performance tricks we can get within a stone's throw of the performance of imperative parsers, and with much more maintainable code.
      """,
    codeSampleDirectory: "0130-parsing-performance-pt4",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 669_202_779,
      downloadUrls: .s3(
        hd1080: "0130-1080p-cd19e779684f415da33ff53c102247f2",
        hd720: "0130-720p-56e963e7f6f540a58344c452138f9c3f",
        sd540: "0130-540p-9b7ae744c9494f58b05323927d79eac3"
      ),
      id: "d564484aea57131c5414777a98bbb37a"
    ),
    id: 130,
    length: 58 * 60 + 46,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_608_530_400),
    references: [
      .init(
        author: "Chris Eidhof & Florian Kugler",
        blurb: """
          This [Swift Talk](https://talk.objc.io) episode was the inspiration for two of the CSV parsers we built in this episode, and formed the basis of how we could compare combinator-style parsing with imperative-style parsing.

          > We show a parsing technique that we use for many parsing tasks in our day-to-day work.
          """,
        link: "https://talk.objc.io/episodes/S01E170-parsing-with-mutating-methods",
        publishedAt: yearMonthDayFormatter.date(from: "2019-09-20"),
        title: "Parsing with Mutating Methods"
      ),
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
    ],
    sequence: 130,
    subtitle: "The Point",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 64_504_653,
      downloadUrls: .s3(
        hd1080: "0130-trailer-1080p-f952d430eaff4095a83fac1bfcffef87",
        hd720: "0130-trailer-720p-76730843c6b145b48252c7edff0c0c7c",
        sd540: "0130-trailer-540p-388bab40b2fd452b91d59d68de52f524"
      ),
      id: "7f08120f6ee05bea17977c7e3cb4363f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Fix the unrolled loop parser, `loopParseCSV`, to properly trim leading and trailing double quotes from quoted fields. Update the benchmark's precondition to check this, as well.
      """#
  ),
  .init(
    problem: #"""
      The `OneOf` parser type we introduced has a nesting problem, which you can see if you try to use it with 3 or more parsers. For example, the `race` parser has a `currency` parser that will match `oneOf` 3 parsers:

      ```swift
      let currency = Parser<Substring, Currency>.oneOf(
        Parser.prefix("€").map { Currency.eur },
        Parser.prefix("£").map { .gbp },
        Parser.prefix("$").map { .usd }
      )
      ```

      What does it look like to define this parser using `OneOf`?

      In order to solve this problem, extend `ParserProtocol` with a method version of `OneOf` called `orElse` that simply wraps the `OneOf` initializer. How does this improve the ergonomics of `currency`?
      """#,
    solution: #"""
      There are two equivalent ways of defining `currency` using the `ParserProtocol` types we've defined:

      ```swift
      // 1:
      let currency = OneOf(
        OneOf(
          Prefix<Substring>("€").map { Currency.eur },
          Prefix("£").map { .gbp }
        ),
        Prefix("$").map { .usd }
      )

      // 2:
      let currency = OneOf(
        Prefix<Substring>("€").map { Currency.eur },
        OneOf(
          Prefix("£").map { .gbp },
          Prefix("$").map { .usd }
        )
      )
      ```

      Luckily, a method will completely hide away the nesting of types. It can be defined in a similar matter to how we've defined other methods:

      ```swift
      extension ParserProtocol {
        func orElse<P>(_ other: P) -> OneOf<Self, P> {
          .init(self, other)
        }
      }
      ```

      Which let's us flatten that nesting with method chaining:

      ```swift
      let currency = Prefix<Substring>("€").map { Currency.eur }
        .orElse(Prefix("£").map { .gbp })
        .orElse(Prefix("$").map { .usd })
      ```
      """#
  ),
]
