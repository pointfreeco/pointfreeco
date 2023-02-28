import Foundation

extension Episode {
  static let ep25_theManyFacesOfZip_pt3 = Episode(
    blurb: """
      The third, and final, part of our introductory series to `zip` finally answers the question: "What's the point?"
      """,
    codeSampleDirectory: "0025-zip-pt3",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 501_551_082,
      downloadUrls: .s3(
        hd1080: "0025-1080p-0c3662f1b2a24327b506998491fcf9b2",
        hd720: "0025-720p-273cf96a66e64a50bf2de80281cb4b4a",
        sd540: "0025-540p-f44d76562ee74d05b1d88555295ff8c7"
      ),
      vimeoId: 351_397_230
    ),
    id: 25,
    length: 24 * 60 + 21,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_532_930_223 + 604_800),
    references: [.swiftValidated],
    sequence: 25,
    title: "The Many Faces of Zip: Part 3",
    trailerVideo: .init(
      bytesLength: 79_605_908,
      downloadUrls: .s3(
        hd1080: "0025-trailer-1080p-5ba9c219f88943f8b50372f58262e04c",
        hd720: "0025-trailer-720p-a8e7ddc2769a4cb5b3eb577cdbc92c78",
        sd540: "0025-trailer-540p-ba75dc231bdb4103b34c0db39f90579e"
      ),
      vimeoId: 351_175_721
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 25)
  )
}

private let _exercises: [Episode.Exercise] = [

  .init(
    problem: """
      In this series of episodes on `zip` we have described zipping types as a kind of way to swap the order of
      nested containers when one of those containers is a tuple, e.g. we can transform a tuple of arrays to an
      array of tuples `([A], [B]) -> [(A, B)]`. There's a more general concept that aims to flip containers of any
      type. Implement the following to the best of your ability, and describe in words what they represent:

      - `sequence: ([A?]) -> [A]?`
      - `sequence: ([Result<A, E>]) -> Result<[A], E>`
      - `sequence: ([Validated<A, E>]) -> Validated<[A], E>`
      - `sequence: ([Parallel<A>]) -> Parallel<[A]>`
      - `sequence: (Result<A?, E>) -> Result<A, E>?`
      - `sequence: (Validated<A?, E>) -> Validated<A, E>?`
      - `sequence: ([[A]]) -> [[A]]`. Note that you can still flip the order of these containers even though they
      are both the same container type. What does this represent? Evaluate the function on a few sample nested
      arrays.

      Note that all of these functions also represent the flipping of containers, e.g. an array of optionals
      transforms into an optional array, an array of results transforms into a result of an array, or a
      validated optional transforms into an optional validation, etc.

      Do the implementations of these functions have anything in common, or do they seem mostly distinct from
      each other?
      """),

  .init(
    problem: """
      There is a function closely related to `zip` called `apply`. It has the following shape:
      `apply: (F<(A) -> B>, F<A>) -> F<B>`. Define `apply` for `Array`, `Optional`, `Result`, `Validated`,
      `Func` and `Parallel`.
      """),

  .init(
    problem: """
      Another closely related function to `zip` is called `alt`, and it has the following shape:
      `alt: (F<A>, F<A>) -> F<A>`. Define `alt` for `Array`, `Optional`, `Result`, `Validated` and `Parallel`.
      Describe what this function semantically means for each of the types.
      """),

]
