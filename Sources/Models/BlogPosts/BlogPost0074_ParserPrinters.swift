import Foundation

public let post0074_ParserPrinters = BlogPost(
  author: .pointfree,
  blurb: """
    A new release of swift-parsing brings printing capabilities to your parsers for transforming structured data back into unstructured data.
    """,
  contentBlocks: [
    .init(
      content: #"""
        We are excited to release [0.9.0][0_9_0] of our [swift-parsing][swift-parsing] library, which brings printing capabilities to parsers, allowing them to transform structured data back into unstructured data. This is useful for serializating your data types, sending data over the network, routing on servers and clients, and more. It's our biggest update to the library yet, so join us for a quick overview, and be sure to check out the [free][episode] video tour we are releasing this week.

        ## Parsing

        Parsing is the process of turning unstructured data into structure data. Swift comes with a few tools for small parsing problems, such as initializing integers from strings, extracting dates from strings, as well as JSON decoding.

        Our library allows you to create your own custom parsers from small, composable units. For example, suppose we wanted to parse the following string (which comes from the 2021 Advent of Code challenge [#13][aoc13]) into some first class Swift data types:

        ```swift
        let input = """
        6,10
        0,14
        9,10
        0,3
        10,4
        4,11
        6,0
        6,12
        4,1
        0,13
        10,12
        3,4
        3,0
        8,4
        1,10
        2,14
        8,10
        9,0

        fold along y=7
        fold along x=5
        """
        ```

        We could start by doing a little domain modeling to figure out the data types we want to extract from this string:

        ```swift
        struct Dot {
          let x, y: Int
        }
        enum Direction: String, CaseIterable {
          case x, y
        }
        struct Fold {
          let direction: Direction
          let position: Int
        }
        struct Instructions {
          let dots: [Dot]
          let folds: [Fold]
        }
        ```

        A parser for this textual format can be constructed by defining a few small parsers that attack simpler problems, and then pieced together to attack the full format. For example, we can parse a single dot from the input via:

        ```swift
        let dot = Parse(Dot.init) {
          Digits()
          ","
          Digits()
        }
        ```

        And then we can parse multiple dots using the `Many` parser to run the `dot` parser many times:

        ```swift
        let dots = Many {
          dot
        } separator: {
          "\n"
        }
        ```

        Similarly a parser that can extract a single line of fold information can be constructed like so:

        ```swift
        let fold = Parse(Fold.init) {
          "fold along "
          Direction.parser()
          "="
          Digits()
        }
        ```

        And we can parse multiple folds using `Many` again:

        ```swift
        let folds = Many {
          fold
        } separator: {
          "\n"
        }
        ```

        And with those smaller parsers we can now construct a parser that works on the entire input:

        ```swift
        let instructions = Parse(Instructions.init) {
          dots
          "\n\n"
          folds
        }
        ```

        In just 26 lines of code we have written a parser that can extract first class Swift data types from an unstructured blob of text:

        ```swift
        try instructions.parse(input) // Instructions(dots: […], folds: […])
        ```

        ## Printing

        Sometimes we need to be able to do the _inverse_ of parsing, also called printing. This allows you to turn your structured Swift data types back into unstructured data.

        There are only 3 small changes that need to be made to the instructions parser above to turn it into a printer:

        ```diff
        - let fold = Parse(Fold.init) {
        + let fold = ParsePrint(.memberwise(Fold.init)) {

        - let fold = Parse(Fold.init) {
        + let fold = ParsePrint(.memberwise(Fold.init)) {

        - let instructions = Parse(Instructions.init) {
        + let instructions = ParsePrint(.memberwise(Instructions.init)) {
        ```

        These changes give the types enough information to know how to perform a bidirectional transformation, which is what enables printing capabilities. And with those 3 small changes we can now print an `Instructions` value back to a string:

        ```swift
        instructions.print(
          Instructions(
            dots: [.init(x: 3, y: 1), .init(x: 1, y: 0), .init(x: 2, y: 2)],
            folds: [.init(direction: .x, position: 1), .init(direction: .y, position: 2)]
          )
        )
        // 3,1
        // 1,0
        // 2,2
        //
        // fold along x=1
        // fold along y=2
        ```

        ## Check it out today

        This is only scratching the surface. There is _a lot_ more offered in the library. Check out our [video tour][episode] for more information, and give the [library][swift-parsing] a spin to explore its new capabilities.

        [aoc13]: https://adventofcode.com/2021/day/13
        [episode]: /episodes/ep185-tour-of-parser-printers-introduction
        [swift-parsing]: https://github.com/pointfreeco/swift-parsing
        [0_9_0]: https://github.com/pointfreeco/swift-parsing/releases/0.9.0
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 74,
  publishedAt: Date(timeIntervalSince1970: 1_649_653_200),
  title: "Parser-printer unification"
)
