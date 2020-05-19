import Foundation

extension Episode {
  static let ep52_enumProperties = Episode(
    blurb: """
Swift makes it easy for us to access the data inside a struct via dot-syntax and key-paths, but enums are provided no such affordances. This week we correct that deficiency by defining the concept of "enum properties", which will give us an expressive way to dive deep into the data inside our enums.
""",
    codeSampleDirectory: "0052-enum-properties",
    exercises: _exercises,
    id: 52,
    image: "https://i.vimeocdn.com/video/801298760.jpg",
    length: 24*60 + 38,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1554098400),
    references: [
      reference(
        forEpisode: .ep8_gettersAndKeyPaths,
        additionalBlurb: """
An episode dedicated to property access on structs and how key paths can further aid us in writing expressive code.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep8-getters-and-key-paths"
      ),
      .se0249KeyPathExpressionsAsFunctions,
      Episode.Reference(
        author: "Zoë Smith",
        blurb: "This site is a cheat sheet for `if case let` syntax in Swift, which can be seriously complicated.",
        link: "http://goshdarnifcaseletsyntax.com",
        publishedAt: nil,
        title: "How Do I Write If Case Let in Swift?"
      ),
    ],
    sequence: 52,
    title: "Enum Properties",
    trailerVideo: .init(
      bytesLength: 38869888,
      downloadUrl: "https://player.vimeo.com/external/348478815.hd.mp4?s=d57fd6dd852dc6b56ba0da04bba1170d768a98dc&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348478815"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
While we've defined the `get`s of our enum properties, we haven't defined our `set`s. Redefine `Validated`'s `valid` and `invalid` properties to have a setter in addition to its getter.
""",
    solution: """
We can redefine `valid` with the following setter.

```
var valid: Valid? {
  get {
    guard
      case let .valid(value) = self
      else { return nil }
    return value
  }
  set {
    guard
      let newValue = newValue,
      case .valid = self
      else { return }
    self = .valid(newValue)
  }
}
```

While we must safely unwrap a non-optional `newValue` to reassign `self`, we also test that the current `self` is `valid` before doing so.

The `invalid` property is the same boilerplate but uses the `invalid` case.

```
var invalid: [Invalid]? {
  get {
    guard
      case let .invalid(value) = self
      else { return nil }
    return value
  }
  set {
    guard
      let newValue = newValue,
      case .invalid = self
      else { return }
    self = .invalid(newValue)
  }
}
```
"""
  ),
  Episode.Exercise(
    problem: """
Take the `valid` setter for a spin. Assign `Validated<Int, String>.valid(1)` to a variable and increment the number using the setter.
""",
    solution: """
There are a few ways of doing this! First, let's assign a mutable variable.

```
var v = Validated<Int, String>.valid(1)
```

We can `map` over the optional `Int` returned by the `valid` getter.

```
v.valid = v.valid.map { $0 + 1 }
```

Or we can optionally chain with the `+=` operator.

```
v.valid? += 1
"""
  ),
]
