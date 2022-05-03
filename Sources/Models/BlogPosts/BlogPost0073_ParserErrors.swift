import Foundation

public let post0073_ParserErrors = BlogPost(
  author: .pointfree,
  blurb: """
    A new release of swift-parsing that brings delightful and informative error messaging to parser failures.
    """,
  contentBlocks: [
    .init(
      content: #"""
        We are excited to release [0.7.0][0_7_0] of our [swift-parsing](https://github.com/pointfreeco/swift-parsing) library that brings delightful and informative error messaging to parser failures. This is a huge change to the library, and unfortunately is a breaking change, but continue reading to see how to migrate existing parsers and learn a new [trick](#rethrows) using an experimental Swift compiler feature.

        ## What's different?

        The most fundamental change is that the `Parser` protocol's single method requirement is now a throwing function rather an optional-returning function:

        ```diff
         public protocol Parser {
           associatedtype Input
           associatedtype Output
        -  func parse(_ input: inout Input) -> Output?
        +  func parse(_ input: inout Input) throws -> Output
         }
        ```

        From the beginning of swift-parsing we leaned on optionals as a very simple way to denote failure when parsing. That works well enough for simple parsers, but as parsers become more and more complex, a proper description and context is needed to understand where a parser failed and why.

        For example, if we want to parse a CSV formatted string into an array of `User` struct values:

        ```swift
        struct User {
          var id: Int
          var name: String
          var admin: Bool
        }

        let input = """
        1,Blob,true
        2,Blob Jr.,false
        3,Blob Sr.,tru
        """
        ```

        We can do so with a few seemingly-simple parsers:

        ```swift
        let user = Parse(User.init) {
          Int.parser()
          ","
          Prefix { $0 != "," }.map(String.init)
          ","
          Bool.parser()
        }

        let users = Many {
          user
        } separator: {
          "\n"
        } terminator: {
          End()
        }
        ```

        But, if we run our parser on the `input` value above we will find we only get `nil` instead of an array of users:

        ```swift
        let output = users.parser(input) // nil
        ```

        The reason for this is because we actually have a typo for the boolean in the last column of the last row of the CSV text:

        ```swift
        let input = """
        1,Blob,true
        2,Blob Jr.,false
        3,Blob Sr.,tru
        """
        ```

        That typo causes parsing to fail, but we have no information of what went wrong since the parser just returns `nil`. This can be really frustrating for large inputs where it can be difficult to find where the error is, especially when the error is literally the last character of the input.

        By making the `parse` method of the `Parser` protocol throwing we can contextualize the error message in a much better way. For example, calling the throwing `parse` method on the above malformed input:

        ```swift
        let output = try users.parse(input)
        ```

        An error is now thrown, and it shows exactly what went wrong, including pointing to the exact line and character where the error occured:

        ```
        caught error: "error: multiple failures occurred

        error: unexpected input
         --> input:3:11
        3 | 3,Blob Jr,tru
          |           ^ expected "true" or "false"

        error: unexpected input
         --> input:2:16
        2 | 2,Blob Sr,false
          |                ^ expected end of input"
        ```

        There are two errors printed because technically two things went wrong:

        * First and foremost the boolean parser failed to parse "tru".
        * Second, because the boolean parser failed it caused the `Many` parser to only consume the first 2 lines of the input text. This left additional input to be consumed, but we told our `Many` parser that it should consume the full input by using `End()` for its terminator.

        This can be incredibly handy for tracking down logical problems in your parsers or figuring out what is wrong with the input.

        ## Migrating from 0.6.0

        Unfortunately changing the `Parser` protocol's requirement to be throwing is a breaking change, and we're not sure there is a way to maintain backwards compatibility. But fortunately there are a few small things you can do to bring your code up-to-date.

        By far the most common use of parsers that will need to be migrated is when calling the `parse` method. To recapture that behavior you only need to `try?` the parsing:

        ```diff
        - let output = myParser.parse(&input)
        + let output = try? myParser.parse(&input)
        ```

        However, if you want to get access to the error message you can open a `do` block to try the parser, and when catching an error you can print it:

        ```swift
        do {
          output = try myParser.parser(&input)
        } catch {
          print(error)
        }
        ```

        A less common, but still important, use of parsers that will need to be migrated are custom conformances to the parser protocol.

        If you have a custom parser type, you will need to update its `parse` method to be throwing. Depending on the parser, this can give you an opportunity to clean up code. For instance, `Void` parsers no longer need to explicitly and awkwardly return an optional void value:

        ```diff
         struct End: Parser {
        -  func parse(_ input: inout Substring) -> Void? {
        +  func parse(_ input: inout Substring) throws {
             guard input.isEmpty else {
        -      return nil
        +      throw ...
             }
        -    return ()
           }
         }
        ```

        And parsers that call out to other parsers under the hood can prefer `try` over optional wrangling:

        ```diff
         struct Map<Upstream: Parser, NewOutput>: Parser {
           let upstream: Upstream
           let transform: (Upstream.Output) -> NewOutput

        -  func parse(_ input: inout Upstream.Input) -> NewOutput?
        -    guard let output = self.upstream.parse(&input)
        -    else { return nil }
        +  func parse(_ input: inout Upstream.Input) throws -> NewOutput {
        +    self.transform(try self.upstream.parse(&input))
           }
         }
        ```

        Notably, types can satisfy throwing protocol conformances without throwing themselves, which means if your parser cannot fail, you can drop the `throws` and `try` for parsers that can't fail.

        ```swift
        public struct Rest: Parser {
          public func parse(_ input: inout Substring) -> Input {
            let output = input
            input.removeFirst(input.count)
            return output
          }
        }

        // No need to `try`!
        Rest().parse("Hello!")  // "Hello!"
        ```

        This means you can even use the new `.replaceError(with:)` parser operator throughout your parsers to get compile-time guarantees that parsing can't fail.

        ```swift
        // No need to `try`!
        Int.parser().replaceError(with: 0).parse("!!!")  // 0
        ```

        All of the parsers and operators that ship with the library throw a concrete error whose type is not currently made public. It may be publicized in a future release, but for now we want more flexibility for changing the type without breaking backwards compatibility.

        However, you can still throw your own custom error messages and it will be reformatted and contextualized. For example, suppose we wanted a parser that only parsed the digits 0-9 from the beginning of a string and transformed it into an integer. This is subtly different from `Int.parser()` which allows for negative numbers.

        Constructing a `Digits` parser is easy enough, and we can introduce a custom struct error for customizing the message displayed:

        ```swift
        struct DigitsError: Error {
          let message = "Expected a prefix of digits 0-9"
        }

        struct Digits: Parser {
          func parse(_ input: inout Substring) throws -> Int {
            let digits = input.prefix { $0 >= "0" && $0 <= "9" }
            guard let output = Int(digits)
            else {
              throw DigitsError()
            }
            input.removeFirst(digits.count)
            return output
          }
        }
        ```

        If we swap out the `Int.parser` for a `Digits` parser in `user`:

        ```diff
         let user = Parse(User.init) {
        -  Int.parser()
        +  Digits()
           ","
           Prefix { $0 != "," }.map(String.init)
           ","
           Bool.parser()
         }
        ```

        And we introduce an incorrect value into the input:

        ```diff
          let input = """
          1,Blob,true
        - 2,Blob Jr.,false
        + -2,Blob Jr.,false
          3,Blob Sr.,true
          """
        ```

        Then when running the parser we get a nice error message that shows exactly what went wrong:

        ```
        error: DigitsError(message: "Expected a prefix of digits 0-9")
         --> input:2:1
        2 | -2,Blob Sr,false
          | ^
        ```

        <div id="rethrows"></div>

        ## `@rethrows`

        In this release, swift-parsing has adopted an experimental compiler feature known as [rethrowing protocol conformances][rethrowing-protocol-conformances] (Swift forums [post][rethrowing-protocol-conformances-forums]).

        As is well-known, non-throwing functions can satisfy throwing protocol requirements. This can be incredibly powerful, allowing protocol conformances to more correctly describe their behavior. However, rethrowing functions _cannot_ satisfy throwing protocol requirements. Take for instance the conformance of `Parsers.Map` to the `Parser` protocol:

        ```swift
        struct Map<Upstream: Parser, NewOutput>: Parser {
          let upstream: Upstream
          let transform: (Upstream.Output) -> NewOutput

          func parse(_ input: inout Upstream.Input) throws -> NewOutput {
            self.transform(try self.upstream.parse(&input))
          }
        }
        ```

        The `parse` method above is marked as `throws` even though it technically does not itself throw any errors. It only throws when `upstream` throws, and so if `upstream` does not throw then we would love if `Parsers.Map` could be inferred to not throw. That is exactly what `rethrows` allows us to do, but if we use it here:

        ```swift
        func parse(_ input: inout Upstream.Input) rethrows -> NewOutput {
          ...
        }
        ```

        > ❌ 'rethrows' function must take a throwing function argument

        We get an error that tells us we cannot use `rethrows` in this way. This means if you `.map` on a parser that does not fail you will get back a parser that fails, even though the compiler should statically know it's impossible to fail.

        For example, the `Whitespace` parser does not fail, and if we wanted to `.map` on it to count how much whitespace an input begins with we would unnecessarily turn it into a failing parser:

        ```swift
        let whitespaceCount = Whitespace().map(\.count)
        try whitespaceCount.parse("   Hello".utf8) // 3
        // Must use `try`, even though the parser cannot fail 😫
        ```

        This is a problem even in the Swift standard library. For example, the `IteratorProtocol` is designed like so:

        ```swift
        protocol IteratorProtocol {
          associatedtype Element

          mutating func next() -> Element?
        }
        ```

        This represents a stream of elements that can be pulled by invoking `next()`, and once the stream is empty it can return `nil` to signify completion.

        However, this means that pulling elements from a stream is never allowed to signify failure by throwing an error. This is not very realistic as many streams can fail. Even something as simple as reading lines from stdin can fail, and right now we would have to throw away any failures and just return `nil`:

        ```swift
        struct ReadLineIterator: IteratorProtocol {
          mutating func next() -> String? {
            try? readline()
          }
        }
        ```

        The `IteratorProtocol` was designed in this way because the compiler lacked rethrowing protocol conformances, just as we saw above with `Parsers.Map`. Ideally we could define `IteratorProtocol` with a throwing `next()` method like this:

        ```swift
        protocol IteratorProtocol {
          associatedtype Element

          mutating func next() throws -> Element?
        }
        ```

        And then conformances could choose to be throwing, non-throwing and re-throwing depending on the situation. But, as we saw with `Parsers.Map` above, that is just not possible in today's Swift.

        This problem is exactly what Swift's experimental [`@rethrows`][rethrows-tweet] feature aims to solve. By marking our `Parser` protocol definition as `@rethrows`:

        ```swift
        @rethrows public protocol Parser {
          associatedtype Input
          associatedtype Output

          func parse(_ input: inout Input) throws -> Output
        }
        ```

        We instantly get the ability for conformances of `Parser` to rethrow their errors rather than being throwing themselves:

        ```diff
         struct Map<Upstream: Parser, NewOutput>: Parser {
           let upstream: Upstream
           let transform: (Upstream.Output) -> NewOutput

        -  func parse(_ input: inout Upstream.Input) throws -> NewOutput {
        +  func parse(_ input: inout Upstream.Input) rethrows -> NewOutput {
             self.transform(try self.upstream.parse(&input))
           }
         }
        ```

        And now mapping on a whitespace parser produces a new producer that is known by Swift to not fail:

        ```swift
        let whitespaceCount = Whitespace().map(\.count)
        whitespaceCount.parse("   Hello".utf8) // 3
        // No need to `try` since Swift knows the parser cannot fail! 😄
        ```

        This allows parsers to prove more about what it does and does not do to the compiler, and can make parsers (and other protocols) give strong guarantees.

        Although the `@rethrows` attribute is completely experimental and still has not passed the muster of Swift evolution, it is currently being used in Swift's new concurrency APIs, where `AsyncIteratorProtocol` and `AsyncSequence` have been designed so as not to suffer the same shortcomings of `IteratorProtocol` and `Sequence`:

        ```swift
        @rethrows public protocol AsyncIteratorProtocol {
          ...
        }

        @rethrows public protocol AsyncSequence {
          ...
        }
        ```

        ## Start using it today!

        Version [0.7.0][0_7_0] is available today, so once you are ready to migrate your parsers to throwing be sure to let us know how it is working out for you!

        [rethrowing-protocol-conformances]: https://github.com/DougGregor/swift-evolution/blob/rethrows-protocol-conformances/proposals/NNNN-rethrows-protocol-conformances.md
        [rethrowing-protocol-conformances-forums]: https://forums.swift.org/t/pitch-rethrowing-protocol-conformances/42373
        [rethrows-tweet]: https://twitter.com/slava_pestov/status/1480618687677743109
        [0_7_0]: https://github.com/pointfreeco/swift-parsing/releases/0.7.0
        """#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,  // TODO
  id: 73,
  publishedAt: Date(timeIntervalSince1970: 1_644_818_400),
  title: "Parser Errors"
)
