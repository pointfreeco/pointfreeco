import Foundation

extension Episode {
  static let ep4_algebraicDataTypes = Episode(
    blurb: """
      What does the Swift type system have to do with algebra? A lot! We’ll begin to explore this correspondence \
      and see how it can help us create type-safe data structures that can catch runtime errors at compile time.
      """,
    codeSampleDirectory: "0004-algebraic-data-types",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 194_777_227,
      downloadUrls: .s3(
        hd1080: "0004-1080p-9dab8002b3c54758b4856a521086e114",
        hd720: "0004-720p-062b964b22b44488bbbd4683988548c3",
        sd540: "0004-540p-0122829a2ac048b3a71b41b91fcdf439"
      ),
      vimeoId: 355_115_428
    ),
    id: 4,
    length: 2_172,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_519_045_951),
    references: [
      .makingIllegalStatesUnrepresentable
    ],
    sequence: 4,
    title: "Algebraic Data Types",
    trailerVideo: .init(
      bytesLength: 37_267_895,
      downloadUrls: .s3(
        hd1080: "0004-trailer-1080p-2a68a514275a4cfc85d5246c397fadca",
        hd720: "0004-trailer-720p-71e8e6fc666d45c4b00951550819244a",
        sd540: "0004-trailer-540p-d07c80f547fe401e96a1dd0282e1feb5"
      ),
      vimeoId: 354_215_001
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 4)
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating
      all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and
      `(Three) -> Bool` to get some intuition.
      """,
    solution: """
      For every input, a function must assign a _single_ output. Viewed this way, we can enumerate implementations for the cited functions:

      `(Bool) -> Bool`

      - `true -> true, false -> true`
      - `true -> false, false -> false`
      - `true -> false, false -> true`
      - `true -> true, false -> false`

      ⇒ four inhabitants of `(Bool) -> Bool`.

      `(Unit) -> Bool`

      - `Unit() -> true`
      - `Unit() -> false`

      ⇒ two inhabitants of `(Unit) -> Bool`.

      `(Bool) -> Three`

      - `true` and `false` both need to be mapped onto `Three` ⇒ we have three choices for `true` and three for `false` ⇒ nine inhabitants of `(Bool) -> Three`.

      `(Three) -> Bool`

      Each member of `Three`—`.one`, `.two`, and `.three`—need to be mapped onto `Bool` ⇒ we have two choices per case, totaling at `2*2*2 = 2^3 = 8` inhabitants of `(Three) -> Bool`.

      More generally, functions from `A -> B` correspond to the cardinality of `B` raised to `A`’s cardinality, i.e. `B^A`.
      """
  ),

  Episode.Exercise(
    problem: """
      Consider the following recursively defined data structure:

      ```
      indirect enum List<A> {
        case empty
        case cons(A, List<A>)
      }
      ```

      Translate this type into an algebraic equation relating `List<A>` to `A`.
      """,
    solution: """
      Since `List` is a sum type and the `List.cons` has two associated values (a tuple), we can expand its cardinality as follows:

      `List<A> = 1 + A * List<A>`

       And recursing,

      ```
      List<A>
      = 1 + A * (1 + A * List<A>)
      = 1 + A + A*A * List<A>
      = 1 + A + A*A * (1 + A * List<A>)
      = 1 + A + A*A + A*A*A * List<A>
      = 1 + A + A*A + A*A*A + A*A*A*A * ...
      ```
      """
  ),

  Episode.Exercise(
    problem: """
      Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional
      values does one type have that the other doesn't?
      """,
    solution: """
      `Optional<Either<A, B>> = (A + B) + 1 = A + B + 1`

      `Either<Optional<A>, Optional<B>> = (A + 1) + (B + 1) = A + B + 1 + 1`

      They’re not equivalent. `Either<Optional<A>, Optional<B>>` has _one_ more inhabitant than `Optional<Either<A, B>>`.

      We can think of `Optional<Either<A, B>>` as

      ```
      case some(Either<A, B>), case none
      ```

      and `Either<Optional<A>, Optional<B>>`—when expanded—as

      ```
      case some(Either<A, B>), case none, case other
      ```

      where the `other` case is the extra `1` in the equations above.
      """
  ),

  Episode.Exercise(
    problem: """
      Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
      """,
    solution: """
      `Either<Optional<A>, B> = (A + 1) + B = A + B + 1`

      `Optional<Either<A, B>> = (A + B) + 1 = A + B + 1`

      They’re equivalent!
      """
  ),

  Episode.Exercise(
    problem: """
      Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload
      the `*` and `+` infix operators with functions that take any type and build up an algebraic
      representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest
      themselves in the resulting types.
      """,
    solution: """
      ```
      enum Either<A, B> {
        case left(A)
        case right(B)
      }

      struct Pair<A, B> {
        let first: A
        let second: B
      }

      func * <A, B> (lhs: A.Type, rhs: B.Type) -> Pair<A, B>.Type {
        return Pair<A, B>.self
      }

      func + <A, B> (lhs: A.Type, rhs: B.Type) -> Either<A, B>.Type {
        return Either<A, B>.self
      }
      ```

      To explore the precedence rules of both operators, let’s check the the type of the following expression:

      ```
      Void.self + String.self * Int.self
      ```

      It’s `Either<Void, Pair<String, Int>>`, which is expected, since multiplication takes precedence over addition ⇒ `String` and `Int` would be `Pair`’d before joining under an `Either` with `Void`.
      """
  ),
]
