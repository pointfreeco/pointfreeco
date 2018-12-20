import Foundation

let ep25 = Episode(
  blurb: """
The third, and final, part of our introductory series to `zip` finally answers the question: "What's the point?"
""",
  codeSampleDirectory: "0025-zip-pt3",
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 483_556_172,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/full-720p-1FD9673E-3713-4DF5-B11B-943B93088F9C.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/full/0025-zip-pt-3-AC022B4FFFEB.m3u8"
  ),
  id: 25,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/itunes-poster.jpg",
  length: 24*60 + 21,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_532_930_223 + 604_800),
  references: [.swiftValidated],
  sequence: 25,
  title: "The Many Faces of Zip: Part 3",
  trailerVideo: .init(
    bytesLength: 41_732_099,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/trailer-720p.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0025-zip-pt3/trailer/0025-trailer.m3u8"
  ),
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [

  .init(body: """
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

  .init(body: """
There is a function closely related to `zip` called `apply`. It has the following shape:
`apply: (F<(A) -> B>, F<A>) -> F<B>`. Define `apply` for `Array`, `Optional`, `Result`, `Validated`,
`Func` and `Parallel`.
"""),

  .init(body: """
Another closely related function to `zip` is called `alt`, and it has the following shape:
`alt: (F<A>, F<A>) -> F<A>`. Define `alt` for `Array`, `Optional`, `Result`, `Validated` and `Parallel`.
Describe what this function semantically means for each of the types.
"""),

]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: (0*60 + 05),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We're now in the 3rd and final part of our introduction to the `zip` function. Let's do a quick recap of the first two episodes.
""",
    timestamp: (0*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In [the first episode](https://www.pointfree.co/episodes/ep23-the-many-faces-of-zip-part-1) we showed that the Swift standard library has a `zip` function for combining sequences, and that it can be pretty useful. But then we zoomed out a bit so that we could concentrate on just its shape, and saw that it did something very peculiar: it allowed us to transform a tuple of arrays into an array of tuples. It flipped those containers around. We then zoomed out even more and showed that `zip` in fact generalizes the notion of `map` on arrays. And finally that empowered us to define `zip` on optionals, which previously probably would have seemed weird, but was in fact a very natural thing to do.
""",
    timestamp: (0*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Then in [episode 2](https://www.pointfree.co/episodes/ep24-the-many-faces-of-zip-part-2) we continued the theme of defining `zip` on types that we don't normally think of as having a `zip` operation. We started with the `Result` type, which actually had two `zip`s, but neither seemed like the "right" one. Then we defined the `Validated` type, a close relative of the `Result` type, and it had a `zip` operation that was very useful and clearly the "right" one.
""",
    timestamp: (1*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We kept going and defined `zip` on functions that have the same input type. It seemed strange, but we applied it to zipping lazy values and we were able to write some code that really crammed a lot of powerful ideas in a small package.
""",
    timestamp: (1*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And then we ended the episode with yet another type that has a `zip` operation, it was the strange `F3` type from our `map` episode that we have vaguely alluded to being related to callbacks that we see in `UIView` animations and `URLSession` blocks. We showed that this type had two `zip` operations, but one didn't feel quite right and the other did.
""",
    timestamp: (1*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In this episode we are finally going to answer "what's the point?" for the past two episodes. Because although we've shown some cool uses of `zip`, is it enough for us to bring in more zips into our codebases at the end of the day?
""",
    timestamp: (2*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: (2*60 + 39),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
And we say yes!

In the episode on `map` one of the things I thought was cool was showing that `map` was not just some handy thing that was given to us by the designers of the Swift standard library. It was a universal concept just waiting to be discovered. This empowered us to define `map` on our own types, which allows us to create really expressive code.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Understanding this for `zip` allows us to do the same, but the results are maybe even a little more impressive.
""",
    timestamp: (3*60 + 02),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Before diving in, let's take a quick look at all the code we've written so far in this series.
""",
    timestamp: (3*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
First, we have a whole bunch of `zip` functions. First, from [our first episode](https://www.pointfree.co/episodes/ep23-the-many-faces-of-zip-part-1), `zip` on arrays:
""",
    timestamp: (3*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  (0..<min(xs.count, ys.count)).forEach { idx in
    result.append((xs[idx], ys[idx]))
  }
  return result
}

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return zip2(xs, zip2(ys, zs)) // [(A, (B, C))]
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> ([A], [B]) -> [C] {

  return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> ([A], [B], [C]) -> [D] {

  return { zip3($0, $1, $2).map(f) }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And from [the same episode](https://www.pointfree.co/episodes/ep23-the-many-faces-of-zip-part-1), `zip` on optionals:
""",
    timestamp: (3*60 + 40),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard let a = a, let b = b else { return nil }
  return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
  return zip2(a, zip2(b, c))
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> (A?, B?) -> C? {

  return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (A?, B?, C?) -> D? {

  return { zip3($0, $1, $2).map(f) }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then, in [the 2nd episode](https://www.pointfree.co/episodes/ep24-the-many-faces-of-zip-part-2), we introduced the `Result` type, [reminded ourselves](https://www.pointfree.co/episodes/ep13-the-many-faces-of-map) what its `map` operation looked like, and asked: what would a `zip` operation look like?
""",
    timestamp: (3*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Result<A, E> {
  case success(A)
  case failure(E)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case let .success(a):
      return .success(f(a))
    case let .failure(e):
      return .failure(e)
    }
  }
}

func zip2<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {

  switch (a, b) {
  case let (.success(a), .success(b)):
    return .success((a, b))
  case let (.success, .failure(e)):
    return .failure(e)
  case let (.failure(e), .success):
    return .failure(e)
  case let (.failure(e1), .failure(e2)):
//    return .failure(e1)
    return .failure(e2)
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What we saw was that in the case where we have two `failure`s, we have to make a choice: we either take the first failure, or the second failure, and either way we're discarding information.
""",
    timestamp: (4*60 + 08),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Then what we showed was that if we imported [our NonEmpty library](https://github.com/pointfreeco/swift-nonempty) and defined the `Validated` type, a relative of `Result`, its `map` operation looks the same, but its `zip` operation lets us concatenate errors together, which means we're no longer discarding information.
""",
    timestamp: (4*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
import NonEmpty

enum Validated<A, E> {
  case valid(A)
  case invalid(NonEmptyArray<E>)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
  return { result in
    switch result {
    case let .valid(a):
      return .valid(f(a))
    case let .invalid(e):
      return .invalid(e)
    }
  }
}

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {

  switch (a, b) {
  case let (.valid(a), .valid(b)):
    return .valid((a, b))
  case let (.valid, .invalid(e)):
    return .invalid(e)
  case let (.invalid(e), .valid):
    return .invalid(e)
  case let (.invalid(e1), .invalid(e2)):
    return .invalid(e1 + e2)
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And with `zip2` defined, we can define the other versions of `zip` very easily.
""",
    timestamp: (5*60 + 01),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B, C, E>(
  with f: @escaping (A, B) -> C
  ) -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, E>(_ a: Validated<A, E>, _ b: Validated<B, E>, _ c: Validated<C, E>) -> Validated<(A, B, C), E> {
  return zip2(a, zip2(b, c))
    |> map { a, bc in (a, bc.0, bc.1) }
}

func zip3<A, B, C, D, E>(
  with f: @escaping (A, B, C) -> D
  ) -> (Validated<A, E>, Validated<B, E>, Validated<C, E>) -> Validated<D, E> {

  return { zip3($0, $1, $2) |> map(f) }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then we looked at our `Func` type, which is just a wrapper around a function, and which also has a `map` operation.
""",
    timestamp: (5*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct Func<R, A> {
  let apply: (R) -> A
}

func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
  return { r2a in
    return Func { r in
      f(r2a.apply(r))
    }
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Then we defined `zip2`:
""",
    timestamp: (5*60 + 16),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  return Func<R, (A, B)> { r in
    (r2a.apply(r), r2b.apply(r))
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And the other `zip` functions come easily enough:
""",
    timestamp: (5*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip3<A, B, C, R>(
  _ r2a: Func<R, A>,
  _ r2b: Func<R, B>,
  _ r2c: Func<R, C>
  ) -> Func<R, (A, B, C)> {

  return zip2(r2a, zip2(r2b, r2c)) |> map { ($0, $1.0, $1.1) }
}

func zip2<A, B, C, R>(
  with f: @escaping (A, B) -> C
  ) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, D, R>(
  with f: @escaping (A, B, C) -> D
  ) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {

  return { zip3($0, $1, $2) |> map(f) }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Finally we came to the `F3` type, which wraps a function that takes a function as input that returns `Void`.
""",
    timestamp: (5*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We pasted in its `map` function, which we [previously defined](https://www.pointfree.co/episodes/ep13-the-many-faces-of-map).
""",
    timestamp: (5*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    return F3 { callback in
      f3.run { callback(f($0)) }
    }
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And then we defined `zip2`.
""",
    timestamp: (5*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B>(_ fa: Parallel<A>, _ fb: Parallel<B>) -> Parallel<(A, B)> {
  return Parallel<(A, B)> { callback in
    var a: A?
    var b: B?
    fa.run {
      a = $0
      if let b = b { callback(($0, b)) }
    }
    fb.run {
      b = $0
      if let a = a { callback((a, $0)) }
    }
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We ended up with an implementation that ran each value indendently, saving the results in a mutable variable so that once both callbacks completed, we can invoke the main callback with both values.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And with that defined we get our other `zip`s.
""",
    timestamp: (6*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> (Parallel<A>, Parallel<B>) -> Parallel<C> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C>(_ fa: Parallel<A>, _ fb: Parallel<B>, _ fc: Parallel<C>) -> Parallel<(A, B, C)> {
  return zip2(fa, zip2(fb, fc)) |> map { ($0, $1.0, $1.1) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (Parallel<A>, Parallel<B>, Parallel<C>) -> Parallel<D> {

  return { zip3($0, $1, $2) |> map(f) }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So that's the big overview. Let's get to some new code.
""",
    timestamp: (6*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can start by defining a simple data struct to play with:
""",
    timestamp: (6*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct User {
  let email: String
  let id: Int
  let name: String
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: "Array",
    timestamp: (6*60 + 33),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's say we want to initialize a value of this type, but we don't have the data for the fields immediately as plain strings and ints, they are instead wrapped up in some context. For example, we could load arrays of values for each of the fields, perhaps from a CSV or database:
""",
    timestamp: (6*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let emails = ["blob@pointfree.co", "blob.jr@pointfree.co", "blob.sr@pointfree.co"]
let ids = [1, 2, 3]
let names = ["Blob", "Blob Junior", "Blob Senior"]
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can't immediately construct a `User` from these values, but `zip3(with:)` precisely allows us to create an array of users from this data:
""",
    timestamp: (6*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let users = zip3(with: User.init)(
  emails,
  ids,
  names
)
// [
//   {email "blob@pointfree.co", id 1, name "Blob"},
//   {email "blob.jr@pointfree.co", id 2, name "Blob Junior"},
//   {email "blob.sr@pointfree.co", id 3, name "Blob Senior"}
// ]
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Remember that `zip` bakes in safety if any of these arrays is shorter than the others: it always zips up to the point of the shortest one.
""",
    timestamp: (7*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Adding an `id` doesn't change the result.
""",
    timestamp: (7*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let emails = ["blob@pointfree.co", "blob.jr@pointfree.co", "blob.sr@pointfree.co"]
let ids = [1, 2, 3, 4]
let names = ["Blob", "Blob Junior", "Blob Senior"]

let users = zip3(with: User.init)(
  emails,
  ids,
  names
)
// [
//   {email "blob@pointfree.co", id 1, name "Blob"},
//   {email "blob.jr@pointfree.co", id 2, name "Blob Junior"},
//   {email "blob.sr@pointfree.co", id 3, name "Blob Senior"}
// ]
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
While one fewer `id` results in one fewer user.
""",
    timestamp: (7*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let emails = ["blob@pointfree.co", "blob.jr@pointfree.co", "blob.sr@pointfree.co"]
let ids = [1, 2]
let names = ["Blob", "Blob Junior", "Blob Senior"]

let users = zip3(with: User.init)(
  emails,
  ids,
  names
)
// [
//   {email "blob@pointfree.co", id 1, name "Blob"},
//   {email "blob.jr@pointfree.co", id 2, name "Blob Junior"}
// ]
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is a nice, expressive way of creating an array of users from arrays of values.
""",
    timestamp: (7*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is pretty neat. We were able to take the `User.init` initializer that just takes regular strings and ints, and lift it up to work with arrays so that we can initialize _arrays_ of users from arrays of strings and ints.
""",
    timestamp: (8*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now, we don't really need to explain the point of `zip` on arrays: the standard library authors have already included it with Swift. Optionals, on the other hand...
""",
    timestamp: (8*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Optional",
    timestamp: (8*60 + 28),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Optionals provide another context with which we can explore `zip`.
""",
    timestamp: (8*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's take the same `User` data type, but apply a different context. Instead of those fields being held in arrays, what if they were optional?
""",
    timestamp: (8*60 + 36),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let optionalEmail: String? = "blob@pointfree.co"
let optionalId: Int? = 42
let optionalName: String? = "Blob"
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Well, now we can create an optional user from this data by using our `zip3(with:)` function on optionals:
""",
    timestamp: (8*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let optionalUser = zip3(with: User.init)(
  optionalEmail,
  optionalId,
  optionalName
)
// Optional(User(email: "blob@pointfree.co", id: 42, name: "Blob"))
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we change any of these fields to `nil`...
""",
    timestamp: (9*60 + 07),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let optionalEmail: String? = "blob@pointfree.co"
let optionalId: Int? = nil
let optionalName: String? = "Blob"

let optionalUser = zip3(with: User.init)(
  optionalEmail,
  optionalId,
  optionalName
)
// nil
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
...we see we get `nil` for the user.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is a handy way or requiring a bunch of inputs in a declarative way. And in fact, we saw in the first episode of this series that this is nothing more than an expressive version of multiple `if/guard let`s on the same line. If this was important enough to be made a language feature in Swift 2, it's clearly a useful concept. And even though we have multiple `if/guard let`s at our disposal now, `zip` and `zip(with:)` can still clean up a lot of code.
""",
    timestamp: (9*60 + 12),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
So now we have two different ways of initializing users from values that are wrapped up in other context. Let's explore another.
""",
    timestamp: (9*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Validated",
    timestamp: (10*60 + 06),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now let's consider what would happen if our data was held in validated values. We'll have a few functions that validate each raw input.
""",
    timestamp: (10*60 + 06),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func validate(email: String) -> Validated<String, String> {
  return email.index(of: "@") == nil
    ? .invalid(NonEmptyArray("email is invalid"))
    : .valid(email)
}

func validate(id: Int) -> Validated<Int, String> {
  return id <= 0
    ? .invalid(NonEmptyArray("id must be positive"))
    : .valid(id)
}

func validate(name: String) -> Validated<String, String> {
  return name.isEmpty
    ? .invalid(NonEmptyArray("name can't be blank"))
    : .valid(name)
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Each of these functions just takes a raw value and performs a check to see if it's valid for the program. If it's valid, it wraps this value up in `Validated`'s `valid` case. If it's invalid, it wraps up an error in the `invalid` case—well, in a `NonEmptyArray`, since an empty array of errors doesn't make a lot of sense. We covered non-empty collections earlier in [two](https://www.pointfree.co/episodes/ep19-algebraic-data-types-generics-and-recursion) [separate](https://www.pointfree.co/episodes/ep20-nonempty) episodes.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now we can create a validated user from this data by using our `zip3(with:)` function on validated values:
""",
    timestamp: (11*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let validatedUser = zip3(with: User.init)(
  validate(email: "blob@pointfree.co"),
  validate(id: 42),
  validate(name: "Blob")
)
// valid(User(email: "blob@pointfree.co", id: 42, name: "Blob"))
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've lifted `User.init` up to the world of `Validated`: given validated values, you will get a validated user.
""",
    timestamp: (11*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And if we change any of these validations to be invalid, we will get an `invalid` value!
""",
    timestamp: (12*60 + 09),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let validatedUser = zip3(with: User.init)(
  validate(email: "blobpointfree.co"),
  validate(id: 42),
  validate(name: "Blob")
)
// invalid("email is invalid"[])
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And multiple failures result in multiple errors. They accumulate in that non-empty array.
""",
    timestamp: (12*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let validatedUser = zip3(with: User.init)(
  validate(email: "blobpointfree.co"),
  validate(id: 0),
  validate(name: "")
)
// invalid("email is invalid"["id is invalid", "name can't be blank"])
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The `Validated` context allows us to now see _everything_ that went wrong when we tried to create this user.
""",
    timestamp: (12*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With array and optional, it wasn't a stretch to see the point: the standard library provides `zip` on arrays, and the language provides its own sugar for `zip` on optionals. This `Validated` type is something we introduced to Swift, though, and it might be the strongest case for `zip` yet. We're able to reuse the shape of `zip` on this type and get something that the language has no support for out of the box: accumulating errors. Swift so far has only adopted `throws` for error handling, and the first error always wins. `Validated` and the structure of `zip` gives us a powerful feature _today_, basically for free.
""",
    timestamp: (12*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Func",
    timestamp: (13*60 + 43),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now let's do something really wild. Let's see what would happen if our data was held in closures. We'll use the `Func` type we defined earlier:
""",
    timestamp: (13*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let emailProvider = Func<Void, String> { "blob@pointfree.co" }
let idProvider = Func<Void, Int> { 42 }
let nameProvider = Func<Void, String> { "Blob" }
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
These `Func`s merely wrap some constants, but you can imagine that we might be loading these values from disk, from a database, or from the network.
""",
    timestamp: (14*60 + 11),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can create a "user provider" from this data by using our `zip3(with:)` function on functions:
""",
    timestamp: (14*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
zip3(with: User.init)(
  emailProvider,
  idProvider,
  nameProvider
)
// Func<(), User>
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What we get back is a brand new value in `Func` which produces a users.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And none of the earlier `Func`s have been called. If we _were_ doing a side effect in any of them, calling `zip` does _not_ execute that side effect.
""",
    timestamp: (14*60 + 54),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's replace a value with a side effect.
""",
    timestamp: (15*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let nameProvider = Func<Void, String> {
  (try? String(contentsOf: URL(string: "https://www.pointfree.co")!))
    .map { $0.split(separator: " ")[1566] }
    .map(String.init)
    ?? "PointFree"
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And as it stands, this code doesn't yet run.
""",
    timestamp: (15*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now, our value in `name` requires the network, where it'll pluck a word off [the Point-Free homepage](https://www.pointfree.co). We can call `apply` on `Func` to invoke the function it wraps.
""",
    timestamp: (15*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
zip3(with: User.init)(
  emailProvider,
  idProvider,
  nameProvider
).apply(())
// User(email: "blob@pointfree.co", id: 42, name: "Monday")
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we have our unwrapped `User` value, where its name is a result of hitting the network.
""",
    timestamp: (15*60 + 28),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
On Point-Free we stress the importance of isolating [side effects](https://www.pointfree.co/episodes/ep2-side-effects) and writing as much logic as we can using pure functions, which are easier to test and reason about. What we've done here is wrap a bunch of side effects in lazy `Func` values, and `zip` allowed us to take some pure logic (the `User` initializer), and lift it into that world.
""",
    timestamp: (15*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This example may be harder to see than the others, but it's still amazing to see yet another thing that `zip` is capable of. We're going to go deeper with this kind of laziness in a future episode.
""",
    timestamp: (16*60 + 03),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "F3",
    timestamp: (16*60 + 27),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
What if our values were held in those weird `F3` types?
""",
    timestamp: (16*60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In order to make things interesting, we're going to reuse the `delay` helper we defined [last time](https://www.pointfree.co/episodes/ep24-the-many-faces-of-zip-part-2), which given a duration, delays a block of code from running while printing some logging along the way.
""",
    timestamp: (16*60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
import Foundation

func delay(by duration: TimeInterval, line: UInt = #line, execute: @escaping () -> Void) {
  print("delaying line \\(line) by \\(duration)")
  DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
    execute()
    print("executed line \\(line)")
  }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can now define the following values wrapped in `F3`s.
""",
    timestamp: (17*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let delayedEmail = F3<String> { callback in
  delay(by: 0.2) { callback("blob@pointfree.co") }
}
let delayedId = F3<Int> { callback in
  delay(by: 0.5) { callback(42) }
}
let delayedName = F3<String> { callback in
  delay(by: 1) { callback("Blob") }
}
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So how can we create a `User` from this data? We can use `zip3(with:)` again.
""",
    timestamp: (17*60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
zip3(with: User.init)(
  delayedEmail,
  delayedId,
  delayedName
)
// F3<User>
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we have an `F3` that wraps a `User`. None of the code in each delayed block has executed. In order to get at the value wrapped in the `F3`, we need to `run` it and supply a callback.
""",
    timestamp: (17*60 + 42),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
zip3(with: User.init)(
  delayedEmail,
  delayedId,
  delayedName
  ).run { user in
    print(user)
}
// delaying line 301 by 0.2
// delaying line 304 by 0.5
// delaying line 307 by 1.0
// executed line 301
// executed line 304
// User(email: "blob@pointfree.co", id: 42, name: "Blob")
// executed line 307
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Changing the delays can make things more noticeable, like delaying the email by 3 seconds.
""",
    timestamp: (18*60 + 29),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let delayedEmail = F3<String> { callback in
  delay(by: 3) { callback("blob@pointfree.co") }
}
let delayedId = F3<Int> { callback in
  delay(by: 0.5) { callback(42) }
}
let delayedName = F3<String> { callback in
  delay(by: 1) { callback("Blob") }
}

zip3(with: User.init)(
  delayedEmail,
  delayedId,
  delayedName
  ).run { user in
    print(user)
}
// delaying line 301 by 3.0
// delaying line 304 by 0.5
// delaying line 307 by 1.0
// executed line 304
// executed line 307
// User(email: "blob@pointfree.co", id: 42, name: "Blob")
// executed line 301
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What we see now is that it waits for that final email value to be delivered before delivering a user.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And we see that the entire execution took about 3 seconds. We didn't have to wait 3 + 0.5 + 1 seconds in order to get the result. We only had to wait for the _longest_ of the delays.
""",
    timestamp: (18*60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We've spent a lot of time with `F3` and its shape, and by focusing on its shape and not its name we got a good feel for the shape of `map` and `zip`. But I think it's time to give it a proper name.
""",
    timestamp: (19*60 + 19),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Parallel",
    timestamp: (19*60 + 33),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's rename `F3` to `Parallel`.
""",
    timestamp: (19*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
What we have here is a type that is highly specialized for running a task where its execution flow is decoupled from anything else. Because of that, the `zip` operation can take a bunch of `Parallel` values and run them independently in parallel before bringing the values together again.
""",
    timestamp: (19*60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Yet another example of the point! The `zip` function introduces the notion of concurrency. Swift doesn't have a concurrency story yet. The main tool we have at our disposal is GCD, but GCD is a complicated API and doesn't even provide the ability to run a bunch of tasks and collect their values before bringing them all together again, which is what the `zip` operation does. The `zip` operation seems to be one of the most fundamental units of concurrency.
""",
    timestamp: (20*60 + 00),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now, `Parallel` as defined is hardly ready for production, but we'll have future episodes where we fix these problems and make this type usable in your code base.
""",
    timestamp: (20*60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "All together",
    timestamp: (20*60 + 47),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Alright, so that was five, mini-"what's the point"s, where we explored the point of `zip` for five different contexts. But there's something magical going on here. Let's collect all of our zipped users in one place:
""",
    timestamp: (20*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
zip3(with: User.init)(
  emails,
  ids,
  names
)
zip3(with: User.init)(
  optionalEmail,
  optionalId,
  optionalName
)
zip3(with: User.init)(
  validate(email: "blobpointfree.co"),
  validate(id: 0),
  validate(name: "")
)
zip3(with: User.init)(
  emailProvider,
  idProvider,
  nameProvider
)
zip3(with: User.init)(
  delayedEmail,
  delayedId,
  delayedName
)
""",
    timestamp: (21*60 + 00),
    type: .code(lang: .swift)  ),
  Episode.TranscriptBlock(
    content: """
They all look almost identical. We have completely abstracted away what it means to take many values boxed up in some kind of container and combine them into just a single instance of that container. All of these disparate concepts, things like arrays, optionals, validations, lazy values and delayed values, have been unified under the umbrella of "zippable" containers. That means we can reuse intuitions. We can look at `zip` and just know that we're looking to combine a bunch of values into a single container.
""",
    timestamp: (21*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And this is just five types _so far_. We're going to continue to explore `zip` on other types in the future. And our viewers should take a look at their own types and see, if it has a `map`, what does a `zip` look like?
""",
    timestamp: (22*60 + 04),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The one downside to our current approach is the boilerplate. While `zip2` is the fundamental unit that needs to be defined, and all the other `zip`s come out of it with the same higher-order definitions, for free. Unfortunately, we need to redefine these higher-order `zip`s every time.
""",
    timestamp: (22*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is just a current limitation of Swift, and it very well may be fixed in the future. In the meantime, these `zip`s are a powerful enough addition to your code base that we think it's worth the extra mechanical work, whether you take the time to copy and paste the code or use a source code generation tool.
""",
    timestamp: (22*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The Generics Manifesto even outlines a feature called [variadic generics](https://github.com/apple/swift/blob/b3c9dbeb9f67644027d58cd1fcecb3d8bc760195/docs/GenericsManifesto.md#variadic-generics), which would do away with the need for this boilerplate and we would be able to define `zip`s for any number of arguments. We still don't have the ability to abstract over the shape of this kind of container: we can't, for example, write a generic algorithm against something that is "zippable" or create a `Zippable` protocol. We still need a language-level feature called "higher kinded types", which we also hope to get sometime in the future. The more advanced features Swift gets, the more this boilerplate goes away!
""",
    timestamp: (23*60 + 05),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
In the end, what matters is that "zip" is a universal concept. Boilerplate or not, "zip" is there, waiting for us to take advantage of it, reuse our intuitions on it, and that's the most powerful point of all.
""",
    timestamp: (23*60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This isn't the last of `zip`. This is just our introduction. It's a big enough concept that we still have a ton to cover in future episodes.
""",
    timestamp: (24*60 + 03),
    type: .paragraph
  ),
]
