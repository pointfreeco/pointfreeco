import Foundation

public let post0073_ParserErrors = BlogPost(
  author: .pointfree,
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: """
We are excited to release 0.7.0 of our [swift-parsing](https://github.com/pointfreeco/swift-parsing) library that brings delightful and informative error messaging to parser failures. This is a huge change to the library, and unfortunately is a breaking change.

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

From the beginning of swift-parsing we leaned on optionals as a very simple way to denote failure when parsing. That works well enough for simple parsers, but as

## Migrating from 0.6.0

Unforunately changing the `Parser` protocol's requirement to be throwing is a breaking change, and we're not sure there is a way to maintain backwards compatability. But fortunately there are a few small things you can do to bring your code up-to-date.

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

A less common, but still important, use of parsers that will need to be migrated

## `@rethrows`

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
