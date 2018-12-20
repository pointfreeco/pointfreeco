import Foundation

let ep10 = Episode(
  blurb: """
Swift 4.1 deprecated and renamed a particular overload of `flatMap`. What made this `flatMap` different from \
the others? We'll explore this and how understanding that difference helps us explore generalizations of the \
operation to other structures and derive new, useful code!
""",
  codeSampleDirectory: "0010-a-tale-of-two-flat-maps",
  exercises: exercises,
  fullVideo: .init(
    bytesLength: 537_822_190,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0010-a-tale-of-two-flatmaps/full-720p-8232E8C5-31FB-446E-8C80-0D65377289DC.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0010-a-tale-of-two-flatmaps/full/0010-tale-of-two-flatmaps.m3u8"
  ),
  id: 10,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0010-a-tale-of-two-flatmaps/0010-poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0010-a-tale-of-two-flatmaps/itunes-poster.jpg",
  length: 25*60+4,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_522_144_623),
  references: [.introduceSequenceCompactMap],
  sequence: 10,
  title: "A Tale of Two Flat-Maps",
  trailerVideo: nil,
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  Episode.Exercise(body:
    """
Define `filtered` as a function from `[A?]` to `[A]`.
"""),
  Episode.Exercise(body:
    """
Define `partitioned` as a function from `[Either<A, B>]` to `(left: [A], right: [B])`. What does this function have in common with `filtered`?
"""),
  Episode.Exercise(body:
    """
Define `partitionMap` on `Optional`.
"""),
  Episode.Exercise(body:
    """
Dictionary has `mapValues`, which takes a transform function from `(Value) -> B` to produce a new dictionary of type `[Key: B]`. Define `filterMapValues` on `Dictionary`.
"""),
  Episode.Exercise(body:
    """
Define `partitionMapValues` on `Dictionary`.
"""),
  Episode.Exercise(body:
    """
Rewrite `filterMap` and `filter` in terms of `partitionMap`.
"""),
  Episode.Exercise(body:
    """
Is it possible to define `partitionMap` on `Either`?
"""),
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
A change was proposed for Swift 4.1 that would deprecate an overload of `flatMap` that was a little different from the other `flatMap`s, and provide a new name for this method. The change was met with mixed reception, but ultimately was accepted, although the name was further changed due to community feedback.
""",
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We want to examine why this change was proposed in the first place, and why perhaps the first proposed name might have left us open to further concepts. We hope to show that sometimes naming really matters, and can help us leverage previous intuitions in new, unexpected ways.
""",
    timestamp: 37,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "A tale of two flatMaps",
    timestamp: 1*60+2,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Early on, Swift embraced functional programming patterns by providing functions like `map`, `filter`, `reduce`, and `flatMap` in the standard library.
""",
    timestamp: 1*60+2,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Swift 1.0 shipped with `flatMap` defined on `Array` with the signature that we are all familiar with:
""",
    timestamp: 1*60+2,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// extension Array {
//   func flatMap<B>(_ f: @escaping (Element) -> [B]) -> [B] {
//   }
// }
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is incredibly useful for chaining operations together that return arrays.
""",
    timestamp: 1*60+34,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, given a string holding a comma and newline separated list of values:
""",
    timestamp: 1*60+40,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let csv = \"\"\"
1,2,3,4
3,5,2
8,9,4
\"\"\"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What if we wanted to process this string and extract all values between the commas?
""",
    timestamp: 1*60+49,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can start by splitting on newlines.
""",
    timestamp: 1*60+54,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
csv
  .split(separator: "\\n")
// ["1,2,3,4", "3,5,2", "8,9,4"]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we want to dive into this array to further split each string on commas.
""",
    timestamp: 2*60+3,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We're familiar with using `map` to modify arrays.
""",
    timestamp: 2*60+10,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
csv
  .split(separator: "\\n")
  .map { $0.split(separator: ",") }
// [["1", "2", "3", "4"], ["3", "5", "2"], ["8", "9", "4"]]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This returns nested arrays of values, but we want a flat array of values.
""",
    timestamp: 2*60+19,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
This is exactly what `flatMap` lets us do. It applies a function to each element of the array and then flattens it.
""",
    timestamp: 2*60+33,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
csv
  .split(separator: "\\n")
  .flatMap { $0.split(separator: ",") }
