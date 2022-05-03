import Foundation

extension Episode {
  public static let ep128_parsingPerformance = Episode(
    blurb: """
      We convert some of our substring parsers to work on lower levels of String abstractions, and unlock huge performance gains. Even better, thanks to our generalized parser we can even piece together multiple parsers that work on different abstraction levels, maximizing performance in the process.
      """,
    codeSampleDirectory: "0128-parsing-performance-pt2",
    exercises: _exercises,
    id: 128,
    length: 50 * 60 + 54,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_607_320_800),
    references: [
      .swiftBenchmark,
      .utf8(),
      .stringsInSwift4(),
      .init(
        author: "Stephen Celis",
        blurb: """
          While researching the string APIs for this episode we stumbled upon a massive inefficiency in how Swift implements `removeFirst` on certain collections. This PR fixes the problem and turns the method from an `O(n)` operation (where `n` is the length of the array) to an `O(k)` operation (where `k` is the number of elements being removed).
          """,
        link: "https://github.com/apple/swift/pull/32451",
        publishedAt: referenceDateFormatter.date(from: "2020-07-28"),
        title: "Improve performance of Collection.removeFirst(_:) where Self == SubSequence"
      ),
    ],
    sequence: 128,
    subtitle: "Combinators",
    title: "Parsing and Performance",
    trailerVideo: .init(
      bytesLength: 31_403_006,
      downloadUrls: .s3(
        hd1080: "0128-trailer-1080p-86ea6b92edcd4eeab8c58a6bb6c3c62d",
        hd720: "0128-trailer-720p-d32f751594674f6f96536eacdd56420c",
        sd540: "0128-trailer-540p-4b2cefac90a345fe827e19181dcb4c09"
      ),
      vimeoId: 487_918_802
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      While string's `UTF8View` offers a super-performant, low-level abstraction, we have found that there are other low-level abstractions that offer different performance characteristics. For one, while `UTF8View` is a Swift `Collection` of `UInt8`s, so is a more general array `[UInt8]`. Write another `int` parser overload where `Input` is a more general array. What changes in the implementation? What changes as far as performance is concerned?
      """#,
    solution: #"""
      For our parser type to work most efficiently, we will constrain our parser to work with `ArraySlice`, which has a subsequence of the same type and can share storage when removing elements from the start and end of the array by simply moving the indices:

      ```swift
      extension Parser where Input == ArraySlice<UInt8>, Output == Int {
        static let int = Self { input in
          var isFirstCharacter = true
          let intPrefix = input.prefix { c in
            defer { isFirstCharacter = false }
            return (c == UTF8.CodeUnit(ascii: "-") || c == UTF8.CodeUnit(ascii: "+")) && isFirstCharacter
              || (UTF8.CodeUnit(ascii: "0")...UTF8.CodeUnit(ascii: "9")).contains(c)
          }

          guard let match = Int(String(decoding: intPrefix, as: UTF8.self))
          else { return nil }

          input.removeFirst(intPrefix.count)
          return match
        }
      }
      ```

      The only two changes are in the constraint, which is `ArraySlice<UInt8>` instead of `Substring.UTF8View`, and where the match is converted to a string, which must now use the more generalized `String.init(decoding:as:)` initializer instead of the `String.init`-`Substring.init` that was possible given a `Substring.UTF8View`.

      As far as performance is concerned, there are two things to consider. We must first convert a string to an array before we can parse it, which is a performance cost that both requires double the memory, and the up-front cost of that conversion. Once the string it converted, however, it appears to be about 30–40% faster to parse.
      """#
  ),
  .init(
    problem: #"""
      There is another abstraction level we can parse from, and that's unsafe pointers (😰), but we don't necessarily have to fear them!

      Write another `int` parser that works on an input for one of the safer of unsafe pointers: `UnsafeBufferPointer`. This is a pointer to a collection of elements stored in contiguous memory. Strings offer two main ways of accessing this kind of data:

      ```swift
      // Directly on the string:
      string.withUTF8 { (ptr: UnsafeBufferPointer<UInt8>) in
        ...
      }

      // On any collection:
      string.utf8.withContiguousStorageIfAvailable { (ptr: UnsafeBufferPointer<UInt8>) in
        ...
      }
      ```

      After writing this parser, benchmark it against each interface.
      """#,
    solution: #"""
      Starting from the previous exercise, the only thing that needs to change is the extension, which needs to work on a _slice_ of a buffer pointer. Everything else is the same:

      ```swift
      extension Parser where Input == Slice<UnsafeBufferPointer<UInt8>>, Output == Int {
        static let int = Self { input in
          var isFirstCharacter = true
          let intPrefix = input.prefix { c in
            defer { isFirstCharacter = false }
            return (c == UTF8.CodeUnit(ascii: "-") || c == UTF8.CodeUnit(ascii: "+")) && isFirstCharacter
              || (UTF8.CodeUnit(ascii: "0")...UTF8.CodeUnit(ascii: "9")).contains(c)
          }

          guard let match = Int(String(decoding: intPrefix, as: UTF8.self))
          else { return nil }

          input.removeFirst(intPrefix.count)
          return match
        }
      }
      ```

      We can benchmark `withUTF8` and `withContiguousStorageIfAvailable` with a little extra upfront work.

      `withUTF8` requires a mutable string (or substring), since if the string is _not_ in contiguous memory, it must be moved into contiguous memory beforehand, so we must copy the string into a mutable variable before parsing. The operation returns a non-failable result because strings can always move their bytes into contiguous memory.

      ```swift
      suite.benchmark("withUTF8") {
        var s = string
        precondition(
          s.withUTF8 { ptr in
            var ptr = ptr[...]
            return Parser.int.run(&ptr)!
          }
          == 1234567890
        )
      }
      ```

      `withContiguousStorageIfAvailable` on the other hand is more general and more failable. If contiguous memory cannot be allocated for the given collection, it will return `nil`, so we must further unwrap it in our precondition (we know it should never fail for `UTF8View`s).

      ```swift
      suite.benchmark("withContiguousStorageIfAvailable") {
        precondition(
          string.utf8.withContiguousStorageIfAvailable { ptr in
            var ptr = ptr[...]
            return Parser.int.run(&ptr)!
          }!
          == 1234567890)
        )
      }
      ```

      Performance-wise, these methods are even faster than `ArraySlice<UInt8>` and do not incur the same memory cost: about 2x faster than `UTF8View` and 70% faster than `ArraySlice<UInt8>`. Performance between each interface is negligible and can be measured in under 10 nanoseconds.
      """#
  ),
  .init(
    problem: #"""
      The `int` parser on `UTF8View`, `[UInt8]` and `UnsafeBufferPointer<UInt8>` can be unified in a single implementation that is constrained against the `Collection` protocol. Comment out the other parsers and use this single, more generalized parser, instead. How does this affect performance?
      """#,
    solution: #"""
      The body of this parser is the same as the last two. We just need to update the extension with more general constraints and use a computed static property instead of a `let`:

      ```swift
      extension Parser
      where
        Input: Collection,
        Input.SubSequence == Input,
        Input.Element == UInt8,
        Output == Int
      {
        static var int: Self {
          Self { input in
            var isFirstCharacter = true
            let intPrefix = input.prefix { c in
              defer { isFirstCharacter = false }
              return (c == UTF8.CodeUnit(ascii: "-") || c == UTF8.CodeUnit(ascii: "+")) && isFirstCharacter
                || (UTF8.CodeUnit(ascii: "0")...UTF8.CodeUnit(ascii: "9")).contains(c)
            }

            guard let match = Int(String(decoding: intPrefix, as: UTF8.self))
            else { return nil }

            input.removeFirst(intPrefix.count)
            return match
          }
        }
      }
      ```

      Performance characteristics seem to be the same (in this single module).
      """#
  ),
]
