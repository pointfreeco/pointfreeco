import Foundation

extension Episode {
  static let ep20_nonEmpty = Episode(
    blurb: """
We often deal with collections that we know can never be empty, yet we use arrays to model them. Using the ideas from our last episode on algebraic data types, we develop a `NonEmpty` type that can be used to transform any collection into a non-empty version of itself.
""",
    codeSampleDirectory: "0020-nonempty",
    exercises: _exercises,
    id: 20,
    image: "https://i.vimeocdn.com/video/804928456.jpg",
    length: 49*60 + 2,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_529_920_623),
    references: [.swiftNonEmpty, .swiftValidated],
    sequence: 20,
    title: "NonEmpty",
    trailerVideo: .init(
      bytesLength: 44028902,
      downloadUrl: "https://player.vimeo.com/external/352312199.hd.mp4?s=7ac2966a42f34242bc11e4b915981f20edae50a0&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/352312199"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Why shouldn't `NonEmpty` conditionally conform to `SetAlgebra` when its underlying collection type also conforms to `SetAlgebra`?
"""),
  .init(problem: """
Define the following method:

```
extension NonEmpty where C: SetAlgebra {
  func contains(_ member: C.Element) -> Bool
}
```

Note that `SetAlgebra` does not require that elements are equatable, so utilize other methods on `SetAlgebra` to make this check.
"""),
  .init(problem: """
Define the following method:

```
extension NonEmpty where C: SetAlgebra {
  func union(_ other: NonEmpty) -> NonEmpty
}
```

Ensure that no duplicate `head` element enters the resulting non-empty set. The following property should hold true:

```
NonEmptySet(1, 2, 3).union(NonEmptySet(3, 2, 1)).count == 3
```
"""),
  .init(problem: """
Define a helper subscript on `NonEmpty` to access a non-empty dictionary's element using the dictionary key. You can constrain the subscript over `Key` and `Value` generics to make this work.
"""),
  .init(problem: """
Our current implementation of `NonEmpty` allows for non-empty dictionaries to contain the `head` key twice! Write a constrained extension on NonEmpty to prevent this from happening. You will need create a `DictionaryProtocol` for `Dictionary` in order to make this work because Swift does not currently support generic extentions.

```
// Doesn't work
extension <Key, Value> NonEmpty where Element == [Key: Value] {}

// Works
protocol DictionaryProtocol {
  /* Expose necessary associated types and interface */
}
extension Dictionary: DictionaryProtocol {}
extension NonEmpty where Element: DictionaryProtocol {}
```

Look to the [standard library APIs](https://developer.apple.com/documentation/swift/dictionary) for inspiration on how to handle duplicate keys, like the `init(uniqueKeysAndValues:)` and `init(_:uniquingKeysWith:)` initializers.
"""),
  .init(problem: """
Define [`updateValue(_:forKey:)`](https://developer.apple.com/documentation/swift/dictionary/1539001-updatevalue)
on non-empty dictionaries.
"""),
  .init(problem: """
Define `merge` and `merging` on non-empty dictionaries.
"""),
  .init(problem: """
Swift `Sequence` contains [two `joined` methods](https://developer.apple.com/documentation/swift/sequence#2923868) that flattens a nested sequence given an optional separator sequence. For example:
```
["Get ready", "get set", "go!"].joined("...")
// "Get ready...get set...go!"

[[1], [1, 2], [1, 2, 3]].joined([0, 0])
// [1, 0, 0, 1, 2, 0, 0, 1, 2, 3]
```

A non-empty collection of non-empty collections, when joined, should also be non-empty. Write a `joined` function that does so. How must the collection be constrained?
"""),
  .init(problem: """
Swift `Sequence` also contains [two `split` methods](https://developer.apple.com/documentation/swift/sequence#2923868) that split a `Sequence` into `[Sequence.SubSequence]`. They contain a parameter, `omittingEmptySubsequences` that prevents non-empty sub-sequences from being included in the resulting array.

Splitting a non-empty collection, while omitting empty subsequences, should return a non-empty collection of non-empty collections. Define this version of `split` on `NonEmpty`.
"""),
  .init(problem: """
What are some challenges with conditionally-conforming `NonEmpty` to `Equatable`? Consider the following
check: `NonEmptySet(1, 2, 3) == NonEmptySet(3, 2, 1)`. How can these challenges be overcome?
"""),
  .init(problem: """
Define `zip` on non-empty arrays:

```
func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {}
```
"""),
]