// ["1", "2", "3", "4", "3", "5", "2", "8", "9", "4"]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Shortly thereafter, Swift introduced `flatMap` on `Optional` with the following signature:
""",
    timestamp: 2*60+41,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// extension Optional {
//   func flatMap<B>(_ f: @escaping (Element) -> B?) -> B? {
//   }
// }
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is useful for chaining operations together than return optionals.
""",
    timestamp: 3*60,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
For example, `String` has a failable initializer that takes data and returns an optional string:
""",
    timestamp: 3*60+4,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
String(data: Data(), encoding: .utf8)
// Optional("")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
As with arrays, we can `map` on optionals to transform the wrapped value. Say we want to transform our optional string into an integer.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
String(data: Data(), encoding: .utf8)
  .map(Int.init)
// Optional(nil)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We got `nil` back because we were calling the `Int` initializer with an empty string, but something else is a little strange here. Is the type `Optional<Int>`?
""",
    timestamp: 3*60+24,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
_: Int? =  String(data: Data(), encoding: .utf8)
  .map(Int.init)
// Value of optional type 'Int??' not unwrapped
""",
    timestamp: 3*60+32,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's not! Using `map` results in a double-optional `Int??`. We use `map` on an optional with an initializer that returned an optional, resulting in a nest of optionals! What we really wanted to use is `flatMap`.
""",
    timestamp: 3*60+37,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
_: Int? =  String(data: Data(), encoding: .utf8)
  .flatMap(Int.init)
// nil
""",
    timestamp: 3*60+49,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This now compiles, which means our value is being flattened. It's still returning `nil`, so let's provide some data.
""",
    timestamp: 3*60+53,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
String(data: Data([55]), encoding: .utf8)
  .flatMap(Int.init)
// Optional(7)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
With `flatMap` we were able to take our optional string, apply a function to its unwrapped value, and then take that optional result and flatten it back into a single optional integer.
""",
    timestamp: 4*60,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There was a third `flatMap` on `Array` that blurred these worlds together: it took array elements and sent them through transformations that return optionals. Let's look at an array of strings.
""",
    timestamp: 4*60+10,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
["1", "2", "buckle", "my", "shoe"]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What if we wanted to transform each string into an integer? Using `map`, we get back the following:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
["1", "2", "buckle", "my", "shoe"]
  .map(Int.init)
// [{some 1}, {some 2}, nil, nil, nil]
""",
    timestamp: 4*60+25,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We're given back an array where successful transformations are wrapped in an optional, while transformations that failed are `nil`.
""",
    timestamp: 4*60+30,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
If we used `flatMap` instead, we could discard those `nil`s and safely unwrap the integers.
""",
    timestamp: 4*60+40,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
["1", "2", "buckle", "my", "shoe"]
  .flatMap(Int.init)
// [1, 2]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is incredibly useful! We do this kind of thing all the time. But this version of `flatMap` feels a bit different than the others since it's mixing together some qualities of arrays with qualities of optionals.
""",
    timestamp: 4*60+47,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Things become even more confusing when using both methods together. Let's take our CSV example from earlier and further convert each value to an integer before adding them up.
""",
    timestamp: 5*60+1,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
csv.split(separator: "\\n")
  .flatMap { $0.split(separator: ",") }
  .flatMap { Int($0) }
  .reduce(0, +)
// 41
""",
    timestamp: 5*60+18,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here the first `flatMap` is in charge of getting all the values separated by commas and flattening them into a single array, and then the next `flatMap` tries to create an `Int` from the string, and discards any that fail to do so. These are two very different operations but we're using the same name for them, making it difficult to tell them apart at a glance here.
""",
    timestamp: 5*60+51,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We spend a lot of time thinking about types, particularly the shape of functions. Sometimes this can get lost in the definition of a method: the container type fades away from the declaration, and the function and argument names can make things a bit hazier. Let’s isolate these function signatures to the types themselves. We’ll use our free function syntax of `(Configuration) -> (Data) -> ReturnValue`:
""",
    timestamp: 6*60+12,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// flatMap : ((A) -> [B]) -> ([A]) -> [B]
// flatMap : ((A) ->  B?) -> ( A?) ->  B?

