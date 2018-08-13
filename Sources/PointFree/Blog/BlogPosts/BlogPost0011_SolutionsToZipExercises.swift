import Foundation

// todo: renumber
let post0011_solutionsToZipExercises = BlogPost(
  author: .brandon,
  blurb: """
This week we solve the exercises from our introductory series of episode on zip, because there were _a lot_ of
them!
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      //todo
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0003-solutions-to-exercises-contravariance/poster.jpg")
    ),

    .init(
      content: """
---

> This week we solve the exercises from our introductory series of episode on zip, because there were _a lot_
of them!

Last week we concluded our 3-part introductory series to the `zip` function. We saw that the Swift standard
library

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
  return (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1.0 tuple.1.1.1.0)
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

## Exercise 3

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

## Exercise 4

> Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any
applications of this function?

TODO
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
---

## Exercise 5

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

## Exercise 6

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

## Exercise 7

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
[epsiode](/episodes/ep24-the-many-faces-of-zip-part-2) we explored this idea a bit more and showed how it
unlocks some interesting expressivity when dealing with lazy values.

---

## Exercise 8

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
  return zip2(a, b)
    .map(zip2)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Short and sweet! To `zip` a nested optional array you simply `map` on the `zip` of the optionals using the
`zip` on arrays as the transformation function.
""",
      timestamp: nil,
      type: .paragraph
    ),













    .init(
      content: """
---

# Exercises for Zip Part 2

## Exercise 9

> Can you make the `zip2` function on our `F3` type thread safe?

You can use GCD's [`DispatchGroup`](https://developer.apple.com/documentation/dispatch/dispatchgroup) to
precisely coordinate two units of work so that we are notified when they are both finished, and we avoid
the racing problems we mentioned in the episode. Here's how we can use it:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B>(_ fa: Parallel<A>, _ fb: Parallel<B>) -> Parallel<(A, B)> {
  return .init { callback in
    let group = DispatchGroup()
    var a: A!
    var b: B!

    group.enter()
    fa.subscribe { a = $0; group.leave() }

    group.enter()
    fb.subscribe { b = $0; group.leave() }

    group.notify(queue: .main) {
        callback((a, b))
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Here we have chosen to notify the group's completion on the main thread, but a more robust `Parallel`
implementation might make that customizable.

---

## Exercise 10

> Generalize the `F3` type to a type that allows returning values other than `Void`:
`struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type
parameter.

TODO
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
---

## Exercise 11

> Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on
it?

Have you ever looked at the method signature of `withUnsafeBytes`? I mean, _really` looked at it? Here it
is:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func withUnsafeBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
There's a lot of noise in this function signature, so let's clear it up a bit by removing all the `throws`
stuff and shortening the `Result` generic name:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) -> R) -> R
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Ok interesting. If we focus on just the shape of this, we see it's a function of the form:
`((UnsafeRawBufferPointer) -> R) -> R`. That is precisely `F4<UnsafeRawBufferPointer, R>` as defined
in exercise 10.

TODO
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
---

## Exercise 12

> This exercise consists of multiple parts, and aims to explore what happens when you nest two types that
each support a `zip` operation.

### Exercise 12.1

> Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also
the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip
structures? Write the signature of such a function and implement it.

We accidentally put in both part 1 and 2 episodes, so we already solved it above!

### Exercise 12.2

> Consider the type `[Validated<A, E>]`. We again have have a nesting of types, each of which have their
own `zip2` operation. Can you define a `zip2` on this type that makes use of both `zip` structures? Write
the signature of such a function and implement it.

Let's start by writing the signature of the function we want to implement:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, E>(_ a: [Validated<A, E>], _ b: [Validated<B, E>]) -> [Validated<(A, B), E>] {
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
If we perform a `zip` on the arrays, then we will get an array of tuples, where each component of the tuple
is a validated value. We can then `map` into _that_ array, and apply `zip` on the validated values:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, E>(_ a: [Validated<A, E>], _ b: [Validated<B, E>]) -> [Validated<(A, B), E>] {
  return zip2(a, b).map(zip2)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
---

### Exercise 12.3

> Consider the type `Func<R, A?>`. Again we have a nesting of types, each of which have their own `zip2`
operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of
such a function and implement it.

TODO

---

### Exercise 12.4

> Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2`
operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of
such a function and implement it.

TODO

---

### Exercise 12.4

> Finally, conisder the type `F3<Validated<A, E>>`. Yet again we have a nesting of types, each of which have
their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write
the signature of such a function and implement it.

TODO

---

## Exercise 13

> Do you see anything common in the implementation of all of the functions in the previous exercise? What this
is showing is that nested zippable containers are also zippable containers because `zip` on the nesting can
be defined in terms of zip on each of the containers.

TODO

---

## Exercise 14

> In this series of episodes on `zip` we have described zipping types as a kind of way to swap the order of
nested containers when one of those containers is a tuple, e.g. we can transform a tuple of arrays to an
array of tuples `([A], [B]) -> [(A, B)]`. There's a more general concept that aims to flip containers of any
type. Implement the following to the best of your ability, and describe in words what they represent:

---

### Exercise 14.1

> `sequence: ([A?]) -> [A]?`

TODO

---

### Exercise 14.2

> `sequence: ([Result<A, E>]) -> Result<[A], E>`

TODO

---

### Exercise 14.3

> `sequence: ([Validated<A, E>]) -> Validated<[A], E>`

TODO

---

### Exercise 14.4

> `sequence: ([Parallel<A>]) -> Parallel<[A]>`

TODO

---

### Exercise 14.5

> `sequence: (Result<A?, E>) -> Result<A, E>?`

TODO

---

### Exercise 14.6

> `sequence: (Validated<A?, E>) -> Validated<A, E>?`

TODO

---

### Exercise 14.6

> `sequence: ([[A]]) -> [[A]]`. Note that you can still flip the order of these containers even though they
are both the same container type. What does this represent? Evaluate the function on a few sample nested
arrays.

TODO

---

### Exercise 14.7

> Note that all of these functions also represent the flipping of containers, e.g. an array of optionals
transforms into an optional array, an array of results transforms into a result of an array, or a
validated optional transforms into an optional validation, etc.
>
> Do the implementations of these functions have anything in common, or do they seem mostly distinct from
each other?

TODO

---

## Exercise 15

> There is a function closely related to `zip` called `apply`. It has the following shape:
`apply: (F<(A) -> B>, F<A>) -> F<B>`. Define `apply` for `Array`, `Optional`, `Result`, `Validated`,
`Func` and `Parallel`.

TODO

---

## Exercise 15

> Another closely related function to `zip` is called `alt`, and it has the following shape:
`alt: (F<A>, F<A>) -> F<A>`. Define `alt` for `Array`, `Optional`, `Result`, `Validated` and `Parallel`.
Describe what this function semantically means for each of the types.

This function encapsulates how to combine two values of the same type in some context into just a single
context of that type. For arrays, a natural way to do this would be simply array concatenation:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func alt<A>(_ lhs: [A], _ rhs: [A]) -> [A] {
  return lhs + rhs
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
For optionals, let's write down the signature and see what possible implementations there are:
}
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func alt<A>(_ lhs: A?, _ rhs: A?) -> A? {
  switch (lhs, rhs) {
  case let (.none, .none):
    fatalError()
  case let (.some(lhs), .none):
    fatalError()
  case let (.none, .some(rhs)):
    fatalError()
  case let (.some(lhs), .some(rhs)):
    fatalError()
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We've filled in the first step, which is to simply to switch on the two optionals handed to us. In the first
case we have two `.none` values, and so there's nothing we could hope to do to return an `A` value, so we'll
just return `nil`. In the next 2 cases we have a `.some` value of type `A`, and so let's just return it.
The last case is the trickiest, in which we have two `.some` values of type `A`. We don't know anything
about `A` so we can't combine those values in anyway reasonable way. Therefore we must just decide to
return one of them, so we'll return the first one:
}
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func alt<A>(_ lhs: A?, _ rhs: A?) -> A? {
  switch (lhs, rhs) {
  case let (.none, .none):
    return nil
  case let (.some(lhs), .none):
    return lhs
  case let (.none, .some(rhs)):
    return rhs
  case let (.some(lhs), .some(rhs)):
    return lhs
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This function should seem quite familiar to you. It's precisely `??`, Swift's `nil` coalescing operator.
This provides important semantic meaning to the `alt` function, because in the case of optionals it means
"return the first non-`nil` value, otherwise return `nil`." This is what allows you to chain many of these
functions together to express the idea of getting the first non-`nil` value from a bunch of optionals.

Next we will consider `Result`. How can we combine two `Result<A, E>`'s into just a single one? Let's take
some inspiration from our comments on `Optional` above, and think about this semantically. We will define
`alt` on `Result` to be the operation of returning the first `.success` value if it exists, and otherwise
return the _last_ `.failure`. Here's the implementation:
}
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func alt<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
  switch (a, b) {
  case let (.success(a), _):
    return .success(a)
  case let (.failure, .success(b)):
    return .success(b)
  case let (.failure, .failure(e)):
    return .failure(e)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The implementation for `alt` on `Validated` is very similar.

Finally, we have the `Parallel` type. How can we combine two `Parallel<A>`'s into just a single one? If
we were to run both parallel values at the same time, and then at a later time procure two values of type
`A` from them, there still wouldn't be anyway to combine both values into one since we know _nothing_ about
the type `A`. Seems like no matter what we have to discard information. Similar to what we've done with
`Result`, maybe we should only take the first one that finishes? We can implement that like so:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func alt<A>(_ lhs: Parallel<A>, _ rhs: Parallel<A>) -> Parallel<A> {
  return .init { f in
    var finished = false
    let callback: (A) -> () = {
      guard !finished else { return }
      finished = true
      f($0)
    }
    lhs.run(callback)
    rhs().run(callback)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Semantically this means that we are _racing_ both parallels, and just picking the one that is fastest.
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
  id: 11,
  publishedAt: Date(timeIntervalSince1970: 1_532_930_223 + 604_800*2),
  title: "Solutions to Exercises: Zip"
)

/*

    .init(
      content: """
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
""",
      timestamp: nil,
      type: .paragraph
    ),

 */
