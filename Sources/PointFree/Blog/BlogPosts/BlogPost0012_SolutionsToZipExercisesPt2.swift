import Foundation

let post0012_solutionsToZipExercisesPt2 = BlogPost(
  author: .brandon,
  blurb: """
Today we solve the exercises to the second part of our introductory series on zip.
""",
  contentBlocks: [
    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0012-solutions-to-zip-pt2/poster.jpg")
    ),

    .init(
      content: """
---

Last week we concluded our 3-part introductory series to the `zip` function. In the
[second episode](/episodes/ep24-the-many-faces-of-zip-part-2) of that series we saw that many types support
`zip`-like operations, even though we don't typically think of those types in that way. For example,
two `Result` values can be zipped up, and even two functions with the same input can be zipped. At the end of
the episode we provided some exercises to help viewers dive a little deeper into what `zip` had to offer, and
this week we solve most of those problems!

---

## Exercise 1

> Can you make the `zip2` function on our `Parallel` type thread safe?

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
    fa.run { a = $0; group.leave() }

    group.enter()
    fb.run { b = $0; group.leave() }

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
implementation might make that customizable. It's interesting to think of `DispatchGroup`'s as just
GCD's version of a `zip` operation. We feel that `zip` is a little more expressive and composable
than `DispatchGroup`'s are.

---

## Exercise 2

> Generalize the `Parallel` type to a type that allows returning values other than `Void`:
`struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type
parameter.

Although this `F4` type is closely related to `Parallel`, its `zip` implementation is a bit different.
If we try to repeat what we did for `Parallel` above we will quickly run into the problem that we must
return an `R` value from each of the `fa.run` and `fb.run` functions, and we don't have any such value.
Instead, we can take the approach we first took in [episode two](/episodes/ep24-the-many-faces-of-zip-part-2)
when trying to define `zip` on `Parallel`, and we will nest the `run` blocks:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(_ fa: F4<A, R>, _ fb: F4<B, R>) -> F4<(A, B), R> {
  return .init { callback in
    fa.run { a in
      fb.run { b in
        callback((a, b))
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
---

## Exercise 3

> Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on
it?

Have you ever looked at the method signature of `withUnsafeBytes`? I mean, _really_ looked at it? Here it
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
`((UnsafeRawBufferPointer) -> R) -> R`. That is basically `F4<UnsafeRawBufferPointer, R>` as defined
in exercise 2!

Unfortunately, we cannot just wrap these functions up in an `F4` value, and then start zipping them. The
`throws` and `rethrows` annotations make these function signatures distinct from that of `F4`. Instead
of littering our `F4` type with `throws` annotations, let's just define a specialized `zip2` for functions
of the form `((A) throws R) throws R`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(
  _ f: @escaping ((A) throws -> R) throws -> R,
  _ g: @escaping ((B) throws -> R) throws -> R
  ) -> (@escaping (A, B) throws -> R) throws -> R {

  return { callback in
    try f { a in
      try g { b in
        try callback(a, b)
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
Ok, now that we have `zip` defined, how can we use it? Well, imagine we had some C function that was imported
that operates on `UnsafeRawBufferPointer` values. Then we could `zip` up the `withUnsafeBytes` of two
arrays and invoke that C function:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
var xs = [1, 2, 3]
var ys = [4, 5, 6]

func someCFunction(_ x: UnsafeRawBufferPointer, _ y: UnsafeRawBufferPointer) -> Int {
  // Do something with the pointers here...
  return 1
}

try (zip2(xs.withUnsafeBytes, ys.withUnsafeBytes)) { x, y in
  someCFunction(x, y)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This allows you to clearly express that you want to grab the underlying bytes of the array storage
and invoke a C function with those contents. The alternative way is to nest multiple calls to
`withUnsafeBytes`, which leads to highly indented code and "callback hell":
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
try xs.withUnsafeBytes { x in
  try ys.withUnsafeBytes { y in
    someCFunction(x, y)
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Notice that we had to nest two layers deep, and if we were to need more unsafe bytes the indentation would
continue to grow. The `zip` method for handling unsafe bytes is shorter and more expressive.

---

## Exercise 4

> This exercise consists of multiple parts, and aims to explore what happens when you nest two types that
each support a `zip` operation.

### Exercise 4.1

> Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also
the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip
structures? Write the signature of such a function and implement it.

We accidentally put in both part 1 and 2 episodes, so we already solved it
[before](\(path(to: .blog(.show(post0011_solutionsToZipExercisesPt1)))))!

### Exercise 4.2

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
This allows us to express the idea of taking two lists of validated values, and combining them into one
list, where if there are any errors they combine, and otherwise we get a tuple of the valid values.

---

### Exercise 4.3

> Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2`
operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of
such a function and implement it.

Let's start by writing the signature of the function we want to implement:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(_ a: Func<R, [A]>, _ b: Func<R, [B]>) -> Func<R, [(A, B)]> {
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We know how to perform `zip` on `Func` values, so we could start with that:

""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(_ a: Func<R, [A]>, _ b: Func<R, [B]>) -> Func<R, [(A, B)]> {
  zip2(a, b) // Func<R, ([A], [B])>
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Also, `map` on `Func` operates on the second type parameter, in this case `([A], [B])`, and that's precisely
the shape we like for `zip`, so sounds like we can do those two operations together:

""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, R>(_ a: Func<R, [A]>, _ b: Func<R, [B]>) -> Func<R, (A, B)> {
  return zip2(a, b).map(zip2)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
---

### Exercise 4.4

> Finally, conisder the type `Parallel<Validated<A, E>>`. Yet again we have a nesting of types, each of which have
their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write
the signature of such a function and implement it.

Well, now I think you are probably seeing the pattern, but let's go through the steps anyway. Let's start by
writing out the signature:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, E>(_ a: Parallel<Validated<A, E>>, _ b: Parallel<Validated<B, E>>) -> Parallel<Validated<(A, B), E>> {
  fatalError()
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
If we `zip` both of these parallel values together, we will arrive at another parallel value that holds
two validated values. So, we can `map` into that new parallel value, and then `zip` the two validated
values inside it. This implements the function:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func zip2<A, B, E>(_ a: Parallel<Validated<A, E>>, _ b: Parallel<Validated<B, E>>) -> Parallel<Validated<(A, B), E>> {
  return zip2(a, b).map(zip2)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This allows us to simultaneously perform two parallel tasks and two validations at the same time, bringing
the results into one single value. Very powerful!

---

## Exercise 5

> Do you see anything common in the implementation of all of the functions in the previous exercise? What this
is showing is that nested zippable containers are also zippable containers because `zip` on the nesting can
be defined in terms of zip on each of the containers.

Every implementation of `zip` on nested containers looked identical. We first `zip` the outer containers, then
`map` on that container with the `zip` on the inner containers. What we are seeing here is that nested
zippable containers are _always_ zippable themselves. Unfortunately Swift does not have the type level
features that allows us to express this algorithm generically, and so we are forced to write the
`zip2(lhs, rhs).map(zip2)` boilerplate _every_ time we want to nest two zippable containers. Maybe someday
this will be better!

---

And that's the solutions to the [second part](/episodes/ep24-the-many-faces-of-zip-part-2) of our 3 part
introductory series to `zip`! If you thought those were too easy, be sure to check out the exercises to
[part 3](/episodes/ep25-the-many-faces-of-zip-part-3) too. Until next time!
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0012-solutions-to-zip-pt2/poster.jpg",
  id: 12,
  publishedAt: Date(timeIntervalSince1970: 1534312623),
  title: "Solutions to Exercises: Zip Part 2"
)