// flatMap : ((A) ->  B?) -> ([A]) -> [B]
""",
    timestamp: 6*60+35,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
One of these shapes is not like the others. The top two `flatMap`s operate with a single container type: `Array` and `Optional`, but the third `flatMap` operates on both containers at once.
""",
    timestamp: 7*60+24,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
If we desugar things, the generics look like this:
""",
    timestamp: 7*60+43,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// flatMap : ((A) ->    Array<B>) -> (   Array<A>) ->    Array<B>
// flatMap : ((A) -> Optional<B>) -> (Optional<A>) -> Optional<B>

// flatMap : ((A) -> Optional<B>) -> (   Array<A>) ->    Array<B>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What if we could think of the container `Array` and `Optional` types as generic types of their own? We can write things in such a way where we throw away their names to come up with something like this:
""",
    timestamp: 8*60,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// flatMap : ((A) -> M<B>) -> (M<A>) -> M<B>
// flatMap : ((A) -> M<B>) -> (M<A>) -> M<B>

// flatMap : ((A) -> N<B>) -> (M<A>) -> M<B>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Whoa, the first two signatures end up turning into the exact same thing! But with the third signature, we’re dealing with two different generic container types and the semantics become a lot more confusing. What exactly is `N` doing to produce an `M`? In the other versions, one can kind of make sense of the transform function having something to do with composing into the container type all over again. In this version, the `N` doesn’t really give us much to go on.
""",
    timestamp: 8*60+36,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
To make sense of it, we have to go back to concrete types.
""",
    timestamp: 9*60+27,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// flatMap : ((A) -> B?) -> (M<A>) -> M<B>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is still a bit confusing. Can any `M` work with `Optional` in this way? Maybe this third `flatMap` isn't as generic as the others.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Optional promotion",
    timestamp: 10*60+13,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
There was another issue with overloading `flatMap` on `Array` for operations that return `Optional`s: optional promotion. For the sake of ergonomics, Swift automatically wraps values in the `Optional` type wherever an optional parameter requires. This can lead to code that’s much more succinct, and it can reduce some of the boilerplate burden on the engineer that would have otherwise needed to explicitly wrap values with `.some`, but type inference is a double-edged blade, and in the case of a closure that returns an optional result, anything is fair game.

""",
    timestamp: 10*60+13,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Consider the following snippet:
""",
    timestamp: 10*60+54,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3]
  .flatMap { $0 + 1 }
// [2, 3, 4]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This compiles, runs, and produces a result, but the semantics are strange: we're not returning an optional from the provided closure. The compiler is automatically wrapping the value for us, like this:

""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3]
  .flatMap { .some($0 + 1) }
// [2, 3, 4]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Wrapping our value manually shows that our logic here is a bit strange. We always return `.some` and never fail over to `nil`. Because this operation can never fail, we could have just used `map`.
""",
    timestamp: 11*60+22,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3]
  .map { $0 + 1 }
// [2, 3, 4]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Because of optional promotion, any operation that works with `map` will also work with `flatMap`. It might even be tempting to avoid `map` in general because `flatMap` always seems to work, but `map` sometimes doesn't. This is a bit unfortunate because we lose a bit of semantic meaning if we use `flatMap` everywhere. If we use both `flatMap` and `map`, we document operations that can and cannot fail explicitly.
""",
    timestamp: 11*60+36,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Even worse, we can make changes to our types that we would expect to be compile time errors, but because of the overloaded `flatMap` and optional promotion it compiles fine but it has unexpected runtime behavior. For example, given a `User` struct with an optional name, and an array of users:
""",
    timestamp: 12*60+8,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct User {
  let name: String?
}

let users = [User(name: "Blob"), User(name: "Math")]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Given an array of users, we may be tempted to `map` over them and pluck out their names.
""",
    timestamp: 12*60+15,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
users
  .map { $0.name }
// [{some "Blob"}, {some "Math"}]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But now we have this array of optional values. What we really wanted to use is `flatMap`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
users
  .flatMap { $0.name }
// ["Blob", "Math"]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We might build a lot of code around a type like this, and one day we may change our `User` type to require a name. We've grown to appreciate that a powerful type system can help guide us through refactoring code whenever we change the way our type looks.
""",
    timestamp: 12*60+32,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct User {
  let name: String
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
When our code recompiles, what happens to our runtime behavior?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
users
  .flatMap { $0.name }
// ["B", "l", "o", "b", "M", "a", "t", "h"]
""",
    timestamp: 13*60,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
