import Foundation

extension Episode {
  static let ep19_algebraicDataTypes_genericsAndRecursion = Episode(
    blurb: """
Our third installment of algebraic data types explores how generics and recursive data types manifest themselves in algebra. This exploration allows us to construct a useful, precise type that can be useful in everyday programming.
""",
    codeSampleDirectory: "0019-algebraic-data-types-pt3",
    exercises: _exercises,
    id: 19,
    length: 47*60 + 01,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_528_711_023),
    sequence: 19,
    title: "Algebraic Data Types: Generics and Recursion",
    trailerVideo: .init(
      bytesLength: 55979211,
      downloadUrls: .s3(
        hd1080: "0019-trailer-1080p-ccbfdf0aa82348f4847b0b26ff566123",
        hd720: "0019-trailer-720p-2e2e7852eeab4291b54820843f27bc02",
        sd540: "0019-trailer-540p-228fc14424e74c508922ae0395f80ca8"
      ),
      vimeoId: 352312239
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Define addition and multiplication on `NaturalNumber`:

* `func +(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber`
* `func *(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber`
"""),

  .init(problem: """
Implement the `exp` function on `NaturalNumber` that takes a number to a power:

`exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber`
"""),

  .init(problem: """
Conform `NaturalNumber` to the `Comparable` protocol.
"""),

  .init(problem: """
Implement `min` and `max` functions for `NaturalNumber`.
"""),

  .init(problem: """
How could you implement *all* integers (both positive and negative) as an algebraic data type? Define all of the above functions and conformances on that type.
"""),

  .init(problem: """
What familiar type is `List<Void>` equivalent to? Write `to` and `from` functions between those types showing how to travel back-and-forth between them.
"""),

  .init(problem: """
Conform `List` and `NonEmptyList` to the `ExpressibleByArrayLiteral` protocol.
"""),

  .init(problem: """
Conform `List` to the `Collection` protocol.
"""),

  .init(problem: """
Conform each implementation of `NonEmptyList` to the `Collection` protocol.
"""),

  .init(problem: """
Consider the type `enum List<A, B> { cae empty; case cons(A, B) }`. It's kinda like list without recursion, where the recursive part has just been replaced with another generic. Now consider the strange type:

```
enum Fix<A> {
  case fix(ListF<A, Fix<A>>)
}
```

Construct a few values of this type. What other type does `Fix` seem to resemble?
"""),

  .init(problem: """
Construct an explicit mapping between the `List<A>` and `Fix<A>` types by implementing:

* `func to<A>(_ list: List<A>) -> Fix<A>`
* `func from<A>(_ fix: Fix<A>) -> List<A>`

The type `Fix` is known as the "fixed-point" of `List`. It is more generic than just dealing with lists, but unfortunately Swift does not have the type feature (higher-kinded types) to allow us to express this.
"""),
]
