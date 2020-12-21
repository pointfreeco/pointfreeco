import Foundation

public let post0049_OpenSourcingParsing = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open sourcing Parsing, a library for turning nebulous data into well-structured data, with a focus on composition, performance, and generality.
""",
  contentBlocks: [
    .init(
      content: #"""
We are excited to announce the 0.1.0 release of [Parsing](https://github.com/pointfreeco/swift-parsing), a library for turning nebulous data into well-structured data. It was built from the content of [21 episodes](/collections/parsing) (10 hours) where we show how to build a parsing library from scratch, with a focus on composition, performance, and generality:

* **Composition**: The ability to break large, complex parsing problems down into smaller, simpler ones. And the ability to take small, simple parsers and easily combine them into larger, more complex ones.

* **Performance**: Parsers that have been composed of many smaller parts should perform as well as highly-tuned, hand-written parsers.

* **Generality**: The ability to parse _any_ kind of input into _any_ kind of output. This allows you to choose which abstraction levels you want to work with based on how much performance you need or how much correctness you want guaranteed. For example, you can write a highly tuned parser on collections of UTF-8 code units, and it will automatically plug into parsers of strings, arrays, unsafe buffer pointers and more.

## Motivation

Parsing is a surprisingly ubiquitous problem in programming. We can define parsing as trying to take a more nebulous blob of data and transform it into something more well-structured. The Swift standard library comes with a number of parsers that we reach for every day. For example, there are initializers on `Int`, `Double`, and even `Bool`, that attempt to parse numbers and booleans from strings:

```swift
Int("42")         // 42
Int("Hello")      // nil

Double("123.45")  // 123.45
Double("Goodbye") // nil

Bool("true")      // true
Bool("0")         // nil
```

And there are types like `JSONDecoder` and `PropertyListDecoder` that attempt to parse `Decodable`-conforming types from data:

```swift
try JSONDecoder().decode(User.self, from: data)
try PropertyListDecoder().decode(Settings.self, from: data)
```

While parsers are everywhere in Swift, Swift has no holistic story _for_ parsing. Instead, we typically parse data in an ad hoc fashion using a number of unrelated initializers, methods, and other means. And this typically leads to less maintainable, less reusable code.

This library aims to write such a story for parsing in Swift. It introduces a single unit of parsing that can be combined in interesting ways to form large, complex parsers that can tackle the programming problems you need to solve in a maintainable way.

## Getting started

Suppose you have a string that holds some user data that you want to parse into an array of `User`s:

```swift
var input = """
1,Blob,true
2,Blob Jr.,false
3,Blob Sr.,true
"""

struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
}
```

A naive approach to this would be a nested use of `.split(separator:)`, and then a little bit of extra work to convert strings into integers and booleans:

```swift
let users = input
  .split(separator: "\n")
  .compactMap { row -> User? in
    let fields = row.split(separator: ",")
    guard
      fields.count == 3,
      let id = Int(fields[0]),
      let isAdmin = Bool(String(fields[2]))
    else { return nil }

    return User(id: id, name: String(fields[1]), isAdmin: isAdmin)
  }
```
                                                          
Not only is this code a little messy, but it is also inefficient since we are allocating arrays for the `.split` and then just immediately throwing away those values.

It would be more straightforward and efficient to instead describe how to consume bits from the beginning of the input and convert that into users. This is what this parser library excels at 😄.

We can start by describing what it means to parse a single row, first by parsing an integer off the front of the string, and then parsing a comma that we discard using the `.skip` operator:

```swift
let user = Int.parser()
  .skip(StartsWith(","))
```

Already this can consume the beginning of the input:

```swift
user.parse(&input) // => 1
input // => "Blob,true\n2,Blob Jr.,false\n3,Blob Sr.,true"
```

Next we want to take everything up until the next comma for the user's name, and then skip the comma:

```swift
let user = Int.parser()
  .skip(StartsWith(","))
  .take(PrefixWhile { $0 != "," })
  .skip(StartsWith(","))
```

Here the `.take` operator has combined parsed values together into a tuple, `(Int, Substring)`.

And then we want to take the boolean at the end of the row for the user's admin status:

```swift
let user = Int.parser()
  .skip(StartsWith(","))
  .take(PrefixWhile { $0 != "," })
  .skip(StartsWith(","))
  .take(Bool.parser())
```

Currently this will parse a tuple `(Int, Substring, Bool)` from the input, and we can `.map` on that to turn it into a `User`:

```swift
let user = Int.parser()
  .skip(StartsWith(","))
  .take(PrefixWhile { $0 != "," })
  .skip(StartsWith(","))
  .take(Bool.parser())
  .map { User(id: $0, name: String($1), isAdmin: $2) }
```

That is enough to parse a single user from the input string:

```swift
user.parse(&input) // => User(id: 1, name: "Blob", isAdmin: true)
input // => "\n2,Blob Jr.,false\n3,Blob Sr.,true"
```

To parse multiple users from the input we can use the `Many` parser:

```swift
let users = Many(user, separator: StartsWith("\n"))

user.parse(&input) // => [User(id: 1, name: "Blob", isAdmin: true), ...]
input // => ""
```

Now this parser can process an entire document of users, and the code is simpler and more straightforward than the version that uses `.split` and `.compactMap`.

Even better, it's more performant. We've written [benchmarks](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/ReadmeExample.swift) for these two styles of parsing, and the `.split`-style of parsing is more than twice as slow:

```
name                             time        std        iterations
------------------------------------------------------------------
README Example.Parser: Substring 3426.000 ns ±  63.40 %     385395
README Example.Adhoc             7631.000 ns ±  47.01 %     169332
Program ended with exit code: 0
```

Further, if you are willing write your parsers against `UTF8View` instead of `Substring`, you can eke out even more performance, more than doubling the speed:

```
name                             time        std        iterations
------------------------------------------------------------------
README Example.Parser: Substring 3693.000 ns ±  81.76 %     349763
README Example.Parser: UTF8      1272.000 ns ± 128.16 %     999150
README Example.Adhoc             8504.000 ns ±  59.59 %     151417
```

We can also compare these times to a tool that Apple's Foundation gives us: `Scanner`. It's a type that allows you to consume from the beginning of strings in order to produce values, and provides a nicer API than using `.split`:

```swift
var users: [User] = []
while scanner.currentIndex != input.endIndex {
  guard
    let id = scanner.scanInt(),
    let _ = scanner.scanString(","),
    let name = scanner.scanUpToString(","),
    let _ = scanner.scanString(","),
    let isAdmin = scanner.scanBool()
  else { break }

  users.append(User(id: id, name: name, isAdmin: isAdmin))
  _ = scanner.scanString("\n")
}
```

However, the `Scanner` style of parsing is more than 5 times as slow as the substring parser written above, and more than 15 times slower than the UTF-8 parser:

```
name                             time         std        iterations
-------------------------------------------------------------------
README Example.Parser: Substring  3481.000 ns ±  65.04 %     376525
README Example.Parser: UTF8       1207.000 ns ± 110.96 %    1000000
README Example.Adhoc              8029.000 ns ±  44.44 %     163719
README Example.Scanner           19786.000 ns ±  35.26 %      62125
```

That's the basics of parsing a simple string format, but there's a lot more operators and tricks to learn in order to performantly parse larger inputs. View the [benchmarks](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark) for examples of real life parsing scenarios.

## Design

### Protocol

The design of the library is largely inspired by the Swift standard library and Apple’s Combine framework. A parser is represented as a protocol that many types conform to, and then parser transformations (also known as "combinators") are methods that return concrete types conforming to the parser protocol.

For example, to parse all the characters from the beginning of a substring until you encounter a comma you can use the `Prefix` parser:

```swift
let parser = Prefix<Substring> { $0 != "," }

var input = "Hello,World"[...]
parser.parse(&input) // => "Hello"
input // => ",Hello"
```

The type of this parser is:

```swift
Prefix<Substring>
```

We can `.map` on this parser in order to transform its output, which in this case is the string "Hello":

```swift
let parser = Prefix<Substring> { $0 != "," }
  .map { $0 + "!!!" }

var input = "Hello,World"[...]
parser.parse(&input) // => "Hello!!!"
input // => ",Hello"
```

The type of this parser is now:

```swift
Parsers.Map<Prefix<Substring>, Substring>
```

Notice how the type of the parser encodes the operations that we performed. This adds a bit of complexity when using these types, but comes with some performance benefits because Swift can usually optimize the creation of those nested types.

### Low-level versus high-level

The library makes it easy to choose which abstraction level you want to work on. Both low-level and high-level have their pros and cons.

Parsing low-level inputs, such as UTF-8 code units, has better performance, but at the cost of potentially losing correctness. A canonical example of this is trying to parse the character "é", which can be represented in code units as `[233]` or `[101, 769]`. If you don't remember to always parse both representations you may have a bug where you accidentally fail your parser when it encounters a code unit sequence you don't support.

On the other hand, parsing high-level inputs, such as `String`, can guarantee correctness, but at the cost of performance. For example, `String` handles the complexities of extended grapheme clusters and UTF-8 normalization for you, but traversing strings is slower since its elements are variable width.

The library gives you the tools that allow you to choose which abstraction level you want to work on, as well as the ability to fluidly move between abstraction levels where it makes sense.

For example, say we want to parse particular city names from the beginning of a string:

```swift
enum City {
  case london
  case newYork
  case sanJose
}
```

Because "San José" has an accented character, the safest way to parse it is to parse on the `Substring` abstraction level:

```swift
let city = StartsWith<Substring>("London").map { City.london }
  .orElse(StartsWith("New York").map { .newYork })
  .orElse(StartsWith("San José").map { .sanJose })

var input = "San José,123"
city.parse(&input) // => City.sanJose
input // => ",123"
```

However, we are incurring the cost of parsing `Substring` for this entire parser, even though only the "San José" case needs that power. We can refactor this parser so that "London" and "New York" are parsed on the `UTF8View` level, since they consist of only ASCII characters, and then parse "San José" as `Substring`:

```swift
let city = StartsWith("London".utf8).map { City.london }
  .orElse(StartsWith("New York".utf8).map { .newYork })
  .orElse(StartsWith("San José").utf8.map { .sanJose })
```

It's subtle, but `StartsWith("London".utf8)` is a parser that parses the code units for "London" from the beginning of a `UTF8View`, whereas `StartsWith("San José").utf8` parses "San José" as a `Substring`, and then converts that into a `UTF8View` parser.

This allows you to parse as much as possible on the more performant, low-level `UTF8View`, while still allowing you to parse on the more correct, high-level `Substring` when necessary.

## Benchmarks

This library comes with a benchmark executable that not only demonstrates the performance of the library, but also provides a wide variety of parsing examples:

* [URL router](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/Routing.swift)
* [Xcode test logs](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/XcodeLogs)
* [Simplfied CSV](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/CSV)
* [Hex color](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/Color.swift)
* [ISO8601 date](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/Date.swift)
* [HTTP request](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/HTTP.swift)
* [Simplified JSON](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/JSON.swift)
* [Arithmetic grammar](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark/Arithmetic.swift)
* and more

These are the times we currently get when running the benchmarks:

```text
MacBook Pro (16-inch, 2019)
2.4 GHz 8-Core Intel Core i9
64 GB 2667 MHz DDR4

name                                         time             std          iterations
-------------------------------------------------------------------------------------
Arithmetic.Parser                                12622.000 ns ±  40.63 %       102408
BinaryData.Parser                                  512.000 ns ± 172.80 %      1000000
Bool.Bool.init                                      28.000 ns ± 880.63 %      1000000
Bool.BoolParser                                     43.000 ns ± 423.22 %      1000000
Bool.Scanner.scanBool                              920.000 ns ± 119.49 %      1000000
Color.Parser                                       127.000 ns ± 341.57 %      1000000
CSV.Parser                                     1370906.000 ns ±  12.24 %         1027
CSV.Ad hoc mutating methods                    1338824.500 ns ±  13.91 %         1014
Date.Parser                                      12429.000 ns ±  38.26 %       107342
Date.DateFormatter                               41168.000 ns ±  29.40 %        31353
Date.ISO8601DateFormatter                        56236.000 ns ±  27.39 %        23383
HTTP.HTTP                                         3850.000 ns ± 1898.35 %      341642
JSON.Parser                                       6115.000 ns ±  45.95 %       217152
JSON.JSONSerialization                            3050.000 ns ±  71.43 %       431524
Numerics.Int.init                                   38.000 ns ± 655.10 %      1000000
Numerics.Int.parser                                 41.000 ns ± 464.80 %      1000000
Numerics.Scanner.scanInt                           145.000 ns ± 22359.78 %    1000000
Numerics.Comma separated: Int.parser           5511505.000 ns ±   8.87 %          245
Numerics.Comma separated: Scanner.scanInt     82824843.000 ns ±   2.37 %           17
Numerics.Comma separated: String.split       117376272.000 ns ±   2.68 %           11
Numerics.Double.init                                58.000 ns ± 518.12 %      1000000
Numerics.Double.parser                              59.000 ns ± 445.11 %      1000000
Numerics.Scanner.scanDouble                        195.000 ns ± 234.94 %      1000000
Numerics.Comma separated: Double.parser        6222693.000 ns ±   9.33 %          220
Numerics.Comma separated: Scanner.scanDouble  89431780.500 ns ±   3.75 %           16
Numerics.Comma separated: String.split        33387660.000 ns ±   4.02 %           41
PrefixUpTo.Parser                                22898.000 ns ±  34.40 %        58197
PrefixUpTo.Scanner.scanUpToString               162816.000 ns ±  18.55 %         8000
Race.Parser                                      29962.000 ns ±  32.24 %        43186
README Example.Parser: Substring                  3451.000 ns ±  59.72 %       378685
README Example.Parser: UTF8                       1247.000 ns ± 110.74 %      1000000
README Example.Adhoc                              8134.000 ns ±  34.87 %       161121
Routing.Parser                                    5242.000 ns ±  52.70 %       249596
String Abstractions.Substring                  1044908.500 ns ±  12.95 %         1296
String Abstractions.UTF8                        138412.000 ns ±  22.64 %         8938
Xcode Logs.Parser                              6980962.000 ns ±   7.61 %          197
```

# Try it today

Head over to the [Parsing](https://github.com/pointfreeco/swift-parsing) repository to try the library out today. For some inspiration of things you might like to write parsers for check out the [benchmarks](https://github.com/pointfreeco/swift-parsing/blob/main/Sources/swift-parsing-benchmark) in the project.
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 49,
  publishedAt: Date(timeIntervalSince1970: 1608530400),
  title: "Open Sourcing Parsing"
)
