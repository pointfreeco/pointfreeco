import Foundation

let ep4 = Episode(
  blurb: """
What does the Swift type system have to do with algebra? A lot! We’ll begin to explore this correspondence 
and see how it can help us create type-safe data structures that can catch runtime errors at compile time.
""",
  codeSampleDirectory: "0004-algebraic-data-types",
  id: 4,
  exercises: exercises,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0004-adt/0004-poster.jpg",
  length: 2_172,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_519_045_951),
  sequence: 4,
  sourcesFull: [
    "https://d1hf1soyumxcgv.cloudfront.net/0004-adt/hls-math-is-useful.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0004-adt/webm-math-is-useful.webm",
    ],
  sourcesTrailer: [
    "https://d1hf1soyumxcgv.cloudfront.net/0004-adt/trailer/hls-trailer.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0004-adt/trailer/webm-trailer.webm",
    ],
  title: "Algebraic Data Types",
  transcriptBlocks: transcriptBlocks
)

private let exercises: [Episode.Exercise] = [
  Episode.Exercise(body: """
What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating
all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and
`(Three) -> Bool` to get some intuition.
"""),

  Episode.Exercise(body: """
Consider the following recursively defined data structure:

```
indirect enum List<A> {
  case empty
  case cons(A, List<A>)
}
```

Translate this type into an algebraic equation relating `List<A>` to `A`.
"""),

  Episode.Exercise(body: """
Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional
values does one type have that the other doesn't?
"""),

  Episode.Exercise(body: """
Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
"""),

  Episode.Exercise(body: """
Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload
the `*` and `+` infix operators with functions that take any type and build up an algebraic
representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest
themselves in the resulting types.
"""),
]

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 18,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Today we wanna talk about a link between two worlds: Swift types and algebra. We all have familiarity with both of these worlds, but it turns out they are related in a very deep, beautiful way. Using this correspondence we can better understand what adds complexity to our data structures, and even use intuition we have from algebra to better sculpt our data so that impossible states are not representable, and hence do not compile!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The algebra of structs",
    timestamp: 60,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
