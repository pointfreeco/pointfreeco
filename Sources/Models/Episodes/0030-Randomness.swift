import Foundation

extension Episode {
  static let ep30_composableRandomness = Episode(
    blurb: """
      Randomness is a topic that may not seem so functional, but it gives us a wonderful opportunity to explore composition. After a survey of what randomness looks like in Swift today, we'll build a complex set of random APIs from just a single unit.
      """,
    codeSampleDirectory: "0030-composable-randomness",
    exercises: _exercises,
    id: 30,
    image: "https://i.vimeocdn.com/video/802688724.jpg",
    length: 40 * 60 + 30,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_537_163_823),
    references: [.randomZalgoGenerator],
    sequence: 30,
    title: "Composable Randomness",
    trailerVideo: .init(
      bytesLength: 29_177_507,
      downloadUrl:
        "https://player.vimeo.com/external/351175150.hd.mp4?s=73403f198bf79c495f09540b3836314cde4417b4&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/351175150"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Create a function called `frequency` that takes an array of pairs, `[(Int, Gen<A>)]`, to create a `Gen<A>` such that `(2, gen)` is twice as likely to be run than a `(1, gen)`.
      """),
  Episode.Exercise(
    problem: """
      Extend `Gen` with an `optional` computed property that returns a generator that returns `nil` a quarter of the time. What other generators can you compose this from?
      """),
  Episode.Exercise(
    problem: """
      Extend `Gen` with a `filter` method that returns a generator that filters out random entries that don't match the predicate. What kinds of problems may this function have?
      """),
  Episode.Exercise(
    problem: """
      Create a `string` generator of type `Gen<String>` that randomly produces a randomly-sized string of any unicode character. What smaller generators do you composed it from?
      """),
  Episode.Exercise(
    problem: """
      Redefine `element(of:)` to work with any `Collection`. Can it also be redefined in terms of `Sequence`?
      """),
  Episode.Exercise(
    problem: """
      Create a `subsequence` generator to return a randomly-sized, randomly-offset subsequence of an array. Can it be redefined in terms of `Collection`?
      """),
  Episode.Exercise(
    problem: """
      The `Gen` type has `map` defined it, which, as we've seen in the past, allows us to consider what `zip` might look like. Define `zip2` on `Gen`:

      ``` swift
      func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)>
      ```
      """),
  Episode.Exercise(
    problem: """
      Define `zip2(with:)`:

      ``` swift
      func zip2<A, B, C>(with f: (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C>
      ```
      """),
  Episode.Exercise(
    problem: """
      With `zip2` and `zip2(with:)` defined, define higher-order `zip3` and `zip3(with:)` and explore some uses. What functionality does `zip` provide our `Gen` type?
      """),
]
