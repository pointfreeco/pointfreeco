import Foundation

// todo: renumber
let post0011_solutionsToZipExercisesPt1 = BlogPost(
  author: .brandon,
  blurb: """
Today we solve the exercises to the first part of our introductory series on zip.
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      //todo

      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0011-solutions-to-zip-pt1/poster.jpg")
    ),

    .init(
      content: """
---

Last week we concluded our 3-part introductory series to the `zip` function. In the
[first episode](/episodes/ep23-the-many-faces-of-zip-part-1) we saw that `zip` goes well beyond the function
that is defined in the Swift standard library, and in fact it generalizes the notion of `map` that we are
familiar with on arrays. At the end of the episode we provided some exercises to help viewers dive a little
deeper into what `zip` had to offer, and this week we solve most of those problems!

---

## Exercise 1

> In this episode we came across closures of the form `{ ($0, $1.0, $1.1) }` a few times in order to unpack a
tuple of the form `(A, (B, C))` to `(A, B, C)`. Create a few overloaded functions named `unpack` to automate
this.

This function can be handy for juggling nested tuples, and it's straightforward to define the first few
overloads:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func unpack<A, B, C>(_ tuple: (A, (B, C))) -> (A, B, C) {
  return (tuple.0, tuple.1.0, tuple.1.1)
}

func unpack<A, B, C, D>(_ tuple: (A, (B, (C, D)))) -> (A, B, C, D) {
  return (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1)
}

func unpack<A, B, C, D, E>(_ tuple: (A, (B, (C, (D, E))))) -> (A, B, C, D, E) {
  return (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1.0 tuple.1.1.1.1)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This function makes it easier to unpack nested zips. For example, higher-order `zip` can now be defined
quite succinctly:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return zip(xs, ys, zs).map(unpack)
}

func zip4<A, B, C, D>(_ xs: [A], _ ys: [B], _ zs: [C], _ ws: [D]) -> [(A, B, C, D)] {
  return zip(xs, ys, zs, ws).map(unpack)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
---

## Exercise 2

> Do you think `zip2` can be seen as a kind of associative infix operator? For example, is it true that
`zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)`? If it's not strictly true, can you define an equivalence
between them?

Unfortunately `zip` cannot be made into an associative infix operator because the resulting type from
`zip(xs, zip(ys, zs))` is `(A, (B, C))`, whereas from `zip(zip(xs, ys), zs)` it is `((A, B), C)`. You
can of course define a `repack` helper that transforms between those nested tuple types, but it's just not
_strictly_ true that `zip` is associative.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
---

## Exercise 3

> Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any
applications of this function?

The most straightforward way to define `unzip` is to simply do two `map`s that each projecct onto a component
of the tuple:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func unzip2(_ pairs: [(A, B)]) -> ([A], [B]) {
  return (pairs.map { $0.0 }, pairs.map { $0.1 })
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
However, this is looping over the array twice, which isn't necessary. To avoid that we can instead use a
mutable variable:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func unzip2(_ pairs: [(A, B)]) -> ([A], [B]) {
  var xs: [A] = []
  var ys: [B] = []
  for (a, b) in pairs {
    xs.append(a)
    ys.append(b)
  }
  return (xs, ys)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
---

## Exercise 4

> It turns out, that unlike the `map` function, `zip2` is not uniquely defined. A single type can have multiple,
completely different `zip2` functions. Can you find another `zip2` on arrays that is different from the one
we defined? How does it differ from our `zip2` and how could it be useful?

What if instead of iterating over both arrays simulataneously to pair off their elements, we paired each
element of the second array with each element of the first array? Essentially, creating an array of all
possible combinations of pairs from both arrays. The implementation might look something like this:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func combos2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  for x in xs {
    for y in ys {
      result.append((x, y))
    }
  }
  return result
}

combos2([1, 2], ["one", "two"])
// [(1, "one"), (1, "two"), (2, "one"), (2, "two")]
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That implementation certainly does the trick, but it's not super functional. Lots of statements instead of
expressions, and lots of mutation. We can simplify things by using `map` and `flatMap` on arrays:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func combos2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in
    ys.map { y in (x, y) }
  }
}

combos2([1, 2], ["one", "two"])
// [(1, "one"), (1, "two"), (2, "one"), (2, "two")]
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Much simpler and succinct!

However, it still is strange that there seem to be two completely different implementations of the
function signature `([A], [B]) -> [(A, B)]`. We will explore this idea more in future Point-Free episodes.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
---

## Exercise 5

> Define `zip2` on the result type: `(Result<A, E>, Result<B, E>) -> Result<(A, B), E>`. Is there more than one
possible implementation? Also define `zip3`, `zip2(with:)` and `zip3(with:)`.
>
> Is there anything that seems wrong or “off” about your implementation? If so, it
will be improved in the next episode 😃.

We ended up solving this in [part 2](/episodes/ep24-the-many-faces-of-zip-part-2) of our zip series.
To implement `zip` on results you must `switch` over two result values, and then handle the four cases.
Three of those cases are straightforward to implement, and in fact there is only one possible implementation.
The last case, however, has two possible implementations, and both throw away some information, which seems
not ideal:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
  switch (a, b) {
  case let (.success(a), .success(b)):
    return .success((a, b))
  case let (.success, .failure(e)):
    return .failure(e)
  case let (.failure(e), .success):
    return .failure(e)
  case let (.failure(e1), .failure(e2)):
    // Two possible implementations...
    return .failure(e1)
    return .failure(e2)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Take note that in the last case we have no choise but to either discard the `e1` error or the `e2` error.
Watch [part 2](/episodes/ep24-the-many-faces-of-zip-part-2) of our `zip` series to understand more in depth
why this is not ideal, and to see how a whole new type that is closely related to `Result` solves this
problem very neatly.

---

## Exercise 6

> In [previous](/episodes/ep14-contravariance) episodes we've considered the type that simply wraps a function,
and let's define it as `struct Func<R, A> { let apply: (R) -> A }`. Show that this type supports a `zip2`
function on the `A` type parameter. Also define `zip3`, `zip2(with:)` and `zip3(with:)`.

We also ended up solving this in [part 2](/episodes/ep24-the-many-faces-of-zip-part-2) of our zip series.
We came up with the following solution:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  return Func<R, (A, B)> { r in
    (r2a.apply(r), r2b.apply(r))
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This allows us to `zip` two functions together as long as their input types are the same. In the
[episode](/episodes/ep24-the-many-faces-of-zip-part-2) we explored this idea a bit more and showed how it
unlocks some interesting expressivity when dealing with lazy values.

---

## Exercise 7

> The nested type `[A]? = Optional<Array<A>>` is composed of two containers, each of which has their own
`zip2` function. Can you define `zip2` on this nested container that somehow involves each of the `zip2`'s
on the container types?

Dealing with nested types can be quite confusing because of the layers, so a trick to simplify a bit is to
define a `typealias` for the nested type:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
typealias OptionalArray<A> = [A]?
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now that we only have one type name to deal with, `OptionalArray`, we can very easily state what its `zip`
signature _should_ look like:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B>(_ a: OptionalArray<A>, _ b: OptionalArray<B>) -> OptionalArray<(A, B)> {
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And how might we implement this? Well, the outer layer, `Optional`, has a `zip` operation for transforming
a tuple of optionals into an optional tuple, so let's start there:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B>(_ a: OptionalArray<A>, _ b: OptionalArray<B>) -> OptionalArray<(A, B)> {
  zip2(a, b) //: ([A], [B])?
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now we have an optional tuple of arrays. We want to apply `zip` to the tuple of arrays, but its trapped
in an optional now. Well, never fear, our old friend `map` can safely open up that optional:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B>(_ a: OptionalArray<A>, _ b: OptionalArray<B>) -> OptionalArray<(A, B)> {
  zip2(a, b).map { zip2($0, $1) } //: [(A, B)]?
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
By `map`ing and then `zip`ing we ended up with an optional array of tuples, which is precisely what we wanted
since the return type is `OptionalArray<(A, B)>`. So, this is the implementation we were looking for, but
let's clean it up a bit by writing it in the [point-free](https://en.wikipedia.org/wiki/Tacit_programming)
style:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B>(_ a: OptionalArray<A>, _ b: OptionalArray<B>) -> OptionalArray<(A, B)> {
  return zip2(a, b).map(zip2)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Short and sweet! To `zip` a nested optional array you simply `map` on the `zip` of the optionals using the
`zip` on arrays as the transformation function.

---

And that's the solutions to the [first part](/episodes/ep23-the-many-faces-of-zip-part-1) of our 3 part
introductory series to `zip`! If you thought those were too easy, be sure to check out the exercises to
[part 2](/episodes/ep24-the-many-faces-of-zip-part-2) and
[part 3](/episodes/ep25-the-many-faces-of-zip-part-3) too. Until next time!
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0011-solutions-to-zip-pt1/poster.jpg",
  id: 11,
  publishedAt: Date(timeIntervalSince1970: 1_532_930_223 + 604_800*2 + 60*60*24),
  title: "Solutions to Exercises: Zip Part 1"
)
