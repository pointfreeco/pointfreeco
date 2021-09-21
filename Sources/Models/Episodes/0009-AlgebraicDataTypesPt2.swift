import Foundation

extension Episode {
  static let ep9_algebraicDataTypes_exponents = Episode(
    blurb: """
We continue our explorations into algebra and the Swift type system. We show that exponents correspond to functions in Swift, and that by using the properties of exponents we can better understand what makes some functions more complex than others.
""",
    codeSampleDirectory: "0009-algebraic-data-types-pt-2",
    exercises: _exercises,
    id: 9,
    image: "https://i.vimeocdn.com/video/807678680.jpg",
    length: 38*60 + 21,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_522_058_223),
    sequence: 9,
    title: "Algebraic Data Types: Exponents",
    trailerVideo: .init(
      bytesLength: 31060549,
      vimeoId: 354215009,
      vimeoSecret: "4f54cb0f33bc6531813335f9f4136c463ea22e10"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Prove the equivalence of `1^a = 1` as types. This requires re-expressing this algebraic equation as types,
and then defining functions between the types that are inverses of each other.
"""),

  Episode.Exercise(problem: """
What is `0^a`? Prove an equivalence. You will need to consider `a = 0` and `a != 0` separately.
"""),

  Episode.Exercise(problem: """
How do you think generics fit into algebraic data types? We've seen a bit of this with thinking of `Optional<A>` as `A + 1 = A + Void`.
"""),

  Episode.Exercise(problem: """
Show that sets with values in `A` can be represented as `2^A`. Note that `A` does not require any `Hashable`
constraints like the Swift standard library `Set<A>` requires.
"""),

  Episode.Exercise(problem: """
Define `intersection` and `union` functions for the above definition of set.
"""),

  Episode.Exercise(problem: """
How can dictionaries with keys in `K` and values in `V` be represented algebraically?
"""),

  Episode.Exercise(problem: """
Implement the following equivalence:

```
func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
  fatalError()
}

func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
  fatalError()
}
```
"""),

  Episode.Exercise(problem: """
Implement the following equivalence:

```
func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
  fatalError()
}

func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
  fatalError()
}
```
"""),
]
