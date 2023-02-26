import Foundation

public let post0087_ParsingSwift57 = BlogPost(
  author: .pointfree,
  blurb: """
    In time for Advent of Code, a new release of swift-parsing brings several quality-of-life
    improvements to Swift 5.7 users.
    """,
  contentBlocks: [
    .init(
      content: #"""
        It's the season of [Advent of Code][aoc2022], and over the years, many reach for [our
        Parsing library][swift-parsing] to solve its puzzles. So we wanted to take the time to make
        their experience a bit nicer this year by bringing in several quality-of-life improvements
        to Swift 5.7 users.

        Our [0.11.0][0_11_0] release removes many limitations placed on parser builders in the
        previous release of the library, as well as introduces primary associated types, and
        the ability to use formatters (_e.g._, date formatters, number formatters, and more) in your
        parsers and parser-printers.

        ## More flexible builders

        The library's builders have limited the number of parsers allowed in a block because of a
        great number of overloads that need to be maintained and code generated, causing a bloat in
        binary size and compilation times.

        For example, `@OneOfBuilder`, which tries each parser given to the block till one succeeds,
        was previously limited to 10 parsers, which is similar to the limit SwiftUI imposes on
        `ViewBuilder` blocks. This means if you were trying to parse an input string into an enum
        with more than 10 cases, you would need to nest the `OneOf` parsers to get around this
        limitation:

        ```swift
        let router = OneOf {
          OneOf {
            // ...
          }
          OneOf {
            // ...
          }
          OneOf {
            // ...
          }
        }
        ```

        Meanwhile, `@ParserBuilder`, which breaks parsing jobs down into small incremental steps for
        each parser passed to the block, was previously limited to only 6 parsers due to an
        exponential number of `buildBlock` overloads that had to be [code
        generated][code-gen-script]: [_hundreds_][code-gen-file] of overloads were required to
        support 6 parsers in a block, and _thousands_ would be required to support 7 or more!

        This limitation broke down quickly. For example, to parse a parentheses-surrounded and
        comma-separated set of values into a `User` type, you should be able to do this:

        ```swift
        let user = Parse(User.init) {
          "("
          Int.parser()
          ","
          Prefix { $0 != "," }
          ","
          Bool.parser()
          ")" 
        }
        ```

        But, that parser fails to compile because it is combining 7 parsers. To work around this
        limitation you would need to nest the `Parse` builder contexts:

        ```swift
        let user = Parse {
          "("
          Parse(User.init) {
            Int.parser()
            ","
            Prefix { $0 != "," }
            ","
            Bool.parser()
          }
          ")"
        }
        ```

        Thankfully, Swift 5.7 comes with a brand new result builder feature called
        [`buildPartialBlock`][se-0348], which allows us to eliminate many of these restrictions and
        overloads, and improve library ergonomics, compile times, and even binary size!

        `@OneOfBuilder` no longer has a limit at all: you can simply list as many parsers as needed
        (or as many as the Swift compiler can handle).

        And `@ParserBuilder` now supports any number of `Void` parsers and up to 10 non-`Void`
        parsers. While it is still limited, it is not nearly as bad as it used to be since the
        majority of parsers in a builder context tend to be `Void`-parsers. For example, in the
        `user` parser above, 4 of the 7 parsers are `Void`.

        ## Primary associated type support

        Parsing is powered by a number of protocols with associated types, including:

          * The `Parser` protocol, which is the fundamental unit of the library, and describes
            transforming a blob of nebulous data into something more structured.

          * The `ParserPrinter` protocol, which inherits from `Parser` but comes with a superpower:
            it can "print" structured data back into the nebulous blob from whence it came.

          * The `Conversion` protocol, which parser-printers leverage for transforming parsed data
            in an invertible way.

          * The `PrependableCollection` protocol, which parser-printers use to reverse the process
            of parsing. This is a strange protocol that even [took us a long time][bizarro] to
            grapple with its mind-bending nature.

        All four of these protocols have associated types that should take advantage of Swift 5.7's
        new [primary associated types][se-0346]:

          * `Parser<Input, Output>`
          * `ParserPrinter<Input, Output>`
          * `Conversion<Input, Output>`
          * `PrependableCollection<Element>`

        This change allows you to express and constrain these protocols in a more lightweight,
        natural manner, especially with the use of opaque `some` types.

        ## `Formatted` parser-printer

        We've also introduced a brand-new `Formatted` parser-printer, which is compatible with
        Apple's entire family of formatters, including byte formatters, date formatters, number
        formatters, and many more!

        Simply pass the formatter to `Formatted` to take advantage of many of the complex formats
        Apple provides for us.

        ```swift
        let total = ParsePrint {
          "TOTAL: "
          Formatted(.currency(code: "USD"))
        }

        try total.parse("TOTAL: $42.42")  // 42.42
        try total.print(99.95)            // "TOTAL: $99.95"
        ```

        ## Check it out today

        This is only scratching the surface. There is _a lot_ more offered in the library. Check out
        our [free video tour][episode] for more information, and give the [library][swift-parsing] a
        spin to explore its new capabilities.

        [0_11_0]: https://github.com/pointfreeco/swift-parsing/releases/0.11.0
        [aoc2022]: https://adventofcode.com/2022
        [aoc2022d4]: https://adventofcode.com/2022/day/4
        [episode]: /episodes/ep185-tour-of-parser-printers-introduction
        [se-0346]: https://github.com/apple/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md
        [se-0348]: https://github.com/apple/swift-evolution/blob/main/proposals/0348-buildpartialblock.md
        [swift-parsing]: https://github.com/pointfreeco/swift-parsing
        [code-gen-script]: https://github.com/pointfreeco/swift-parsing/blob/0.10.0/Sources/variadics-generator/VariadicsGenerator.swift
        [code-gen-file]: https://github.com/pointfreeco/swift-parsing/blob/0.10.0/Sources/Parsing/Builders/Variadics.swift
        [bizarro]: /collections/parsing/invertible-parsing/ep183-invertible-parsing-bizarro-printing
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 87,
  publishedAt: Date(timeIntervalSince1970: 1_670_479_200),
  title: "swift-parsing: Swift 5.7 improvements"
)
