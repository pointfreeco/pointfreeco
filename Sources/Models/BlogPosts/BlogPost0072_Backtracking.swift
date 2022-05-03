import Foundation

public let post0072_Backtracking = BlogPost(
  author: .pointfree,
  blurb: """
    """,
  contentBlocks: [
    .init(
      content: """
        Today we are releasing [0.6.0][0_6_0] of our [swift-parsing](https://github.com/pointfreeco/swift-parsing) library that changes its backtracking behavior. Most users of the library will not notice a difference, though some of your parsers may start to run slightly faster. If you are interested in why we made this decision, then read on!

        ## What is backtracking?

        Backtracking in parsing is the process of restoring the input to its original state when it fails. From the first release of [swift-parsing](https://github.com/pointfreeco/swift-parsing) we made each parser responsible for backtracking its input upon failure. For example, the `Many` parser keeps [track][many-capture] of the original input so that if something goes wrong we can [restore][many-restore] the input to its original state.

        A more complex example is the [`.flatMap`][flatmap-source-file] operator. This operator allows you to run one parser after another such that the second parser can use the output of the first to customize its logic. In order to implement this parser with backtracking we need to check if something fails after each step of the sequence so that we can restore the original input:

        ```swift
        public func parse(_ input: inout Upstream.Input) -> NewParser.Output? {
          let original = input
          guard let newParser = self.upstream.parse(&input).map(self.transform)
          else {
            input = original
            return nil
          }
          guard let output = newParser.parse(&input)
          else {
            input = original
            return nil
          }
          return output
        }
        ```

        ## Why remove backtracking?

        Making parsers responsible for backtracking seems reasonable, but in practice was fraught. At best, if done correctly, it meant that your parser was littered with additional logic not related to parsing in order to properly restore the input to its original state. For example, removing backtracking from the `.flatMap` parser above greatly simplifies the parser's logic:

        ```swift
        public func parse(_ input: inout Upstream.Input) -> NewParser.Output? {
          self.upstream.parse(&input).map(self.transform)?.parse(&input)
        }
        ```

        And at worst, backtracking in each parser could could be done incorrectly, or not at all, which would lead to subtle bugs where some parsers backtrack and some do not.

        So, this is why we decided to remove the requirement that parsers individually implement backtracking logic. Backtracking is still useful, but if you need backtracking you can use a dedicated parser for it: [`OneOf`][oneof-source-file]. It's a parser that tries multiple parsers on the same input. If one fails, it backtracks the input to its original state, and if one succeeds, then that output is returned and no other parsers are tried.

        This coalesces all backtracking responsibilities into a single parser, which allows you, the library user, to decide when and where you want backtracking.

        ## Does this affect me?

        Most likely it does not. If you only use the parsers and operators that ship with the library you will probably not notice any different behavior in your parsers.

        If you implement custom parsers, meaning you create new types that conform to the `Parser` protocol, then you no longer need additional logic for tracking the orginal input and restoring it when parsing fails. You can just leave the partially consumed input as-is.

        And regardless of whether you implement custom parsers or not, it can be a good idea to be mindful of how backtracking affects the performance of your parsers. If used naively, backtracking can lead to less performant parsing code. For example, if we wanted to parse two integers from a string that were separated by either a dash "-" or slash "/", then we could write this as:

        ```swift
        OneOf {
          Parse { Int.parser(); "-"; Int.parser() } // 1️⃣
          Parse { Int.parser(); "/"; Int.parser() } // 2️⃣
        }
        ```

        However, parsing slash-separated integers is not going to be performant because it will first run the entire 1️⃣ parser until it fails, then backtrack to the beginning, and run the 2️⃣ parser. In particular, the first integer will get parsed twice, unnecessarily repeating that work.

        On the other hand, we can factor out the common work of the parser and localize the backtracking `OneOf` work:

        ```swift
        Parse {
          Int.parser()
          OneOf { "-"; "/" }
          Int.parser()
        }
        ```

        This is a much more performant parser.

        # Try it today

        Update your projects to use [0.6.0][0_6_0] of swift-parsing today, and [let us know][swift-parsing-discussions] if you encountered any strange behavior that you did not expect.

        [0_6_0]: https://github.com/pointfreeco/swift-parsing/releases/tag/0.6.0
        [many-capture]: https://github.com/pointfreeco/swift-parsing/blob/56215fb35c87da4f7b7aff1820d8ef5732465eb4/Sources/Parsing/Parsers/Many.swift#L79
        [many-restore]: https://github.com/pointfreeco/swift-parsing/blob/56215fb35c87da4f7b7aff1820d8ef5732465eb4/Sources/Parsing/Parsers/Many.swift#L121-L124
        [flatmap-source-file]: https://github.com/pointfreeco/swift-parsing/blob/main/Sources/Parsing/Parsers/FlatMap.swift
        [oneof-source-file]: https://github.com/pointfreeco/swift-parsing/blob/main/Sources/Parsing/Parsers/OneOf.swift
        [swift-parsing-discussions]: https://github.com/pointfreeco/swift-parsing/discussions
        """,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 72,
  publishedAt: Date(timeIntervalSince1970: 1_644_386_400),
  title: "Backtracking Parsers"
)
