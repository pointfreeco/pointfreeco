import Foundation

extension Episode {
  static let ep42_theManyFacesOfFlatMap_pt1 = Episode(
    blurb: """
Previously we've discussed the `map` and `zip` operations in detail, and today we start completing the trilogy by exploring `flatMap`. This operation is precisely the tool needed to solve a nesting problem that `map` and `zip` alone cannot.
""",
    codeSampleDirectory: "0042-the-many-faces-of-flatmap-pt1",
    exercises: _exercises,
    id: 42,
    length: 25 * 60 + 9,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1546844400),
    references: [
      .railwayOrientedProgramming,
      reference(
        forEpisode: .ep10_aTaleOfTwoFlatMaps,
        additionalBlurb: """
Up until Swift 4.1 there was an additional `flatMap` on sequences that we did not consider in this episode, but that's because it doesn't act quite like the normal `flatMap`. Swift ended up deprecating the overload, and we discuss why this happened in a previous episode:
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep10-a-tale-of-two-flat-maps"
      )
    ],
    sequence: 42,
    title: "The Many Faces of Flat‑Map: Part 1",
    trailerVideo: .init(
      bytesLength: 96616356,
      downloadUrls: .s3(
        hd1080: "0042-trailer-1080p-06e2b74c902740c3a22215a3f5bdd41c",
        hd720: "0042-trailer-720p-1d683f05250d46238c63e7df9618e538",
        sd540: "0042-trailer-540p-becab98d9e4b4be2998b706b7ad24a65"
      ),
      vimeoId: 348589500
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
In this episode we saw that the `combos` function on arrays can be implemented in terms of `flatMap` and `map`. The `zip` function on arrays as the same signature as `combos`. Can `zip` be implemented in terms of `flatMap` and `map`?
"""),
  .init(problem: """
Define a `flatMap` method on the `Result<A, E>` type. Its signature looks like:

```
(Result<A, E>, (A) -> Result<B, E>) -> Result<B, E>
```

It only changes the `A` generic while leaving the `E` fixed.
"""),
  .init(problem: """
Can the `zip` function we defined on `Result<A, E>` in [episode #24](/episodes/ep24-the-many-faces-of-zip-part-2#t98) be implemented in terms of the `flatMap` you implemented above? If so do it, otherwise explain what goes wrong.
"""),
  .init(problem: """
Define a `flatMap` method on the `Validated<A, E>` type. Its signature looks like:

```
(Validated<A, E>, (A) -> Validated<B, E>) -> Validated<B, E>
```

It only changes the `A` generic while leaving the `E` fixed. How similar is it to the `flatMap` you defined on `Result`?
"""),
  .init(problem: """
Can the `zip` function we defined on `Validated<A, E>` in [episode #24](/episodes/ep24-the-many-faces-of-zip-part-2#t367) be defined in terms of the `flatMap` above? If so do it, otherwise explain what goes wrong.
"""),
  .init(problem: """
Define a `flatMap` method on the `Func<A, B>` type. Its signature looks like:

```
(Func<A, B>, (B) -> Func<A, C>) -> Func<A, C>
```

It only changes the `B` generic while leaving the `A` fixed.
"""),
  .init(problem: """
Can the `zip` function we defined on `Func<A, B>` in [episode #24](/episodes/ep24-the-many-faces-of-zip-part-2#t817) be implemented in terms of the `flatMap` you implemented above? If so do it, otherwise explain what goes wrong.
"""),
  .init(problem: """
Define a `flatMap` method on the `Parallel<A>` type. Its signature looks like:

```
(Parallel<A>, (A) -> Parallel<B>) -> Parallel<B>
```
"""),
  .init(problem: """
Can the `zip` function we defined on `Parallel<A>` in [episode #24](/episodes/ep24-the-many-faces-of-zip-part-2#t1252) be implemented in terms of the `flatMap` you implemented above? If so do it, otherwise explain what goes wrong.
"""),
]
