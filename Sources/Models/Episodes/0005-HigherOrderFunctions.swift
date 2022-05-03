import Foundation

extension Episode {
  static let ep5_higherOrderFunctions = Episode(
    blurb: """
      Most of the time we interact with code we did not write, and it doesn’t always play nicely with the types \
      of compositions we have developed in previous episodes. We explore how higher-order functions can help \
      unlock even more composability in our everyday code.
      """,
    codeSampleDirectory: "0005-higher-order-functions",
    exercises: _exercises,
    id: 5,
    length: 1350,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_519_653_423),
    references: [
      .everythingsAFunction
    ],
    sequence: 5,
    title: "Higher-Order Functions",
    trailerVideo: .init(
      bytesLength: 37_233_625,
      downloadUrls: .s3(
        hd1080: "0005-trailer-1080p-08b9b49c4abe49a190f3ba16a8b92208",
        hd720: "0005-trailer-720p-59ef26534ee34aa4ba4a027db9cbc54b",
        sd540: "0005-trailer-540p-a7d82d9abf1b44cfa2aad16683195415"
      ),
      vimeoId: 354_215_008
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Write `curry` for functions that take 3 arguments.
      """,
    solution: """
      ```
      func curry<A, B, C, Z>(
        _ f: @escaping (A, B, C) -> Z
      ) -> (A) -> (B) -> (C) -> Z {

        return { a in { b in { c in f(a, b, c) } } }
      }
      ```
      """),

  Episode.Exercise(
    problem: """
      Explore functions and methods in the Swift standard library, Foundation, and other third party code, and
      convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
      """),

  Episode.Exercise(
    problem: """
      Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C`
      equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as
      you build deeper, curried functions?
      """,
    solution: """
      If the function `((A) -> B) -> C` were equivalent to `(A) -> ((B) -> C)` then we'd be able to write a function that can transform from one to the other. For example, we would be able to implement this function:

      ```
      func equivalence<A, B, C>(
        _ f: @escaping (A) -> ((B) -> C)
      ) -> ((A) -> B) -> C {
        return { f in
          // How to return something in C in here???
        }
      }
      ```

      However, it is not possible to implement this function.

      It turns out, the function arrow `->` only associates to the right. So if we were to write:

      ```
      f: (A) -> (B) -> (C) -> D
      ```

      what that really means is:

      ```
      f: (A) -> ((B) -> ((C) -> D))
      ```
      """),

  Episode.Exercise(
    problem: """
      Write a function, `uncurry`, that takes a curried function and returns a function that takes two
      arguments. When might it be useful to un-curry a function?
      """),

  Episode.Exercise(
    problem: """
      Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
      """,
    solution: """
      The reduce method on collections takes two arguments: the initial value to reduce into, and the accumulation function that takes what has been accumulated so far and a value from the array and must return a new accumulation value. The accumulation function is most like configuration in that it describes how to perform the reduce, and is most likely to be reused across many reduces. Whereas the initial value, and the collection being operated on, are like the data since it's what you aren't likely to have access to until the moment you want to reduce. So a possible curried signature of `reduce` might take the accumulation upfront, and delay the initial value and collection:

      ```
      func reduce<A, R>(
        _ accumulator: (R, A) -> R
      ) -> (R) -> ([A]) -> R {

        return { initialValue in
          return { collection in
            return collection.reduce(initialValue, accumulator)
          }
        }
      }
      ```
      """),

  Episode.Exercise(
    problem: """
      In programming languages that lack sum/enum types one is tempted to approximate them with pairs of
      optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent
      the creation of invalid values by providing initializers.

      This is "type safe" in the sense that you are not allowed to construct invalid values, but not
      "type safe" in the sense that the compiler is proving it to you. You must prove it to yourself.
      """,
    solution: """
      The `PseudoEither` type could be defined as:

      ```
      struct PseudoEither<A, B> {
        let left: A?
        let right: B?

        init(left: A) {
          self.left = left
          self.right = nil
        }

        init(right: B) {
          self.left = nil
          self.right = right
        }
      }
      ```

      It is not possible to construct values of `PseudoEither` where both `left` and `right` hold some value, but nevertheless it is not the compiler proving this but rather you having to make sure this remains true. We talk more about this in our episode on [algebraic data types](/episodes/ep4-algebraic-data-types).
      """),

  Episode.Exercise(
    problem: """
      Explore how the free `map` function composes with itself in order to transform a nested array. More
      specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation
      on the inner array or the outer array. Can you make sense of doing `map >>> map`?
      """),
]
