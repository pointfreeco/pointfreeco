import Foundation

public let post0028_openSourcingEnumProperties = BlogPost(
  author: .pointfree,
  // TODO: Cloudfront
  blurb: """
We wanted to make Swift enum data access as ergonomic as struct data access, so today we are open sourcing a code generation tool to do just that!
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0028-enum-properties/cover.png")
    ),

    .init(
      content: """
---

> We wanted to make Swift enum data access as ergonomic as struct data access, so today we are open sourcing a code generation tool to do just that: [generate-enum-properties](https://github.com/pointfreeco/swift-enum-properties).

---

We are excited to announce the 0.1.0 release of [generate-enum-properties](https://github.com/pointfreeco/swift-enum-properties), a code generation tool for Swift that makes enum data access as ergonomic as struct data access!

## Motivation

In Swift, struct data access is far more ergonomic than enum data access by default.

A struct field can be accessed in less than a single line using expressive dot-syntax:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
user.name
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
An enum's associated value requires as many as _seven_ lines to bring it into the current scope:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let optionalValue: String?
if case let .success(value) = result {
  optionalValue = value
} else {
  optionalValue = nil
}
optionalValue
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That's a lot of boilerplate getting in the way of what we care about: getting at the value of a `success`.

This difference is also noticeable when working with higher-order functions like `map` and `compactMap`.

An array of struct values can be transformed succinctly in a single expression:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
users.map { $0.name }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
But an array of enum values requires a version of the following incantation:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
results.compactMap { result -> String? in
  guard case let .success(value) = result else { return nil }
  return value
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The imperative nature of unwrapping an associated value spills over multiple lines, which requires us to give Swift an explicit return type, name our closure argument, and provide _two_ explicit `return`s.

## Solution

We can recover all of the ergonomics of struct data access for enums by defining "enum properties": computed properties that optionally return a value when the case matches:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Result {
  var success: Success? {
    guard case let .success(value) = self else { return nil }
    return value
  }

  var failure: Failure? {
    guard case let .failure(value) = self else { return nil }
    return value
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This is work we're used to doing in an ad hoc way throughout our code bases, but by centralizing it in a computed property, we're now free to access underlying data in a succinct fashion:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// Optionally-chain into a successful result.
result.success?.count

// Collect a bunch of successful values.
results.compactMap { $0.success }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
By defining a computed property, we bridge another gap: our enums now have key paths!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
\\Result<String, Error>.success
// KeyPath<Result<String, Error>, String?>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Despite the benefits, defining these from scratch is a tall ask. Instead, enter `generate-enum-properties`.

## `generate-enum-properties`

`generate-enum-properties` is a command line tool that will rewrite Swift source code to add ergonomic enum data access to any enum with associated data.

Given the following source file as input:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Validated<Valid, Invalid> {
  case valid(Valid)
  case invalid(Invalid)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
It will be replaced with the following output:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Validated<Valid, Invalid> {
  case valid(Valid)
  case invalid(Invalid)

  var valid: Valid? {
    get {
      guard case let .valid(value) = self else { return nil }
      return value
    }
    set {
      guard case .valid = self, let newValue = newValue else { return }
      self = .valid(newValue)
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Not only can you ergonomically _access_ enum data, but you can update it as well!

## Learn more

We've explored why "enum properties" are important on [Point-Free](https://www.pointfree.co), but we hope this library empowers folks to write source code generation tools to solve these kinds of problems more broadly.

To generate enum properties for your Swift source code projects, today, visit [the repository](https://github.com/pointfreeco/swift-enum-properties) and read through its installation and usage!
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0028-enum-properties/cover.png",
  id: 28,
  publishedAt: .init(timeIntervalSince1970: 1556517600),
  title: "Open Sourcing Enum Properties"
)
