import Foundation

extension Episode {
  static let ep14_contravariance = Episode(
    blurb: """
      Let's explore a type of composition that defies our intuitions. It appears to go in the opposite direction than we are used to. We'll show that this composition is completely natural, hiding right in plain sight, and in fact related to the Liskov Substitution Principle.
      """,
    codeSampleDirectory: "0014-contravariance",
    exercises: _exercises,
    id: 14,
    image: "https://i.vimeocdn.com/video/807679247.jpg",
    length: 38 * 60 + 39,
    permission: .freeDuring(
      Date(timeIntervalSince1970: 1_528_797_423)..<Date(timeIntervalSince1970: 1_529_920_623)),
    publishedAt: Date(timeIntervalSince1970: 1_525_082_223),
    references: [.someNewsAboutContramap, .contravariance],
    sequence: 14,
    title: "Contravariance",
    trailerVideo: .init(
      bytesLength: 54_446_212,
      downloadUrl:
        "https://player.vimeo.com/external/354214967.hd.mp4?s=b8931e84a658cebfc4dff3f143a5afea659651fb&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/354214967"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Determine the sign of all the type parameters in the function `(A) -> (B) -> C`. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.
      """,
    solution: """
      Recall from the episode on [exponents and algebraic data types](/episodes/ep9-algebraic-data-types-exponents) that function arrows parenthesize to the right, which means when we write `(A) -> (B) -> C`, we really mean `(A) -> ((B) -> C)`. Now we can apply the bracketing method we demonstrated in the episode:

      ```
      // (A) -> ((B) -> C)
      //         |_|   |_|
      //         -1    +1
      // |_|    |________|
      // -1        +1
      ```

      So now we see that `A` is negative, `B` is also negative, and `C` is positive.
      """),
  Episode.Exercise(
    problem: """
      Determine the sign of all the type parameters in the following function:

      ```
      (A, B) -> (((C) -> (D) -> E) -> F) -> G
      ```
      """,
    solution: """
      We will apply the bracketing method to this expression, it's just a little more involved:

      ```
      // (A, B) -> (((C) -> (D) -> E) -> F) -> G
      //             |_|    |_|   |_|
      //             -1     -1    +1
      // |_||_|     |_______________|   |_|
      // +1 +1             -1           +1
      // |____|    |______________________|   |_|
      //   -1                 -1              +1
      ```

      That's intense! One tricky part is how we determined that the `A` and `B` inside the tuple were in positive position, and this is because tuples are naturally a covariant structure: you can define `map` on the first and second components.

      Now all we have to do is trace through the layers and multiply all the signs:

      ```
      * A = -1 * +1 = -1
      * B = -1 * +1 = -1
      * C = -1 * -1 * -1 = -1
      * D = -1 * -1 * -1 = -1
      * E = -1 * -1 * +1 = +1
      * F = -1 * +1 = -1
      * G = +1
      ```

      And there you have it!
      """),
  Episode.Exercise(
    problem: """
      Recall that [a setter is just a function](/episodes/ep6-functional-setters#t813) `((A) -> B) -> (S) -> T`. Determine the variance of each type parameter, and define a `map` and `contramap` for each one. Further, for each `map` and `contramap` write a description of what those operations mean intuitively in terms of setters.
      """,
    solution: """
      Again applying the bracketing method we see:

      ```
      // ((A) -> B) -> (S) -> T
      //  |_|   |_|
      //  -1    +1
      // |________|    |_|   |_|
      //     -1        -1    +1
      ```

      So now we see:

      * `A = -1 * -1 = +1`
      * `B = -1 * +1 = -1`
      * `S = -1`
      * `T = +1`

      This means we should be able to define `map` on `A` and `T`, and `contramap` on `B` and `S`. Here are the implementations of each, with comments that show the types of all the parts we need to plug together:

      ```
      typealias Setter<S, T, A, B> = ((@escaping (A) -> B) -> (S) -> T

      func map<S, T, A, B, C>(_ f: @escaping (A) -> C)
        -> (@escaping Setter<S, T, A, B>)
        -> Setter<S, T, C, B> {

          return { setter in
            return { update in
              return { s in
                // f: (A) -> C
                // setter: ((A) -> B) -> (S) -> T
                // update: (C) -> B
                // s: S
                setter(f >>> update)(s)
              }
            }
          }
      }

      func map<S, T, U, A, B>(_ f: @escaping (T) -> U)
        -> (@escaping Setter<S, T, A, B>)
        -> Setter<S, U, A, B> {

          return { setter in
            return { update in
              return { s in
                // f: (T) -> U
                // setter: ((A) -> B) -> (S) -> T
                // update: (A) -> B
                // s: S
                f(setter(update)(s))
              }
            }
          }
      }

      func contramap<S, T, A, B, C>(_ f: @escaping (C) -> B)
        -> (@escaping Setter<S, T, A, B>)
        -> Setter<S, T, A, C> {

          return { setter in
            return { update in
              return { s in
                // f: (C) -> B
                // setter: ((A) -> B) -> (S) -> T
                // update: (A) -> C
                // s: S
                setter(update >>> f)(s)
              }
            }
          }
      }

      func contramap<S, T, U, A, B>(_ f: @escaping (U) -> S)
        -> (@escaping Setter<S, T, A, B>)
        -> Setter<U, T, A, B> {

          return { setter in
            return { update in
              return { u in
                // f: (U) -> S
                // setter: ((A) -> B) -> (S) -> T
                // update: (A) -> B
                // u: U
                setter(update)(f(u))
              }
            }
          }
      }
      ```

      It's interesting to see that the implementation of `map` on `A` is quite similar to `contramap` on `B`, and `map` on `T` is similar to `contramap` on `S`.
      """),
  Episode.Exercise(
    problem: """
      Define `union`, `intersect`, and `invert` on `PredicateSet`.
      """),
  Episode.Exercise(
    problem: """
      This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.

      1. Create a predicate set `powersOf2: PredicateSet<Int>` that determines if a value is a power of `2`, _i.e._
      `2^n` for some `n: Int`.
      1. Use the above predicate set to derive a new one `powersOf2Minus1: PredicateSet<Int>` that tests if a number
      is of the form `2^n - 1` for `n: Int`.
      1. Find an algorithm online for testing if an integer is prime, and turn it into a predicate
      `primes: PredicateSet<Int>`.
      1. The intersection `primes.intersect(powersOf2Minus1)` consists of numbers known as
      [Mersenne primes](https://en.wikipedia.org/wiki/Mersenne_prime). Compute the first 10.
      1. Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and
      `intersect`?
      1. What is the difference between `primes.intersect(powersOf2Minus1)` and `powersOf2Minus1.intersect(primes)`?
      Which one represents a more performant predicate set?
      """),
  Episode.Exercise(
    problem: """
      It turns out that dictionaries `[K: V]` do not have `map` on `K` for all the same reasons `Set` does not. There is an alternative way to define dictionaries in terms of functions. Do that and define `map` and `contramap` on that new structure.
      """),
  Episode.Exercise(
    problem: """
      Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).
      """),
  Episode.Exercise(
    problem: """
      Let's explore what happens when a type parameter appears multiple times in a function signature.

      1. Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or `contramap` on `A`.
      1. Is `A` in positive or negative position in `(A, A) -> B`? Define either `map` or `contramap`.
      1. Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because functions whose input type is the same as the output type are called "endomorphisms". Notice that `A` is in both positive and negative position. Does that mean that _both_ `map` and `contramap` can be defined, or that neither can be defined?
      1. Turns out, `Endo` has a different structure on it known as an "invariant structure", and it comes equipped with a different kind of function called `imap`. Can you figure out what it's signature should be?
      """),
  Episode.Exercise(
    problem: """
      Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper around an equality check. You can think of it as a kind of "type erased" `Equatable` protocol. Write `contramap` for this type.
      """),
  Episode.Exercise(
    problem: """
      Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the "type erased" analogy, this is like a "witness" to the `Equatable` conformance of `Int`. Show how to use `contramap` defined above to transform `intEquate` into something that defines equality of strings based on their character count.
      """),
]