That's unexpected! Maybe it's a good thing that this outlier was renamed.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "compactMap and filterMap",
    timestamp: 13*60+18,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
So, given the complications that came up with the overloaded `flatMap` that was not quite like the other `flatMap`s, it was decided to deprecate it and introduce a new name. It is very important to remember that `flatMap` on arrays with transforms that return arrays, and `flatMap` on optionals that return optionals is not deprecated. It is only the one outlier method.
""",
    timestamp: 13*60+18,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The name originally proposed was `filterMap`, in that you are mapping over the array and then discarding the `nil` values. It could be defined like so:
""",
    timestamp: 13*60+48,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Array {
  func filterMap<B>(_ transform: (Element) -> B?) -> [B] {
    var result = [B]()
    for x in self {
      switch transform(x) {
      case let .some(x):
        result.append(x)
      case let .none:
        continue
      }
    }
    return result
  }
}
""",
    timestamp: 14*60+3,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
After a bit of bike shedding on the evolution mailing list it was ultimately changed to `compactMap`, which is nice because it shares some prior art in Ruby, where `compact` is a method on arrays that discards `nil` values. Let's go ahead and define `compactMap`:
""",
    timestamp: 14*60+29,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Array {
  func compactMap<B>(_ transform: (Element) -> B?) -> [B] {
    var result = [B]()
    for x in self {
      switch transform(x) {
      case let .some(x):
        result.append(x)
      case let .none:
        continue
      }
    }
    return result
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's just a rename, so we don't have to change the body of the function.
""",
    timestamp: 14*60+53,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Generalizations of filterMap",
    timestamp: 15*60+6,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
One of the downsides of the `compactMap` name is that is has a strong ties to what we are doing with an array: we are "compacting" it to make it smaller by removing the `nil`s. This prevents us from seeing where `compactMap` might have broader applications.
""",
    timestamp: 15*60+6,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
But, one of the wonderful things about the `filterMap` name was that it could lead to some nice generalizations.
""",
    timestamp: 15*60+30,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's start by observing that a predicate `(A) -> Bool` on `A` naturally induces a function `(A) -> A?`:
""",
    timestamp: 15*60+41,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func filterSome<A>(_ p: @escaping (A) -> Bool) -> (A) -> A? {
  return { p($0) ? .some($0) : .none }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It simply returns `.some` of the value when the predicate evaluates to `true`, and `.none` otherwise.

""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With this function we can now re-implement regularly ole `filter` on arrays:
""",
    timestamp: 16*60+33,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.filterMap(filterSome(p)) }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's try it out. We can create a filter for even integers.
""",
    timestamp: 16*60+41,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
filter { $0 % 2 == 0 }
// ([Int]) -> [Int]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And pipe an array through.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Array(0..<10)
  |> filter { $0 % 2 == 0 }
// [2, 4, 6, 8, 10]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
That's pretty neat, but not immediately useful. We could already define `filter` ourselves or just use the one from the standard library. But, the reason we'd want to look at `filter` this way is that perhaps it will lead us to further generalizations.
""",
    timestamp: 16*60+51,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
One way to do this is to [remember](/episodes/ep4-algebraic-data-types) that `Either<A, B>` is a generalization of `Optional<A>`.
""",
    timestamp: 17*60+8,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Either<A, B> {
  case left(A)
  case right(B)
}
""",
    timestamp: 17*60+13,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Instead of modeling the absence of an `A` with `nil`, we can supply a different value of type `B` in its place.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
The function analogous to `filterSome` for `Either` would look something like this:
""",
    timestamp: 17*60+31,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func partitionEither<A>(_ p: @escaping (A) -> Bool) -> (A) -> Either<A, A> {
  return { p($0) ? .right($0) : .left($0) }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Give a predicate `(A) -> Bool`, it returns a function that can partition values of type `(A)` into one of two cases in `Either<A, A>`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now let's generalize `filterMap` using this connection with partition and `Either`:
""",
    timestamp: 18*60+8,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Array {
  func partitionMap<A, B>(_ transform: (Element) -> Either<A, B>) -> (lefts: [A], rights: [B]) {
    var result = (lefts: [A](), rights: [B]())
    for x in self {
      switch transform(x) {
      case let .left(a):
        result.lefts.append(a)
      case let .right(b):
        result.rights.append(b)
      }
    }
    return result
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We saw that we could derive `filter` from `filterMap`. Can we derive `partition` from `partitionMap`?
""",
    timestamp: 19*60+17,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func partition<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> (`false`: [A], `true`: [A]) {
  return { $0.partitionMap(partitionEither(p)) } // error
}
""",
    timestamp: 19*60+28,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The type system has a little bit of trouble with the tuple names here, but we can get things to compile by destructuring and restructuring:
""",
    timestamp: 20*60+9,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func partition<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> (`false`: [A], `true`: [A]) {
  return {
    let (lefts, rights) = $0.partitionMap(partitionEither(p))
    return (lefts, rights)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is nice because `partition` isn't even in the standard library, but we were led there automatically by exploring the link between `filter` and `filterMap`, and a generalization from `Optional` to `Either`.
""",
    timestamp: 20*60+28,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We now see two parallel stories forming here:

- Lifting a predicate `(A) -> Bool` to a function into optionals `(A) -> A?` led us naturally to the `filterMap` function, which in turn induced the `filter` function that we were already familiar with.

- Lifting a predicate `(A) -> Bool` to a function into either `(A) -> Either<A, A>` led us naturally to the `partitionMap` function, which in turn induced the `partition` function.
""",
    timestamp: 20*60+51,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We can also combine this with other machinery that we have built from previous episodes, like our [functional setters](/episodes/ep6-functional-setters). We saw that we could define very small, generic setters that are pieced together in very complex ways. We saw this best worked with free functions so let’s define a free version of `partitionMap` :
""",
    timestamp: 21*60+17,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func partitionMap<A, B, C>(_ p: @escaping (A) -> Either<B, C>) -> ([A]) -> (lefts: [B], rights: [C]) {
  return { $0.partitionMap(p) }
}
""",
    timestamp: 21*60+34,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's define a function that can be used with it.
""",
    timestamp: 21*60+36,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let evenOdds = { $0 % 2 == 0 ? Either.left($0) : .right($0) }
// (Int) -> Either<Int, Int>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can hand this function off to `partitionMap`.
""",
    timestamp: 21*60+48,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
partitionMap(evenOdds)
// ([Int]) -> (lefts: [Int], rights: [Int])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now we have a brand new function that, given an array of integers, returns a tuple partitioning even values on the left, and odd values on the right.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's try it out.
""",
    timestamp: 21*60+57,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Array(1...10)
  |> partitionMap(evenOdds)
// ([2, 4, 6, 8, 10], [1, 3, 5, 7, 9])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Working as expected. We can even compose this using our [tuple composable setters](/episodes/ep6-functional-setters). Let's dive into the even numbers and square them all.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Array(1...10)
  |> partitionMap(evenOdds)
  |> (first <<< map)(square)
// ([4, 16, 36, 64, 100], [1, 3, 5, 7, 9])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In just a few lines and in a single expression, we were able to apply a complex predicate to split an array into two before modifying one of those sets, all while keeping the partitions intact.
""",
    timestamp: 22*60+21,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: 22*60+45,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've spent the entire episode talking about naming things, and naming is a topic that can quickly go the way of the bikeshed, as it did with the renaming of `flatMap`. To top it off, was the rename worth it in the first place? Deprecating it causes a lot of code base churn. People were mostly going about their daily code just fine with the existing `flatMap`, so they may be loading their projects up in Swift 4.1 and asking: "What's the point?" Was it worth going through these exercises in renaming?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It was interesting that we could step back and look at things a bit more abstractly and tie things together in interesting ways. By looking at just the shapes of `flatMap`, we were able to figure out why one was an outlier and how the other two may provide a shared intuition for more `flatMap`s in the future.
""",
    timestamp: 23*60+24,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, in renaming the outlier to `filterMap`, we were given the opportunity to generalize it in ways we may not have otherwise seen.
""",
    timestamp: 23*60+53,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Naming can be controversial! Depending on the name, though, we can create strong bonds between related concepts, which can lead us to discover interesting things, as we saw `filter` and `filterMap` lead us to `partition` and `partitionMap`!
""",
    timestamp: 24*60+9,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now that the outlier of `flatMap` has been renamed to `compactMap`, we'll be free to explore it on more and more types in the future.
""",
    timestamp: 24*60+28,
    type: .paragraph
  ),
]
