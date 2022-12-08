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

        Our [0.11.0][0_11_0] release includes fewer limitations placed on parser builders, primary
        associated types, and the ability to use formatters (including date formatters, number
        formatters, and all the rest) in your parsers and parser printers.

        ## More flexible builders

        Parsing's builders have limited the number of parsers allowed in a block because of a great
        number of overloads that need to be maintained and even generated.

        `OneOfBuilder`, which tries each parser given to the block till one succeeds, was previously
        limited to 10 parsers, which is similar to the limit SwiftUI imposes on `ViewBuilder`
        blocks.

        ```swift
        TODO: example?
        ```

        `ParserBuilder`, which breaks parsing jobs down into small incremental steps for each parser
        passed to the block, was previously limited to only 6 parsers due to an exponential number
        of `buildBlock` overloads that had to be code-generated: _hundreds_ of overloads were
        required to support 6 parsers in a block, and _thousands_ would have been required to
        support 7 or more!

        <!-- TODO: link to old generated file -->

        This limitation broke down quickly.

        <!-- TODO: example? workaround using nested? -->

        Thankfully, Swift 5.7 comes with a brand new result builder feature called
        [`buildPartialBlock`][se-0348], which allows us to eliminate many of these restrictions and
        overloads, improving library ergonomics and compile times!

        `OneOfBuilder` no longer has a limit at all: you can simply list as many parsers as needed
        (or as many as the Swift compiler can handle).

        <!-- TODO: example? -->

        `ParserBuilder` now supports 10 _or more_ parsers in a block: up to 10 parsers that capture
        output data, like integers, bools, and more, and an unlimited number of parsers that don't,
        which includes common parsers like string literals.

        ## Primary associated type support

        Parsing is powered by a number of protocols with associated types, including:

          * The `Parser` protocol, which is the fundamental unit of the library, and describes
            transforming a blob of nebulous data into something more structured.

          * The `ParserPrinter` protocol, which inherits from `Parser` but comes with a superpower:
            it can "print" structured data back into the nebulous blob from whence it came.

          * The `Conversion` protocol, which parser-printers leverage for transforming parsed data
            in a reversible way.

          * The `PrependableCollection` protocol, which parser-printers use to reverse the process
            of parsing. <!-- TODO: link/describe the mindbendy nature of printers? -->

        All four of these protocols have associated types that should take advantage of Swift 5.7's
        new [primary associated types][se-0346]:

          * `Parser<Input, Output>`
          * `ParserPrinter<Input, Output>`
          * `Conversion<Input, Output>`
          * `PrependableCollection<Element>`

        This change allows you to express and constrain these protocols in a more lightweight,
        natural manner, especially with the use of opaque `some` types:

        <!-- TODO: example of returning `some Parser<Substring, _>`? -->

        ## `Formatter` parser-printer

        We've also introduced a brand-new `Formatter` parser-printer, which is compatible with
        Apple's entire formatter family, including byte formatters, date formatters,
        number formatters, and many more!

        <!-- TODO: better example? -->

        ```swift
        let total = ParsePrint {
          "TOTAL: "
          Formatted(.currency(code: "USD"))
        }

        try total.parse("TOTAL: $42.42")  // 42.42
        try total.print(99.95)            // "TOTAL: $99.95"
        ```

        ## Check it out today

        This is only scratching the surface. There is _a lot_ more offered in the library. Check out our [video tour][episode] for more information, and give the [library][swift-parsing] a spin to explore its new capabilities.

        [0_11_0]: https://github.com/pointfreeco/swift-parsing/releases/0.11.0
        [aoc2022]: https://adventofcode.com/2022
        [aoc2022d4]: https://adventofcode.com/2022/day/4
        [episode]: /episodes/ep185-tour-of-parser-printers-introduction
        [se-0346]: https://github.com/apple/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md
        [se-0348]: https://github.com/apple/swift-evolution/blob/main/proposals/0348-buildpartialblock.md
        [swift-parsing]: https://github.com/pointfreeco/swift-parsing
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 74,
  publishedAt: Date(timeIntervalSince1970: 1_670_526_000),
  title: "swift-parsing: Swift 5.7 improvements"
)
