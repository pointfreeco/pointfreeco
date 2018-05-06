import Foundation

let post0003_ep14Solutions = BlogPost(
  author: .brandon,
  blurb: """
This week we solve the exercises from our episode on contravariance, because there were _a lot_ of
them!
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0003-solutions-to-exercises-contravariance/poster.jpg")
    ),

    .init(
      content: """
      In [episode #14](\(url(to: .episode(.right(14))))) we explored the idea of contravariance and it led us
      to some interesting forms of compositions. The episode also had a large number of exercises, 18 in
      total(!), and they went pretty deep into topics that we didn’t have time to cover.

      In today’s Point-Free Pointer we want to provide solutions to those exercises. If you haven’t yet had a
      chance to try solving them on your own, we highly recommend giving it a shot before reading further.

      ---

      ### Exercise 1

      > Determine the sign of all the type parameters in the function (A) -> (B) -> C. Note that this is a
      > curried function. It may be helpful to fully parenthesize the expression before determining variance.

      Recall from the episode on [exponents and algebraic data types](\(url(to: .episode(.right(9)))))
      that function arrows parenthesize to the right, which means when we write `(A) -> (B) -> C`, we really
      mean `(A) -> ((B) -> C)`. Now we can apply the bracketing method we demonstrated in the episode:
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
      ---

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

      ---

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

      Ok, we've now defined all these functions, but what do they _mean_? Well, they all mean that we can
      lift transformations on parts and wholes up to transformations on setters, but let's look at some
      examples.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 4

      > Define `union`, `intersect`, and `invert` on `PredicateSet`.

      These functions directly correspond to applying `||`, `&&` and `!` pointwise on the predicates:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      extension PredicateSet {
        func union(_ other: PredicateSet) -> PredicateSet {
          return PredicateSet { self.contains($0) || other.contains($0) }
        }

        func intersect(_ other: PredicateSet) -> PredicateSet {
          return PredicateSet { self.contains($0) && other.contains($0) }
        }

        var invert: PredicateSet {
          return PredicateSet { !self.contains($0) }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 5.1

      > Create a predicate set `powersOf2: PredicateSet<Int>` that determines if a value is a power of `2`,
      i.e. `2^n` for some `n: Int`.

      There's a fun trick you can perform to compute this easily. A power of two written in binary form
      has the expression `1000...0`, i.e. a `1` followed by sum number of `1`'s, whereas the number that came
      just before it has the expression `111...1`, i.e. all `1`'s and one less digit. So, to see if an integer
      `n` is a power of two we could just `&` the bits of `n` and `n - 1` and see if we get `0`:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      let powersOf2 = PredicateSet<Int> { n in
        n > 0 && (n & (n - 1) == 0)
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 5.2

      > Use the above predicate set to derive a new one `powersOf2Minus1: PredicateSet<Int>` that tests
      if a number is of the form `2^n - 1` for `n: Int`.

      We can `contramap` on `powersOf2` to shift them all by one. However, which direction do we shift?
      Should we shift `-1` or `+1`?

      Well, in order to test if a number is of the form `2^n - 1` using our `powersOf2` predicate set, we
      first need to shift the number up one, and then check if it's a power of two. Therefore
      `powersOf2Minus1` can be defined as such:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      let powersOf2Minus1 = powersOf2.contramap { $0 + 1 }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 5.3

      > Find an algorithm online for testing if an integer is prime, and turn it into a
      predicate `primes: PredicateSet<Int>`.

      The easiest (and most naive) way to tell if `n` is prime is to loop over all the integers from 2 to
      `n - 1` and see if it divides evenly into `n`. One optimization we can make is to only loop over
      integers less than or equal to `sqrt(n)`. The reason is that `n`'s factors cannot all be greater
      than `sqrt(n)`, for then their product would be greater than `n`.

      This description of the algorithm can be translated into code:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      let primes = PredicateSet<Int> { n in
        guard n != 2 else { return true }

        let upperBound = max(2, Int(floor(sqrt(Double(n)))))
        return (2...upperBound)
          .lazy
          .map { n % $0 == 0 }
          .first(where: { $0 == true }) == nil
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      A few notes about this. First, we guard `n != 2` to simplify constructing the range from `2` to
      `sqrt(n)`. Also, the construction of the upper bound of that range is a little complicated in order
      to dance around Swift's numeric system. However, once we are passed that it's pretty straightforward.
      We use `lazy` on the range so that we can early out the moment we find a divisor. We `map` to compute
      if a value in the range is a divisor of `n`, and then we find the first one that is `true`. Finally,
      if that search came up `nil`, we know we have a prime!
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 5.4

      > The intersection `primes.intersect(powersOf2Minus1)` consists of numbers known as Mersenne primes.
      Compute the first `10`.

      We made a small mistake with this one...we didn't mean to ask for you to compute 10! That's too many,
      so let's just compute 5. All we have to do is iterate over all positive integers and test them
      against the Mersenne set. We can use `lazy`+`filter`+`prefix` to do this!
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      (2...)
        .lazy
        .filter(mersennePrimes.contains)
        .prefix(5)
        .forEach { n in
          print(n) // 3, 7, 31, 127, 8191
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      And we can see that indeed all of those primes are one less than a power of 2!

      Now, this isn't the most performant way to do this, we just wanted to illustrate the idea of combining
      complex sets in interesting ways. What's a more performant way to do this?
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 5.5

      > Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and
      `intersect`?

      Short-circuiting `&&` and `||` means that `false && x` and `true || x` does not evaluate the expression
      `x` at all since it already knows the outcome of the logical expression. So, if `x` were an expensive
      computation we would be saving all of that work.

      Applying this to `PredicateSet`, we see that since `union` and `intersect` were really just `||` and
      `&&` under the hood, we can get short-circuiting behavior in our sets too. This means you should
      put all of your most expensive work last when it comes to chaining `union`'s and `intersect`'s together.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 5.6

      > What is the difference between `primes.intersect(powersOf2Minus1)` and
      `powersOf2Minus1.intersect(primes)`? Which one represents a more performant predicate set?

      From the last exercise we can see that `primes.intersect(powersOf2Minus1)` is a worse performing
      set than `powersOf2Minus1.intersect(primes)` since the `primes` calculation is much more expensive
      than the `powersOf2Minus1` computation. Try swapping the order in the `mersenne` calculation to see
      how much faster it can compute the first 5.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 6

      > It turns out that dictionaries `[K: V]` do not have map on `K` for all the same reasons `Set` does not.
      There is an alternative way to define dictionaries in terms of functions. Do that and define map
      and contramap on that new structure.

      A dictionary `[K: V]` is just a "partial" mapping of keys to values, where partial means that not
      every key is mapped to a value. This is precisely a function `(K) -> V?`. Defining `map` and
      `contramap` on this type is similar to defining it on functions, except we have to deal with that
      optional value, which we can do with `map` on optionals!
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      struct FuncDictionary<K, V> {
        let valueForKey: (K) -> V?

        func map<W>(_ f: @escaping (V) -> W) -> FuncDictionary<K, W> {
          return .init { key in self.valueForKey(key).map(f) }
        }

        func contramap<L>(_ f: @escaping (L) -> K) -> FuncDictionary<L, V> {
          return .init { key in self.valueForKey(f(key)) }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 7

      > Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are
      currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).

      We can define a character set as simply a predicate set on characters:
      `typealias CharacterSet = PredicateSet<Character>`. Let's define a character set that holds all
      newlines:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      extension PredicateSet where A == Character {
        static var newlines: PredicateSet {
          return PredicateSet(
            contains: Set<Character>(
              [
                .init(Unicode.Scalar(0x000A)),
                .init(Unicode.Scalar(0x000B)),
                .init(Unicode.Scalar(0x000C)),
                .init(Unicode.Scalar(0x000D)),
                .init(Unicode.Scalar(0x0085)),
                .init(Unicode.Scalar(0x2028)),
                .init(Unicode.Scalar(0x2029))
              ]
              ).contains
          )
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 8.1

      > Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or
      `contramap` on `A`.

      As we have seen, tuples are a covariant construction since we can define `map` on each of their
      components (we did this with `first` and `second` in episodes [#6](\(url(to: .episode(.right(6)))))
      and [#7](\(url(to: .episode(.right(7))))). So, we'd expect functions _into_ a covariant structure to
      also be covariant, and indeed:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      func map<A, B, C>(_ f: @escaping (A) -> C) -> ((B) -> (A, A)) -> ((B) -> (C, C)) {
        return { g in
          return { b in
            let (first, second) = g(b)
            return (g(first), g(second))
          }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      What we are seeing is that if a type parameter appears multiple times in a signature, and all times
      it appears on the right side of `->`, then we can consider the parameter covariant and thus can
      define `map`.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 8.2

      > Is `A` in positive or negative position in `(A, A) -> B`? Define either map or contramap.

      Again, tuples are covariant, and so putting them in a negative position might turn them negative.
      Let's try defining `contramap`:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      func map<A, B, C>(_ f: @escaping (C) -> A) -> ((A, A) -> B) -> ((C, C) -> B) {
        return { g in
          return { c1, c2 in
            let (a1, a2) = (f(c1), f(c2))
            return g(a1, a2)
          }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      What we are seeing is that if a type parameter appears multiple times in a signature, and all times
      it appears on the left side of `->`, then we can consider the parameter contravariant and thus can
      define `contramap`.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 8.3

      > Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because
      functions whose input type is the same as the output type are called "endomorphisms". Notice that
      `A` is in both positive and negative position. Does that mean that both `map` and `contramap` can be
      defined, or that neither can be defined?

      Well, let's try defining each of `map` and `contramap` on `Endo` and see what goes wrong or right:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      extension Endo {
        func map<B>(_ f: @escaping (A) -> B) -> Endo<B> {
          return Endo<B> { b in
            b // B
            f // (A) -> B
            fatalError("Need to return something in B")
          }
        }

        func contramap<B>(_ f: @escaping (B) -> A) -> Endo<B> {
          return Endo<B> { b in
            b // B
            f // (B) -> A
            fatalError("Need to return something in B")
          }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      So, the types we have at our disposal in the `Endo<B>` block don't exactly match up. In `map` we need
      to return something in `B` while we have `b: B` and `f: (A) -> B`. Now, of course we could just return
      `b`, but we didn't use `f` at all, and that seems weird! Likewise, for `contramap` we need to return
      something in `B` and have `b: B` and `f: (B) -> A` at our disposal, so the only thing we can do is
      return `b` and ignore `f` entirely. Very strange!

      It seems that although `map` and `contramap` can be defined on `Endo`, neither one does anything
      interesting.  They just return the identity endomorphism, regardless of what `f` is.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 8.4

      > Turns out, `Endo` has a different structure on it known as an “invariant structure”, and it comes
      equipped with a different kind of function called `imap`. Can you figure out what it’s signature should
      be?

      Since neither `map` nor `contramap` were very interesting, maybe `imap` will have more to it. In both
      potential implementations of `map` and `contramap` on `Endo` we saw that we were missing some way
      of transporting values in the opposite direction of the `f` provided. For example, in `contramap`
      we could apply `f(b)` to get something in `A`, but then we would need some way to transform back to
      something in `B`.

      Perhaps `imap` needs to functions going both ways!
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      extension Endo {
        func imap<B>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Endo<B> {
          return Endo<B> { b in
            f(self.apply(g(b)))
          }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      This shows that if a type parameter appears on _both_ sides of `->` in a function signature, then
      to transform on that parameter you need something like `imap`, which comes equipped with functions
      _into and out of_ the type.
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      ---

      ### Exercise 9

      > Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper
      around an equality check. You can think of it as a kind of “type erased” `Equatable` protocol. Write
      `contramap` for this type.

      This `contramap` is quite similar to some of the other ones we've written:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      extension Equate {
        func contramap<B>(_ f: @escaping (B) -> A) -> Equate<B> {
          return .init { self.equals(f($0), f($1)) }
        }
      }
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      ### Exercise 10

      > Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the “type erased” analogy,
      this is like a “witness” to the `Equatable` conformance of Int. Show how to use `contramap` defined
      above to transform `intEquate` into something that defines equality of strings based on their character
      count.

      We can induce an `Equate` value on strings by contramapping over its character count. Here are two
      ways of doing it:
      """,
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
      intEquate.contramap { (a: String, b: String) in a.count == b.count }

      // Using the `their` function from episode #8: Key Paths and Getters
      intEquate.contramap(their(\\String.count, ==))
      """,
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
      ---

      _Phew_! That was a lot!

      Well, that concludes this week's Point-Free Pointer. I hope that breaking down the exercises helped
      you learn something new about the material, and encouraged you to try more exercises from our
      episodes. They are a great opportunity to dig a lil deeper.

      Until next time!
      """,
      timestamp: nil,
      type: .paragraph
    ),

    ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0003-solutions-to-exercises-contravariance/poster.jpg",
  id: 3,
  publishedAt: .init(timeIntervalSince1970: 1_525_665_662),
  title: "Solutions to Exercises: Contravariance"
)
