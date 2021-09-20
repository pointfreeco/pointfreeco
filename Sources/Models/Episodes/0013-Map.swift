import Foundation

extension Episode {
  static let ep13_theManyFacesOfMap = Episode(
    blurb: """
Why does the `map` function appear in every programming language supporting "functional" concepts? And why does Swift have _two_ `map` functions? We will answer these questions and show that `map` has many universal properties, and is in some sense unique.
""",
    codeSampleDirectory: "0013-the-many-faces-of-map",
    exercises: _exercises,
    id: 13,
    image: "https://i.vimeocdn.com/video/807679165.jpg",
    length: 31*60 + 48,
    permission: .freeDuring(Date(timeIntervalSince1970: 1_524_477_423)..<Date(timeIntervalSince1970: 1559541600)),
    publishedAt: Date(timeIntervalSince1970: 1_524_477_423),
    references: [.theoremsForFree],
    sequence: 13,
    title: "The Many Faces of Map",
    trailerVideo: .init(
      bytesLength: 57789611,
      vimeoId: 354214965,
      vimeoSecret: "9e2cb40eadea330d69402a6e9844293fb6a4e47f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: """
Implement a `map` function on dictionary values, i.e.

```
map: ((V) -> W) -> ([K: V]) -> [K: W]
```

Does it satisfy `map(id) == id`?
"""),

  Episode.Exercise(problem: """
Implement the following function:

```
transformSet: ((A) -> B) -> (Set<A>) -> Set<B>
```

We do not call this `map` because it turns out to not satisfy the properties of `map` that we saw in this
episode. What is it about the `Set` type that makes it subtly different from `Array`, and how does that
affect the genericity of the `map` function?
"""),

  Episode.Exercise(problem: """
Recall that one of the most useful properties of `map` is the fact that it distributes over compositions,
i.e. `map(f >>> g) == map(f) >>> map(g)` for any functions `f` and `g`. Using the `transformSet` function
you defined in a previous example, find an example of functions `f` and `g` such that

```
transformSet(f >>> g) != transformSet(f) >>> transformSet(g)
```

This is why we do not call this function `map`.
"""),

  Episode.Exercise(problem: """
There is another way of modeling sets that is different from `Set<A>` in the Swift standard library. It
can also be defined as function `(A) -> Bool` that answers the question "is `a: A` contained in the set."
Define a type `struct PredicateSet<A>` that wraps this function. Can you define the following?

```
map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>
```

What goes wrong?
"""),

  Episode.Exercise(problem: """
Try flipping the direction of the arrow in the previous exercise. Can you define the following function?

```
fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>
```
"""),

  Episode.Exercise(problem: """
What kind of laws do you think `fakeMap` should satisfy?
"""),

  Episode.Exercise(problem: """
Sometimes we deal with types that have multiple type parameters, like `Either` and `Result`. For those types
you can have multiple `map`s, one for each generic, and no one version is “more” correct than the other.
Instead, you can define a `bimap` function that takes care of transforming both type parameters at once. Do
this for `Result` and `Either`.
"""),

  Episode.Exercise(problem: """
Write a few implementations of the following function:

```
func r<A>(_ xs: [A]) -> A? {
}
```
"""),

  Episode.Exercise(problem: """
Continuing the previous exercise, can you generalize your implementations of `r` to a function `[A] -> B?`
if you had a function `f: (A) -> B`?

```
func s<A, B>(_ f: (A) -> B, _ xs: [A]) -> B? {
}
```

What features of arrays and optionals do you need to implement this?
"""),

  Episode.Exercise(problem: """
Derive a relationship between `r`, any function `f: (A) -> B`, and the `map` on arrays and optionals.

This relationship is the "free theorem" for `r`'s signature.
"""),
]
