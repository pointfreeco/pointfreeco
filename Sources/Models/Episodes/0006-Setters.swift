import Foundation

extension Episode {
  static let ep6_setters = Episode(
    blurb: """
The programs we write can be reduced to transforming data from one form into another. We’re used to transforming this data imperatively, with setters. There’s a strange world of composition hiding here in plain sight, and it has a surprising link to a familiar functional friend.
""",
    codeSampleDirectory: "0006-functional-setters",
    exercises: _exercises,
    id: 6,
    length: 1238,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_520_247_423),
    references: [.composableSetters, .semanticEditorCombinators],
    sequence: 6,
    title: "Functional Setters",
    trailerVideo: .init(
      bytesLength: 12_368_658,
      downloadUrls: .s3(
        hd1080: "0006-trailer-1080p-8cb7cb46d87e461b914b7990f7afd429",
        hd720: "0006-trailer-720p-7b81d0e3c1ee4e93a6ebdde38271fbfa",
        sd540: "0006-trailer-540p-9d17268fb9d845ea80f45cd881693362"
      ),
      vimeoId: 355113870
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
As we saw with free `map` on `Array`, define free `map` on `Optional` and use it to compose setters
that traverse into an optional field.
"""),

  Episode.Exercise(problem: """
Take a `struct`, _e.g._:

```
struct User {
  let name: String
}
```

Write a setter for its property. Take (or add) another property, and add a setter for it. What are
some potential issues with building these setters?
"""),

  Episode.Exercise(problem: """
Take a `struct` with a nested `struct`, _e.g._:

```
struct Location {
  let name: String
}

struct User {
  let location: Location
}
```

Write a setter for `userLocationName`. Now write setters for `userLocation` and `locationName`. How do
these setters compose?
"""),

  Episode.Exercise(problem: """
Do `first` and `second` work with tuples of three or more values? Can we write `first`, `second`,
`third`, and `nth` for tuples of _n_ values?
"""),

  Episode.Exercise(problem: """
Write a setter for a dictionary that traverses into a key to set a value.
"""),

  Episode.Exercise(problem: """
Write a setter for a dictionary that traverses into a key to set a value if and only if that value
already exists.
"""),

  Episode.Exercise(problem: """
What is the difference between a function of the form `((A) -> B) -> (C) -> (D)` and one of the form `(A) -> (B) -> (C) -> D`?
"""),
]
