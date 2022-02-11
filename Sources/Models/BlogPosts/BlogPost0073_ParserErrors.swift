import Foundation

public let post0073_ParserErrors = BlogPost(
  author: .pointfree,
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: """
We are excited to release [0.7.0](https://github.com/pointfreeco/swift-parsing/releases/0.7.0) of our [swift-parsing](https://github.com/pointfreeco/swift-parsing) library that brings delightful and informative error messaging to parser failures. This is a huge change to the library, and unfortunately is a breaking change.

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

## Migrating from 0.6.0

Unfortunately changing the `Parser` protocol's requirement to be throwing is a breaking change, and we're not sure there is a way to maintain backwards compatibility. But fortunately there are a few small things you can do to bring your code up-to-date.

By far the common use of parsers that will need to be migrated is when calling the `parse` method. To recapture the only behavior you only need to `try?` the parsing:

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
+      throw ParsingError(...)
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

This means you can use the new `.replaceError(with:)` parser operator throughout your parsers to get a compile-time guarantee that parsing can't fail.

```swift
// No need to `try`!
Int.parser().replaceError(with: 0).parse("!!!")  // 0
```

## `@rethrows`

In this release swift-parsing has adopted an experimental compiler feature: rethrowing protocols.

## Start using it today!


""",
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil, // TODO
  id: 73,
  publishedAt: Date(timeIntervalSince1970: 1644818400),
  title: "Parser Errors"
)