First, let's look at something simple enough: structs. In fact, this particular struct:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct Pair<A, B> {
  let first: A
  let second: B
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is kinda the most generic, non-trivial struct one could make. It has two fields, and each just holds a piece of generic data. Let's do something a little strange, and for particular values of `A` and `B`, let's count how many values `Pair<A, B>` holds:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Bool, Bool>(first: true, second: true)
Pair<Bool, Bool>(first: true, second: false)
Pair<Bool, Bool>(first: false, second: true)
Pair<Bool, Bool>(first: false, second: false)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
`Pair<Bool, Bool>` holds exactly four values. It is impossible to construct any other value that would be a valid, compiling Swift program. Let's try another. I'm gonna cook up a lil type that has exactly three values and count its pairs with `Bool`:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Three {
  case one
  case two
  case three
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
How many pairs can we build with `Bool` and `Three`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Bool, Three>(first: true, second: .one)
Pair<Bool, Three>(first: true, second: .two)
Pair<Bool, Three>(first: true, second: .three)
Pair<Bool, Three>(first: false, second: .one)
Pair<Bool, Three>(first: false, second: .two)
Pair<Bool, Three>(first: false, second: .three)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Ok this has six values! Interesting!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There's a strange type in Swift called `Void`. In fact it's strange for at least two reasons. For one, you can refer to the type and the value in the same way:
""",
    timestamp: 163,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
_: Void = Void()
_: Void = ()
_: () = ()
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Well, that leads us to the other strange thing. `Void` only has one value! Because of that, the material substance of `()` doesn't matter at all. It's just a value that represents we have the thing in `Void`, but you can't actually do anything with `()`. This is also why functions that have no return value secretly return `Void` even if not explicitly specified:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func foo(_ x: Int) /* -> Void */ {
  // return ()
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The Swift compiler will just go in after you and `return ()`.

Let's try plugging `Void` into our pair and see what happens:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Bool, Void>(first: true, second: ())
Pair<Bool, Void>(first: false, second: ())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It only holds two values.

What about a pair of `Void` and `Void`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Void, Void>(first: (), second: ())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Only 1 value!

Interesting! We had no choice but to plug in `()` for the second field, and so it didn't really change the type much.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
There is yet another strange type in Swift: `Never`. Its definition is simple enough:
""",
    timestamp: 288,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Never {}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What does this mean? It's an enum with no cases. This is the so-called "uninhabited type": a type that contains no values. There is no way to do something like:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
_: Never = ???
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
There's nothing we can put here and have Swift compile this program.

So what happens when we plug `Never` into `Pair`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Bool, Never>(first: true, second: ???)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
There's nothing we can put into `???`!

The `Never` type also gets special treatment by the compiler, in which a function that returns `Never` is known to be a non-returning function. For example, the `fatalError` function returns `Never`. The compiler knows that all lines and branches of code after the execution of this statement will never happen, and can use that to prove exhaustiveness.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With all of these examples in mind, what is the relationship between the number of values in `A` and `B` and the number of values in `Pair<A, B>`?
""",
    timestamp: 366,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Pair<Bool, Bool>  = 4
// Pair<Bool, Three> = 6
// Pair<Bool, Void>  = 2
// Pair<Void, Void>  = 1
// Pair<Bool, Never> = 0
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
A pattern's beginning to emerge: multiplication!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Pair<Bool, Bool>  = 4 = 2 * 2
// Pair<Bool, Three> = 6 = 2 * 3
// Pair<Bool, Void>  = 2 = 2 * 1
// Pair<Void, Void>  = 1 = 1 * 1
// Pair<Bool, Never> = 0 = 2 * 0
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
`Pair` causes the number of values to multiply, _i.e._ the number of values in `Pair<A, B>` is the number of values in `A` times the number of values in `B`.

There's another algebraic interpretation of this phenomenon: logical conjunction, a.k.a. _and_. The `Pair` type is encapsulating what it means to take the "and" of two types, i.e. a value of `Pair<A, B>` is precisely a value of type `A` and a another value of type `B`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
And this is true of any struct and tuple, not just `Pair`. Let's look at an example:
""",
    timestamp: 488,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Theme {
  case light
  case dark
}

enum State {
  case highlighted
  case normal
  case selected
}

struct Component {
  let enabled: Bool
  let state: State
  let theme: Theme
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's the algebra of `Component`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Bool * Theme * State = 2 * 3 * 2 = 12
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
`Component` has twelve values!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
With this intuition, let's wipe away all of the names of the types, and just focus on what data is stored in the fields. To do that, we are going to create a notation that is not valid Swift code, but will allow us to more compactly see the algebra we are uncovering here. So where we used to write `Pair<A, B>` we are now simply going to write `A * B`. Indeed this looks strange, but it is only to help guide our intuition:
""",
    timestamp: 538,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Pair<A, B>        = A * B
// Pair<Bool, Bool>  = Bool * Bool
// Pair<Bool, Three> = Bool * Three
// Pair<Bool, Void>  = Bool * Void
// Pair<Bool, Never> = Bool * Never
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We call `A * B` the product of the types `A` and `B`. And now that we are thinking a little bit more abstractly, we don't can even loosen our intuition around `Pair<A, B>` being the literal multiplication of the number of elements in `A` and `B`. While that is indeed true for types with finitely many values, that doesn't really help us with things like:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Pair<Bool, String> = Bool * String
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We no longer get to talk about the number of values, because `String` has an infinite number, but we're still allowed to think of this as multiplication.

We could even consider the following:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// String * [Int]
// [String] * [[Int]]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We're multiplying infinite types together!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's take things a step further and wipe away the names from `Void`, `Never` and `Bool` and only represent those types by the number of values that are contained within.
""",
    timestamp: 672,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Never = 0
// Void = 1
// Bool = 2
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So now we aren't even thinking about specific types, just abstract algebraic entities.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "The algebra of enums",
    timestamp: 706,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Ok, now we've seen that structs in Swift correspond to multiplication of types. But there's a corresponding "dual": addition! How's this look like in Swift's type system?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Well, turns out Swift has support for such a construction, and that's precisely an `enum`! Let's consider the most generic, non-trivial enum one could make:
""",
    timestamp: 730,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Either<A, B> {
  case left(A)
  case right(B)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's take some of our earlier values and see how to construct some simple values from this type:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Bool>.left(true)
Either<Bool, Bool>.left(false)
Either<Bool, Bool>.right(true)
Either<Bool, Bool>.right(false)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We get four values again. What about `Three`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Three>.left(true)
Either<Bool, Three>.left(false)
Either<Bool, Three>.right(.one)
Either<Bool, Three>.right(.two)
Either<Bool, Three>.right(.three)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This time we get five values. Hm! How about `Void`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Void>.left(true)
Either<Bool, Void>.left(false)
Either<Bool, Void>.right(Void())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Three values!

And `Never`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Never>.left(true)
Either<Bool, Never>.left(false)
Either<Bool, Never>.right(???)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This last example is particularly interesting. We saw that by taking a pair with `Never`, _i.e._ `Pair<A, Never>`, we made the pair uninhabited. However, with `Either` it just means that one case is uninhabited, but the other is free to take values in `Bool`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Now we can see some algebra peeking through. So what's the relationship between the number of values in `A` and `B` and the number of values in `Either<A, B>`?
""",
    timestamp: 886,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Bool>  = 4 = 2 + 2
Either<Bool, Three> = 5 = 2 + 3
Either<Bool, Void>  = 3 = 2 + 1
Either<Bool, Never> = 2 = 2 + 0
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
From these examples we can see that the number of values in `Either<A, B>` is precisely the number of values in `A` plus the number of values of `B`. So `Either` directly corresponds to taking the sum of types. This is why enums are called "sum types." We can also interpret `Either` from the perspective of logic like we did for `Pair`: the `Either` type encapsulates what it means to take the "or" of two types, i.e. a value of `Either<A, B>` is precisely a value of type `A` or a value of type `B`.

So, like before let us abstract away the idea of taking the sum of types by using a new notation that isn't valid Swift but nonetheless will be helpful for developing our intuition.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Bool, Bool>  = Bool + Bool  = 2 + 2 = 4
Either<Bool, Three> = Bool + Three = 2 + 3 = 5
Either<Bool, Void>  = Bool + Void  = 2 + 1 = 3
Either<Bool, Never> = Bool + Never = 2 + 0 = 2
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: "Word of warning: Void",
    timestamp: 1057,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
It's worth noting that some languages (such as Haskell, PureScript, Idris) use `Void` to denote the uninhabited type (_i.e._, what Swift calls `Never`), and so could lead to some confusion if you look into those languages. And in fact, in some sense that's a great name since "void" kinda seems like a space that has nothing in it!

Perhaps a better name for the type with one unique value would be something like `Unit`. We would define it as such:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct Unit {}
let unit = Unit()
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is nice because we now have a distinct name for the type `Unit` and the unique value `unit`. Another nice thing about having an actual struct type for `Unit` is that we get to extend it:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Unit: Equatable {
  static func == (lhs: Unit, rhs: Unit) -> Bool {
    return true
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now we are allowed to pass `unit` into functions that only want equatable value, which is cool. But that isn't possible with `Void` in Swift. If you try to extend it you get this error:

```
Non-nominal type 'Void' cannot be extended
```

The reason is that `Void` is defined as an empty tuple:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
typealias Void = ()
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Tuples in Swift are non-nominal types, _i.e._ you don't get to refer to them by name, only by structure. This is a very unfortunate thing in Swift that can hopefully some day be remedied.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Empty structs vs. empty enums",
    timestamp: 1168,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
But now we want to call out something very strange. Let's look at the definitions of `Unit` and `Never` side-by-side:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct Unit {}
enum Never {}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Clearly there's some symmetry here: an enum with no cases and a struct with no fields. By why does the enum with no cases have no values in it, yet the struct with no fields does have a value? It's perfectly reasonable to maybe expect that `Unit` also has no values.

However can we get intuition to understand why this is the case?

Using our correspondence between Swift types and algebra, we can ask a related question that is perhaps easier to answer. We can ask ourselves, "What values are in the empty enum and empty struct?" and it's equivalent to asking, "What is the sum and product of integers in the empty array?"

So, say we had an array of integers. How can we define the following functions:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func sum(_ xs: [Int]) -> Int {
  fatalError()
}

func product(_ xs: [Int]) -> Int {
  fatalError()
}

let xs = [1, 2, 3]
sum(xs)
product(xs)
""",
    timestamp: 1235,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Well we definitely want to loop over the arrays and sum and multiply all the values together:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func sum(_ xs: [Int]) -> Int {
  var result: Int
  for x in xs {
    result += x
  }
  return result
}

func product(_ xs: [Int]) -> Int {
  var result: Int
  for x in xs {
    result *= x
  }
  return result
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This doesn't currently compile because we haven't given an initial value to `result`. But what should we choose? Well, to answer that question we need to understand what properties `sum` and `product` should satisfy, and that will force our hand as to what `result` needs to start at. The simplest property we would want to satisfy has to do with how `sum` and `product` behave with respect to concatenation of arrays:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
sum([1, 2]) + sum([3]) == sum([1, 2] + [3])
product([1, 2]) * product([3]) == product([1, 2] + [3])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now, what if we used empty arrays?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
sum([1, 2]) + sum([]) == sum([1, 2] + [])
product([1, 2]) * product([]) == product([1, 2] + [])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This forces `sum([])` to be `0` and `product([])` to be `1`. There are no other choices. Therefore the empty sum is `0` and the empty product is `1`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
sum([1, 2]) + 0 == sum([1, 2] + [])
product([1, 2]) * 1 == product([1, 2] + [])

sum([]) == 0
product([]) == 1
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now, transporting this concept back to the type world, we are naturally led to the statement that the "empty sum type" has no values (i.e. uninhabited) and that the "empty product type" has exactly one value! So we've used algebra to disentangle a really gnarly existential quandary!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "Algebraic properties",
    timestamp: 1406,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Now that we've built up some of the concepts to understand the correspondence between Swift types and algebra, let's try to flex these muscles and see if we can get intuition on some type constructions at this higher level.

Let's start easy. Recall that `Void` corresponds to `1`, and in the algebra world we know that multiplying by `1` doesn't do anything. What does this look like in types?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Void = 1
// A * Void = A = Void * A
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This means that using a `Void` value in the field of a struct has the net effect of essentially leaving the type unchanged.

On the other hand, `Never` corresponds to `0`, and we know that multiplying with it results in `0`. In the type world this look like:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Never = 0
// A * Never = Never = Never * A
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So putting `Never` in a field of the struct has the net result of turning that struct into a `Never` type itself. It completely annihilates it.

But, adding `0` has a net result of leaving the value unchanged, and in types this corresponds to:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// A + Never = A = Never + A
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's go the other way. Consider this type expression:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// 1 + A = Void + A
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In terms of `Either` this is:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Either<Void, A> {
//   case left(())
//   case right(A)
// }
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So this is the type that has all of the values of `A` on the right side, and then this one special value `left(Void())` is adjoined. What native Swift type has this same shape? Optionals!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
enum Optional<A> {
  case none
  case some(A)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The `none` case corresponds to `left` (a case with no associated value is essentially the same as a case with a `Void` value), and the `some` case corresponds to `right`. So now we have seen:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// 1 + A = Void + A = A?
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now, say you came across this expression:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Either<Pair<A, B>, Pair<A, C>>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's see what it looks like in our notation:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// A * B + A * C
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Using basic algebra we understand how to factorize this into a simpler expression:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
A * (B + C)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now this corresponds to a pair with an enum:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<A, Either<B, C>>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So here we see that algebraic intuition has led us to a simpler data structure.

On the other hand, if we simply flip the roles of `Pair` and `Either`, we have:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Pair<Either<A, B>, Either<A, C>>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And in the math world:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// (A + B) * (A + C)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This equation does not factorize anymore and so we cannot make it any simpler.

We could, of course, expand it out so that it equals:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// A * A + A * C + B * A + B * C
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And this is kind of like an enum with four cases, each case being a pair. That may not be what you want, but maybe you do, and you have the algebra to show you how to do it!

Every data structure that we talk about, if we just think of the data and none of the behavior we associate with the data, it's all just sums of products: you start with a base enum of cases, and each case you have a bunch of products, which may in turn contain more sums and products.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: 1765,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've written a bunch of pseudocode that isn't even valid Swift, all it can do is guide our intuition. Have we gotten any benefit out of this?

Let's look at a method on `URLSession`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// URLSession.shared
//   .dataTask(with: url, completionHandler: (data: Data?, response: URLResponse?, error: Error?) -> Void)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The completion handler gives us back three values that are all optional. This is a product type with 3 fields. Swift Tuples are just products. Let's express it algebraically:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// (Data + 1) * (URLResponse + 1) * (Error + 1)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This looks a little strange. What happens if we fully expand it?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// (Data + 1) * (URLResponse + 1) * (Error + 1)
//   = Data * URLResponse * Error
//     + Data * URLResponse
//     + URLResponse * Error
//     + Data * Error
//     + Data
//     + URLResponse
//     + Error
//     + 1
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
There are a lot of representable states here that don't make sense. They even jump out on each line. We can get `URLResponse * Error`, while `URLResponse` should never be inhabited at the same time as `Error`. We can also get `Data * Error`, which also makes no sense. We can also get `1`, which is just `Void`, or in this case where everything value is `nil`. And we can also get everything: `Data * URLResponse * Error`, which should never happen.
""",
    timestamp: nil,
    type: .paragraph
    ),

  Episode.TranscriptBlock(
    content: """
It was brought to our attention by one of our viewers, [Ole Begemann](http://twitter.com/olebegemann), that
it is in fact possible for `URLResponse` and `Error` to be non-`nil` at the same time. He wrote a great
[blog post](https://oleb.net/blog/2018/03/making-illegal-states-unrepresentable/) about this, and we
discuss this correct at the beginning of our follow up episode,
[Algebraic Data Types: Exponents](/episodes/ep9-algebraic-data-types-exponents).
""",
    timestamp: nil,
    type: .correction
  ),
  
  .init(
    content: """
When you work with this interface, you may notice that when you `if let` over the cases you expect, you inevitably end up with a branch that you need to `fatalError`, and just hope it never gets called.

Let's use our new intuitions to represent just what we want:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Data * URLResponse + Error
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's this look like with our types?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Either<Pair<Data, URLResponse>, Error>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In fact, the Swift community has embraced a type that allows us to handle these kinds of states, the `Result` type.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Result<(Data, URLResponse), Error>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And in this case, rather than use our `Pair`, we can use a simple tuple to represent the product of `Data` and `URLResponse`.

By using the proper type in the completion callback, we have greatly reduced the number of invalid states that are allowed at compile time, thus simplifying the logic needed in the callback.

Let's consider the `Result` type further. What if we're using an API that returns `Result` but with a particular operation that can never fail? We can specify that our error type is `Never`!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Result<A, Never>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we can be sure that the error case is uninhabitable.

And what if we're dealing with an asynchronous API that supported cancellation? How could we add that cancellation case to our `Result`?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// Result<A, Error>?
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We just make it optional!

Seeing how we can both wrangle complexity and lead ourselves naturally to types that better fit our needs makes it clearer how algebraic intuitions can improve our everyday code. We also see that while structs have lightweight versions in tuples, maybe `Either` is a lightweight enum that belongs in our daily arsenal. Let's not be afraid of `Either`! To be afraid of `Either` but not be afraid of tuples, it's like saying that you're afraid of addition, but not multiplication. Or it's like saying you're afraid of "or", but not "and." We don't program in a way in which we only use multiplication (`*`) and "and" (`&&`). We allow ourselves to use addition (`+`) and "or" (`||`). So let's get comfortable with sum types and `Either`!

We've only just begun on this algebraic journey. We still haven't seen how the type system can represent other concepts, like exponentiation! What does one type to the power of another look like? But that'll have to wait till next time. Stay tuned!
""",
    timestamp: nil,
    type: .paragraph
  ),
]
