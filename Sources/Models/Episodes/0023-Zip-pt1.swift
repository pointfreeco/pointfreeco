import Foundation

extension Episode {
  static let ep23_theManyFacesOfZip_pt1 = Episode(
    blurb: """
The `zip` function comes with the Swift standard library, but its utility goes far beyond what we can see there. Turns out, `zip` generalizes a function that we are all familiar with, and it can unify many seemingly disparate concepts. Today we begin a multipart journey into exploring the power behind `zip`.
""",
    codeSampleDirectory: "0023-zip-pt1",
    exercises: _exercises,
    id: 23,
    length: 28*60 + 53,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1531735023 + 604_800),
    sequence: 23,
    title: "The Many Faces of Zip: Part 1",
    trailerVideo: .init(
      bytesLength: 41301707,
      downloadUrls: .s3(
        hd1080: "0023-trailer-1080p-2c27b21428884ddeacdbdbaf76374b9e",
        hd720: "0023-trailer-720p-d2d47a758a3d4784bca18dbf6db1ce24",
        sd540: "0023-trailer-540p-0e9c69799750417ca3b899fb05e935ac"
      ),
      vimeoId: 349879580
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
In this episode we came across closures of the form `{ ($0, $1.0, $1.1) }` a few times in order to unpack a
tuple of the form `(A, (B, C))` to `(A, B, C)`. Create a few overloaded functions named `unpack` to automate
this.
"""),

  .init(problem: """
Define `zip4`, `zip5`, `zip4(with:)` and `zip5(with:)` on arrays and optionals. Bonus:
[learn](https://nshipster.com/swift-gyb/) how to use Apple's `gyb` tool to generate higher-arity overloads.
"""),

  .init(problem: """
Do you think `zip2` can be seen as a kind of associative infix operator? For example, is it true that
`zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)`? If it's not strictly true, can you define an equivalence
between them?
"""),

  .init(problem: """
Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any
applications of this function?
"""),

  .init(problem: """
It turns out, that unlike the `map` function, `zip2` is not uniquely defined. A single type can have multiple,
completely different `zip2` functions. Can you find another `zip2` on arrays that is different from the one
we defined? How does it differ from our `zip2` and how could it be useful?
"""),

  .init(problem: """
Define `zip2` on the result type: `(Result<A, E>, Result<B, E>) -> Result<(A, B), E>`. Is there more than one
possible implementation? Also define `zip3`, `zip2(with:)` and `zip3(with:)`.

Is there anything that seems wrong or “off” about your implementation? If so, it
will be improved in the next episode 😃.
"""),

  .init(problem: """
In [previous](/episodes/ep14-contravariance) episodes we've considered the type that simply wraps a function,
and let's define it as `struct Func<R, A> { let apply: (R) -> A }`. Show that this type supports a `zip2`
function on the `A` type parameter. Also define `zip3`, `zip2(with:)` and `zip3(with:)`.
"""),

  .init(problem: """
The nested type `[A]? = Optional<Array<A>>` is composed of two containers, each of which has their own
`zip2` function. Can you define `zip2` on this nested container that somehow involves each of the `zip2`'s
on the container types?
"""),
]
