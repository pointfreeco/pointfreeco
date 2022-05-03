import Foundation

extension Episode {
  static let ep24_theManyFacesOfZip_pt2 = Episode(
    blurb: """
      In part two of our series on `zip` we will show that many types support a `zip`-like operation, and some even support multiple distinct implementations. However, not all `zip`s are created equal, and understanding this can lead to some illuminating properties of our types.
      """,
    codeSampleDirectory: "0024-zip-pt2",
    exercises: _exercises,
    id: 24,
    length: 36 * 60 + 01,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_532_930_223),
    references: [.swiftValidated],
    sequence: 24,
    title: "The Many Faces of Zip: Part 2",
    trailerVideo: .init(
      bytesLength: 66_405_830,
      downloadUrls: .s3(
        hd1080: "0024-trailer-1080p-e7c88182fda847b7b2377b58183df4a8",
        hd720: "0024-trailer-720p-5cd9e5a4b2ed4d3bac718893e78bb0b2",
        sd540: "0024-trailer-540p-672a5b96db8246bdaa4bc742b9e26d16"
      ),
      vimeoId: 351_175_698
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Can you make the `zip2` function on our `F3` type thread safe?
      """),

  .init(
    problem: """
      Generalize the `F3` type to a type that allows returning values other than `Void`: `struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type parameter.
      """),

  .init(
    problem: """
      Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on
      it?
      """),

  .init(
    problem: """
      This exercise explore what happens when you nest two types that each support a `zip` operation.

      - Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also
      the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip
      structures? Write the signature of such a function and implement it.
      - Using the `zip2` defined above write an example usage of it involving two `[A]?` values.
      - Consider the type `[Validated<A, E>]`. We again have have a nesting of types, each of which have their
      own `zip2` operation. Can you define a `zip2` on this type that makes use of both `zip` structures? Write
      the signature of such a function and implement it.
      - Using the `zip2` defined above write an example usage of it involving two `[Validated<A, E>]` values.
      - Consider the type `Func<R, A?>`. Again we have a nesting of types, each of which have their own `zip2`
      operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of
      such a function and implement it.
      - Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2`
      operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of
      such a function and implement it.
      - Finally, conisder the type `F3<Validated<A, E>>`. Yet again we have a nesting of types, each of which have
      their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write
      the signature of such a function and implement it.
      """),

  .init(
    problem: """
      Do you see anything common in the implementation of all of the functions in the previous exercise? What this
      is showing is that nested zippable containers are also zippable containers because `zip` on the nesting can
      be defined in terms of zip on each of the containers.
      """),
]
