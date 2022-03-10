import Foundation

extension Episode {
  static let ep8_gettersAndKeyPaths = Episode(
    blurb: """
Key paths aren’t just for setting. They also assist in getting values inside nested structures in a \
composable way. This can be powerful, allowing us to make the Swift standard library more expressive with \
no boilerplate.
""",
    codeSampleDirectory: "0008-getters-and-key-paths",
    exercises: _exercises,
    id: 8,
    length: 1711,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_521_453_423),
    references: [
      .se0249KeyPathExpressionsAsFunctions
    ],
    sequence: 8,
    title: "Getters and Key Paths",
    trailerVideo: .init(
      bytesLength: 14_431_137,
      downloadUrls: .s3(
        hd1080: "0008-trailer-1080p-1e7cc25c74c143f9aaab82e2d52acc5d",
        hd720: "0008-trailer-720p-1bd43f3ad70448fc9826c3ee86c3884a",
        sd540: "0008-trailer-540p-17b701045869479d9a5f189b8c1afc2f"
      ),
      vimeoId: 355113874
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Find three more standard library APIs that can be used with our `get` and `^` helpers.
"""),

  Episode.Exercise(problem: """
The one downside to key paths being _only_ compiler generated is that we do not get to create new ones
ourselves. We only get the ones the compiler gives us.

And there are a lot of getters and setters that are not representable by key paths. For example, the
"identity" key path `KeyPath<A, A>` that simply returns `self` for the getter and that setting on it
leaves it unchanged. Can you think of any other interesting getters/setters that cannot be represented
by key paths?
"""),

  Episode.Exercise(problem: """
In our [Setters and Key Paths](/episodes/ep7-setters-and-key-paths) episode we showed how `map` could
kinda be seen as a "setter" by saying:

> "If you tell me how to transform an `A` into a `B`, I will tell you how to transform an `[A]` into a `[B]`."

There is also a way to think of `map` as a "getter" by saying:

> "If you tell me how to get a `B` out of an `A`, I will tell you how to get an `[B]` out of an `[A]`."

Try composing `get` with free `map` function to construct getters that go even deeper into a structure.
You may want to use the data types we defined [last time](https://github.com/pointfreeco/episode-code-samples/blob/1998e897e1535a948324d590f2b53b6240662379/0007-setters-and-key-paths/Setters%20and%20Key%20Paths.playground/Contents.swift#L2-L20).
"""),

  Episode.Exercise(problem: """
Repeat the above exercise by seeing how the free optional `map` can allow you to dive deeper into an
optional value to extract out a part.

Key paths even give first class support for this operation. Do you know what it is?
"""),

  Episode.Exercise(problem: """
Key paths aid us in getter composition for structs, but enums don't have any stored properties. Write a
getter function for `Result` that plucks out a value if it exists, such that it can compose with `get`.
Use this function with a value in `Result<User, String>` to return the user's name.
"""),

  Episode.Exercise(problem: """
Key paths work immediately with all fields in a struct, but only work with computed properties on an
enum. We saw in [Algebra Data Types](https://www.pointfree.co/episodes/ep4-algebraic-data-types) that
structs and enums are really just two sides of a coin: neither one is more important or better than
the other.

What would it look like to define an `EnumKeyPath<Root, Value>` type that encapsulates the idea of
"getting" and "setting" cases in an enum?
"""),

  Episode.Exercise(problem: """
Given a value in `EnumKeyPath<A, B>` and `EnumKeyPath<B, C>`, can you construct a value in
`EnumKeyPath<A, C>`?
"""),

  Episode.Exercise(problem: """
Given a value in `EnumKeyPath<A, B>` and a value in `EnumKeyPath<A, C>`, can you construct a value in
`EnumKeyPath<A, Either<B, C>>`?
"""),
]
