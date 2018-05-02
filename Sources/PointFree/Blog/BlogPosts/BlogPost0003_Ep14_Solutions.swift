import Foundation

let post0003_ep14Solutions = BlogPost(
  author: .brandon,
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: """
      In [episode #14](\(url(to: .episode(.right(14))))) we explored the idea of contravariance and it led us
      to some interesting forms of compositions. The episode also had a large number of exercises, 18 in
      total(!), and they went pretty deep into topics that we didn’t have time to cover.

      In today’s Point-Free Pointer we want to provide solutions to those exercises. If you haven’t yet had a
      chance to try solving them on your own, we highly recommend giving it a short before reading further.

      ---

      ### Exercise 1

      > Determine the sign of all the type parameters in the function (A) -> (B) -> C. Note that this is a
      > curried function. It may be helpful to fully parenthesize the expression before determining variance.

      Recall from the episode on exponents and algebraic data types that function arrows parenthesize to the
      right, which means when we write `(A) -> (B) -> C`, we really mean `(A) -> ((B) -> C)`. Now we can
      apply the bracketing method we demonstrated in the episode:

      So now we see that `A` is negative, `B` is also negative, and `C` is positive.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      // (A) -> ((B) -> C)
      //         |_|   |_|
      //         -1    +1
      // |_|    |________|
      // -1        +1
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      So now we see that `A` is negative, `B` is also negative, and `C` is positive.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ### Exercise 2

      > Determine the sign of all the type parameters in the following function:
      > `(A, B) -> (((C) -> (D) -> E) -> F) -> G`

      We will apply the bracketing method to this expression, it's just a little more involved:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      // (A, B) -> (((C) -> (D) -> E) -> F) -> G
      //             |_|    |_|   |_|
      //             -1     -1    +1
      // |_||_|     |_______________|   |_|
      // +1 +1             -1           +1
      // |____|    |______________________|   |_|
      //   -1                 -1              +1
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      That's intense! One tricky part is how we determined that the `A` and `B` inside the tuple were in
      positive position, and this is because tuples are naturally a covariant structure: you can define
      `map` on the first and second components.

      Now all we have to do is trace through the layers and multiply all the signs:

      * `A = -1 * +1 = -1`
      * `B = -1 * +1 = -1`
      * `C = -1 * -1 * -1 = -1`
      * `D = -1 * -1 * -1 = -1`
      * `E = -1 * -1 * +1 = +1`
      * `F = -1 * +1 = -1`
      * `G = +1`

      And there you have it!

      ### Exercise 3

      > Recall that a setter is just a function `((A) -> B) -> (S) -> T`. Determine the variance of each
      > type parameter, and define a map and contramap for each one. Further, for each map and contramap
      > write a description of what those operations mean intuitively in terms of setters.

      Again applying the bracketing method we see:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      // ((A) -> B) -> (S) -> T
      //  |_|   |_|
      //  -1    +1
      // |________|    |_|   |_|
      //     -1        -1    +1
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      So now we see:

      * `A = -1 * -1 = +1`
      * `B = -1 * +1 = -1`
      * `S = -1`
      * `T = +1`

      This means we should be able to define `map` on `A` and `T`, and `contramap` on `B` and `S`. Here
      are the implementations of each, with comments that show the types of all the parts we need to plug
      together:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
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
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      It's interesting to see that the implementation of `map` on `A` is quite similar to `contramap` on
      `B`, and `map` on `T` is similar to `contramap` on `S`.

      Ok, we've now defined all these functions, but what do they _mean_? Well, `map` on `A` means
      """,
      timestamp: nil,
      type: .paragraph
    ),

    ],
  coverImage: "TODO",
  id: 3,
  publishedAt: .init(timeIntervalSince1970: 1_525_665_662),
  title: "Solutions to Exercises: Contravariance"
)
