import Foundation

let ep2 = Episode(
  blurb: """
Side effects: can’t live with ’em; can’t write a program without ’em. Let’s explore a few kinds of side effects we encounter every day, why they make code difficult to reason about and test, and how we can control them without losing composition.
""",
  codeSampleDirectory: "0002-side-effects",
  exercises: [],
  fullVideo: .init(
    bytesLength: 890_410_175,
    downloadUrl: "https://d1hf1soyumxcgv.cloudfront.net/0002-side-effects/full-720p-BB35D372-8907-4CA2-AAEB-82B5BB5F1311.mp4",
    streamingSource: "https://d1hf1soyumxcgv.cloudfront.net/0002-side-effects/full/0002-side-effects.m3u8"
  ),
  id: 2,
  image: "https://d1hf1soyumxcgv.cloudfront.net/0002-side-effects/0002-poster.jpg",
  itunesImage: "https://d1hf1soyumxcgv.cloudfront.net/0002-side-effects/itunes-poster.jpg",
  length: 2676,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_517_811_069),
  sequence: 2,
  title: "Side Effects",
  trailerVideo: nil,
  transcriptBlocks: transcriptBlocks
)

private let transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've now had an entire episode just about functions where we emphasized the importance of looking at the input and output types of functions to understand how they compose, but there are a lot of things a function can do that aren't captured by its signature alone. These things are called "side effects."

Side effects are one of the biggest sources of complexity in code, and to make things worse they're very difficult to test and they don't compose well. We've seen from the last episode that we get a lot of benefits from embracing function composition, but side effects throw a wrench in that.

In this episode we'll cover a few kinds of side effects, show why they're so difficult to test, why they don't compose, and try to address these problems in a nice way.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Side effect is a pretty overloaded term, so in order to define it, let's first look at a function that has no side effects:
""",
    timestamp: 43,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func compute(_ x: Int) -> Int {
  return x * x + 1
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
When we call our function, we get a result back:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
compute(2) // 5
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
A really nice property of functions without side effects is that no matter how many times we call one with the same input, we always get the same output:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
compute(2) // 5
compute(2) // 5
compute(2) // 5
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This predictability makes it incredibly simple to write tests for them.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(5, compute(2)) // ✅
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we ever write a test with the wrong expectation or the wrong input for an expectation, it will _always_ fail.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(4, compute(2)) // ❌
assertEqual(5, compute(3)) // ❌
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Let's add a side effect to our function.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func computeWithEffect(_ x: Int) -> Int {
  let computation = x * x + 1
  print("Computed \\(computation)")
  return computation
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've inserted a `print` statement right in the middle.

When we call `computeWithEffect` with the same input as before, we get the same output:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
computeWithEffect(2) // 5
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But if we look at our console, there's some _additional_ output here.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Computed 5
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
If we compare function signatures, `computeWithEffect` is exactly the same as `compute`, but work is being done that we couldn't have accounted for by looking at the signature alone. The `print` function is reaching out into the world and making a change, in this case, printing to our console. Side effects require understanding the body of the function to know they're hiding in there.

Let's write a test for this function:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(5, computeWithEffect(2)) // ✅
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It passes! But now we have an _additional_ line in our console.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Computed 5
Computed 5
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
And this is behavior that we just can't test. Here we're just printing to the console, so it may not seem like a big deal, but if we swapped printing out for another effect, like writing to disk, making an API request, or analytics tracking, we start to care more that this behavior is happening and that we can test it.

Side-effects can also break compositional intuitions we build. In our episode on functions, we discussed how mapping over an array with two functions is the same as mapping over an array with the composition of those functions:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[2, 10].map(compute).map(compute) // [26, 10202]
[2, 10].map(compute >>> compute)  // [26, 10202]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now let's try that with `computeWithEffect`:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[2, 10].map(computeWithEffect).map(computeWithEffect)
// [26, 10202]
[2, 10].map(computeWithEffect >>> computeWithEffect)
// [26, 10202]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The return values are equal, but when we look at the console, the behavior is not!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Computed 5
Computed 101
Computed 26
Computed 10202
--
Computed 5
Computed 26
Computed 101
Computed 10202
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
We can no longer take advantage of this property without having to consider the side effects. Our ability to make this kind of refactor is a real-world performance optimization: instead of traversing our array twice, we traverse it just once. If our functions have side effects, though, they won't execute in the same order, and order may be something we depend on! Making this kind of performance optimization in the world of side effects could break our code!
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Hidden outputs",
    timestamp: 320,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's look at the simplest way to control this side effect. Rather than performing the effect in the body of the function, we can return an extra value that describes what needs to be printed. A function could print many things, so we'll use an array of strings to model this.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func computeAndPrint(_ x: Int) -> (Int, [String]) {
  let computation = x * x + 1
  return (computation, ["Computed \\(computation)"])
}

computeAndPrint(2) // (5, ["Computed 5"])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We get a result of not only the computation, but an array of logs we may want to print.

Let's write a test:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(
  (5, ["Computed 5"]),
  computeAndPrint(2)
)
// ✅
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we're getting coverage not only on the computation, but on the effect we want to perform! Our test will now fail if the side effect is in an unexpected format.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(
  (5, ["Computed 3"]),
  computeAndPrint(2)
)
// ❌
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The data is quite simple here, but remember, it could potentially be more critical data that describes an API request or analytics event, and we could be writing assertions that these effects are being prepared the way we expect them to.

Viewed in this way, a side effect that makes a change to the outside world is nothing but a hidden, implicit output of the function. Implicit is usually not a good thing when it comes to programming.

Now you may ask, "Well, who performs the effect?" By pulling the effect out into the return type, we have pushed responsibility for this effect to whoever calls this function. For example:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let (computation, logs) = computeAndPrint(2)
logs.forEach { print($0) }
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We may not want the caller to have side effects, though, so it may have to pass them along, as well. And maybe _its_ caller doesn't want to have side effects, and so on! This sounds like a messy problem, but there are nice ways to solve it. Before we can solve _that_ problem, though, we need to understand _this_ one in detail.
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: """
It may seem like we've solved the effects problem: we just need to substitute them with descriptions in the output of our functions. Unfortunately, we've broken one of the most important features of functions: composition.

Our `compute` function is nice because it forward-composes with itself.
""",
    timestamp: 495,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
compute >>> compute // (Int) -> Int
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And our `computeWithEffect` function is actually kind of nice because it _also_ forward-composes with itself.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
computeWithEffect >>> computeWithEffect // (Int) -> Int
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can pipe values into them and get results.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> compute >>> compute // 26
2 |> computeWithEffect >>> computeWithEffect // 26
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Of course, now we're back to having `computeWithEffect` printing to the console.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Computed 5
Computed 26
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, our attempt to solve this problem, `computeAndPrint`, does _not_ compose.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
computeAndPrint >>> computeAndPrint
// Cannot convert value of type '(Int) -> (Int, [String])' to expected argument type '((Int, [String])) -> (Int, [String])'
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The output of `computeAndPrint` is a tuple, `(Int, [String])`, but the input is just `Int`.

We'll see this time and again: anytime we have a function that needs to execute a side effect, we'll augment the return type to describe the effect, and we'll break function composition. Then it'll be our job to cook up some kind of way to enhance composition on these kinds of functions.

In the case of functions that return tuples, we can fix the composition quite nicely and do so even more generally than our `computeAndPrint` function. Let's define a function whose entire job is to compose these kinds of functions.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func compose<A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {

  // …
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This looks kind of familiar. It has a signature similar to our `>>>` function: we see `(A) -> B`, `(B) -> C`, and `(A) -> C`, but with a little extra information alongside.

We can implement this function by looking at the type of functions and the values we have at our disposal.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func compose<A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {

  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We know we're returning a function, so we start by opening it up and binding `a`. We also have a function, `f`, that takes `A`s, so let's pass it `a` and bind the return values, in this case, a `b` and some `logs`. Now that we have a `b` that plugs nicely into the function `g`, and it returns a `c` and some `moreLogs`. And now that we have a `c`, we can return it from our function alongside some logs. We could return `logs` or `moreLogs`, but in this case it makes sense to return the concatenation of both.

So let's compose our functions!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
compose(computeAndPrint, computeAndPrint)
// (Int) -> (Int, [String])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've now created a whole new function that calls `computeAndPrint` twice. When we feed data into it, we get not only the final computation, but logs of every step along the way.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> compose(computeAndPrint, computeAndPrint)
// (26, ["Computed 5", "Computed 26"])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),



  Episode.TranscriptBlock(
    content: "Introducing >=>",
    timestamp: 660,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
It seems like we've recovered composition and completely solved the problem, but things start to get messy when we compose more than two functions.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> compose(compose(computeAndPrint, computeAndPrint), computeAndPrint)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What's maybe worse is that there are two different ways to make the same composition:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> compose(compose(computeAndPrint, computeAndPrint), computeAndPrint)
2 |> compose(computeAndPrint, compose(computeAndPrint, computeAndPrint))
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Parentheses always seem to be the enemy of composition. What's the enemy of parentheses? An infix operator.

We know we want to be able to compose multiple times in a row, and we know we want to be able to pipe values into these compositions, so let's define an associative precedence group that's higher than our `|>` operator.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we can define an infix operator that looks a little familiar.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator >=>: EffectfulComposition
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's very close to `>>>`, but we've swapped out the inner arrow for a tube-like `=`. A fun name for this operator is the "fish" operator.

We can now rename our `compose` function and we can glue our effectful functions together without the noise and burden of having to reason about parentheses.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func >=> <A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> (A) -> (C, [String]) {

  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}

computeAndPrint >=> computeAndPrint >=> computeAndPrint // (Int) -> (Int, [String])
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can pipe values through and user multiple lines to create pipelines that read nicely from top to bottom.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2
  |> computeAndPrint
  >=> computeAndPrint
  >=> computeAndPrint
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Another nice thing about bringing our composition into the operator world is that it plays more nicely with existing operators like `>>>`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2
  |> computeAndPrint
  >=> (incr >>> computeAndPrint)
  >=> (square >>> computeAndPrint)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here we're able to take the results of effectful functions and apply them to functions that don't have side effects, all with composition. We have a new parentheses problem, but we can solve it! Function composition is maybe the strongest form of composition, and given where the parentheses appear, and the input and output types along the way, we can come to the conclusion that it should always have a higher precedence. This means we need to update our `EffectfulComposition` precedence group.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
  lowerThan: ForwardComposition
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We no longer need parentheses and we can further pipeline our composition.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2
  |> computeAndPrint
  >=> incr
  >>> computeAndPrint
  >=> square
  >>> computeAndPrint
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Every line is now annotated with an operator that provides meaning. Lines prefixed with `>>>` are dealing with the result of a function that has no side effect, while lines prefixed with `>=>` are a bit fishier: they're dealing with the result of an effectful computation.

We've introduced a new operator, so it's time to justify its addition to our code.

1. Does this operator have existing meaning in Swift? Nope. There's no chance of overloading existing meaning.

2. Does this operator have prior art and does it have a nice, descriptive shape? Yep! The fish operator ships with Haskell and PureScript, and many other programming languages communities have adopted it in functional libraries. The shape is nice, especially alongside `>>>`, where it's just different enough to indicate that something else is going on.

3. Is this a universal operator or is it only solving a domain specific problem? The way the operator is defined right now is quite specific to working on tuples, but the shape it's describing shows up all the time in programming. We can even define the operator on a couple Swift types:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func >=> <A, B, C>(
  _ f: @escaping (A) -> B?,
  _ g: @escaping (B) -> C?
  ) -> ((A) -> C?) {

  return { a in
    fatalError() // an exercise for the viewer
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've replaced our tuples with optionals and now have an operator that aids in composing functions that return optionals. We can now chain a couple failable initializers together:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
String.init(utf8String:) >=> URL.init(string:)
// (UnsafePointer<Int8>) -> URL?
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And we get a brand new failable initializer for free!

We could also use the operator to enhance composition with functions that return arrays:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func >=> <A, B, C>(
  _ f: @escaping (A) -> [B],
  _ g: @escaping (B) -> [C]
  ) -> ((A) -> [C]) {

  return { a in
    fatalError() // an exercise for the viewer
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And if we were using a `Promise` or `Future` type, we could use the operator to compose functions that return promises.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func >=> <A, B, C>(
  _ f: @escaping (A) -> Promise<B>,
  _ g: @escaping (B) -> Promise<C>
  ) -> ((A) -> Promise<C>) {

  return { a in
    fatalError() // an exercise for the viewer
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We'll see this shape come up time and time again. In some languages with very powerful type systems, it's possible to define this operator a single time and get all of these implementations immediately. Swift does not yet have these features, so we have to define them for new types as we go. We're still able to build an intuition for this shape, though, and share it over many, many types. Now when we see `>=>` we can know that it's chaining into some kind of effect.
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: """
Hidden inputs
""",
    timestamp: 1131,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've covered a side effect that leads to a hidden output and shown how to control it by making that output explicit in our functions, all while retaining composability. There's another kind of side effect that's a bit trickier.

Let's look at a simple function that produces a greeting for a user.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greetWithEffect(_ name: String) -> String {
  let seconds = Int(Date().timeIntervalSince1970) % 60
  return "Hello \\(name)! It's \\(seconds) seconds past the minute."
}

greetWithEffect("Blob")
// "Hello Blob! It's 14 seconds past the minute."
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
When we run this code again, we're likely to get a different value. This is the opposite of the predictability we had with our `compute` function.

If we write a test, it's almost always going to fail.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(
  "Hello Blob! It's 32 seconds past the minute.",
  greetWithEffect("Blob")
)
// ❌
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is a particularly bad side effect. In our previous case we could at the very least write assertions against its output, we just weren't covering the whole story. In this case we cant even write a test because the output keeps changing.

Our previous side effect was `print`, which is a function that takes input but has no return value. In this case we have `Date`, which is a function that _has_ a return value but takes no input.

Let's see if we can use a similar solution for this side effect. Earlier we made `print`'s effect explicit in `compute`'s return value, and here we can make `Date`'s effect explicit as an argument to the function.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greet(at date: Date, name: String) -> String {
  let seconds = Int(date.timeIntervalSince1970) % 60
  return "Hello \\(name)! It's \\(seconds) seconds past the minute."
}

greet(at: Date(), name: "Blob")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This function behaves the same as before but with one crucial difference: we can now control the date and have a test that always passes.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(
  "Hello Blob! It's 39 seconds past the minute.",
  greet(at: Date(timeIntervalSince1970: 39), name: "Blob")
)
// ✅
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've recovered testability at the cost of some boilerplate. The caller of the function needs to pass the date explicitly, which seems unnecessary outside of our tests. We may be tempted to hide this implementation detail by specifying a default argument and inject this dependency on the current date into our function to clean up the call site.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greet(at date: Date = Date(), name: String) -> String {
  let s = Int(date.timeIntervalSince1970) % 60
  return "Hello \\(name)! It's \\(s) seconds past the minute."
}

greet(name: "Blob")
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This reads a bit nicer, but we have a bigger problem: we've broken composition again.

Our first `greetWithEffect` function had a nice `(String) -> String` shape that could be composed with other functions that return strings and functions take strings as input.

Let's take a simple function that uppercases a string:
""",
    timestamp: 1355,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func uppercased(_ string: String) -> String {
  return string.uppercased()
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This composes nicely on either side of `greetWithEffect`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
uppercased >>> greetWithEffect
greetWithEffect >>> uppercased
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can pipe a name through and get different behavior for each composition.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
"Blob" |> uppercased >>> greetWithEffect
// "Hello BLOB! It's 56 seconds past the minute."
"Blob" |> greetWithEffect >>> uppercased
// "HELLO BLOB! IT'S 56 SECONDS PAST THE MINUTE."
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Our `greet` function, however, does not compose.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
"Blob" |> uppercased >>> greet
"Blob" |> greet >>> uppercased
// Cannot convert value of type '(Date, String) -> String' to expected argument type '(_) -> _'
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It takes two inputs, so there's no way to compose the output of a function into it. If we ignore the `Date` input, we can kind of still see that `(String) -> String` shape. In fact, there's a bit of a trick we can do to pull the `Date` out of that signature: we can rewrite `greet` to take a `Date` as input, but return a brand new function from `(String) -> String` that handles the actual greeting logic:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func greet(at date: Date) -> (String) -> String {
  return { name in
    let s = Int(date.timeIntervalSince1970) % 60
    return "Hello \\(name)! It's \\(s) seconds past the minute."
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we can call our greet function with a date and get a brand new `(String) -> String` function.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
greet(at: Date()) // (String) -> String
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This function composes!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
uppercased >>> greet(at: Date()) // (String) -> String
greet(at: Date()) >>> uppercased // (String) -> String
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And we can pipe values through!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
"Blob" |> uppercased >>> greet(at: Date())
// "Hello BLOB! It's 37 seconds past the minute."
"Blob" |> greet(at: Date()) >>> uppercased
// "HELLO BLOB! IT'S 37 SECONDS PAST THE MINUTE."
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've restored composition and still have testability.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
assertEqual(
  "Hello Blob! It's 37 seconds past the minute.",
  "Blob" |> greet(at: Date(timeIntervalSince1970: 37))
)
// ✅
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
So now we've encountered an effect that was impossible to test and we were able to control it by moving that context into the input of the function, which is the dual version of the effect we came across earlier. Our first effect reached out into the world and made a change, which is kind of like a hidden output, while this effect depends on some state of the outside world, which is kind of like a hidden input! All effects manifest in this way.
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Mutation",
    timestamp: 1589,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's look at a very particular type of effect and really analyze it: mutation. We've all had to deal with mutation in code and it can lead to a lot of complexity. Luckily, Swift provides some type-level features to help control mutation and properly document how and where it can happen.

Here's example of how mutation can get messy. This sample is inspired by actual code we wrote in the past, and it kept getting uglier and more of a pain to work with until we finally rewrote it to control the mutation.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let formatter = NumberFormatter()

func decimalStyle(_ format: NumberFormatter) {
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
}

func currencyStyle(_ format: NumberFormatter) {
  format.numberStyle = .currency
  format.roundingMode = .down
}

func wholeStyle(_ format: NumberFormatter) {
  format.maximumFractionDigits = 0
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here we have a `NumberFormatter` from `Foundation` and several functions that configure number formatters with specific styles. To use these styling functions, we can apply them directly to our formatter.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
decimalStyle(formatter)
wholeStyle(formatter)
formatter.string(for: 1234.6) // "1,235"

currencyStyle(formatter)
formatter.string(for: 1234.6) // "$1,234"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
If we now re-apply our first set of formatters, we have a problem.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
decimalStyle(formatter)
wholeStyle(formatter)
formatter.string(for: 1234.6) // "1,234"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
The output's changed from `"1,235"` to `"1,234"`. The reason it's changed? Mutation. The `currencyStyle` function's changes have bled into other uses of our formatter, resulting in a bug that in a larger context might be hard to track down.

This is an example of why mutation is so tricky. It's impossible to know what a line is doing until we trace back to learn what every line before it has done. Mutation is a manifestation of both of the side effects we've encountered so far, where mutable data passed between functions is a hidden input and output in one!

The reason we're seeing this particular kind of mutation is because `NumberFormatter` is a "reference" type. In Swift, classes are reference types. An instance of a reference type is a single object that, when mutated, has changed for any part of the code base that holds onto or may hold onto a reference of this object. There's no easy way to track down which parts of a code base may hold onto the same reference of an object, which can lead to a lot of confusion when mutation is involved. If our example code were used in an application and a new feature were written to depend on this formatter, subtle bugs could creep into a totally new part of the code base.

Swift also has "value" types. This is Swift's answer to controlling mutation. When you assign a value, you get a brand new copy to work with for the given scope. All mutations are local and anything else holding onto the same value upstream won't see these changes.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's refactor this code to use values.

We'll start with a struct that is a wrapper around the configuration we do with `NumberFormatter`.
""",
    timestamp: 1773,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
struct NumberFormatterConfig {
  var numberStyle: NumberFormatter.Style = .none
  var roundingMode: NumberFormatter.RoundingMode = .up
  var maximumFractionDigits: Int = 0

  var formatter: NumberFormatter {
    let result = NumberFormatter()
    result.numberStyle = self.numberStyle
    result.roundingMode = self.roundingMode
    result.maximumFractionDigits = self.maximumFractionDigits
    return result
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It has some nice defaults and a `formatter` computed property that we can use to derive new, "honest" `NumberFormatter`s. What does it look like to update our styling functions to use `NumberFormatterConfig` instead?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func decimalStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
  return format
}

func currencyStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.numberStyle = .currency
  format.roundingMode = .down
  return format
}

func wholeStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.maximumFractionDigits = 0
  return format
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Each styling function takes a `NumberFormatterConfig`, copies it using the `var` keyword, and mutates the local copy before returning it to the caller.

Using it looks a bit different.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let config = NumberFormatterConfig()

wholeStyle(decimalStyle(config))
  .formatter
  .string(for: 1234.6)
// "1,235"

currencyStyle(config)
  .formatter
  .string(for: 1234.6)
// "$1,234"

wholeStyle(decimalStyle(config))
  .formatter
  .string(for: 1234.6)
// "1,235"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This time, whenever we pass `config` to a styling function, we get a brand new copy, and our bug goes away!

We could have done something similar with reference types using the `copy` method on classes that implement `NSCopying` and return this copy explicitly:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func decimalStyle(_ format: NumberFormatter) -> NumberFormatter {
  let format = format.copy() as! NumberFormatter
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
  return format
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Unfortunately here, the compiler gives us no guarantees that we don't mutate the original formatter. On top of that, the caller may expect a copy, feel free to make further mutations, and the complexity builds from there!

Because reference types aren't automatically copied, they do have some nice performance benefits. Luckily, Swift provides a nice, semantic way of mutating values in place: the `inout` keyword.

Let's modify our config styling function to use `inout`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func inoutDecimalStyle(_ format: inout NumberFormatterConfig) {
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
}

func inoutCurrencyStyle(_ format: inout NumberFormatterConfig) {
  format.numberStyle = .currency
  format.roundingMode = .down
}

func inoutWholeStyle(_ format: inout NumberFormatterConfig) {
  format.maximumFractionDigits = 0
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This looks a lot like our original, mutating functions on `NumberFormatter`. We can perform mutations right away and don't have to worry about copying values or returning them. Let's try using these styling functions the same way we used the original ones.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
let config = NumberFormatterConfig()

inoutDecimalStyle(config)
inoutWholeStyle(config)
config.formatter.string(from: 1234.6)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We get a compiler error!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Cannot pass immutable value as inout argument: 'config' is a 'let' constant
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
Swift even offers to fix this for us, transforming `let` into `var`.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
var config = NumberFormatterConfig()

inoutDecimalStyle(config)
inoutWholeStyle(config)
config.formatter.string(from: 1234.6)
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But that wasn't enough. We have another compiler error!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Passing value of type 'NumberFormatterConfig' to an inout parameter requires explicit '&'
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
Swift requires us to annotate, at the call site, that we're agreeing to let this data be mutated.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6) // "1,235"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can continue to call our mutating style functions in a similar fashion.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
inoutCurrencyStyle(&config)
config.formatter.string(from: 1234.6) // "$1,234"

inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6) // "1,234"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And there's our bug again, but the code involved now has a lot of syntax that screams "mutation" and it makes this kind of bug much easier to track down.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
It's great that Swift provides a nice solution to mutation problems by providing type-level features to control where mutation can happen and how far it can travel. We still have a problem to solve if we want to use it, though.

The styling functions we used that returned brand new copies have a nice shape:
""",
    timestamp: 2082,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
(NumberFormatterConfig) -> NumberFormatterConfig
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
They have the same input and output which means they compose with each other, _and_ they compose with any other functions that return or take a `NumberFormatterConfig`!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
decimalStyle >>> currencyStyle
// (NumberFormatterConfig) -> NumberFormatterConfig
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now we have a brand new styling function that we've composed from smaller pieces.

Meanwhile, our `inout` functions don't have this shape: their inputs and outputs don't match and they don't compose with many functions in general. These functions have the same logic, though, so there must be a way to bridge the `inout` world with the function world.

It turns out that we can define a function called `toInout` that converts a function with the same input and output type into an `inout` function.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func toInout<A>(
  _ f: @escaping (A) -> A
  ) -> ((inout A) -> Void) {

  return { a in
    a = f(a)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can also define a dual function, `fromInout`, that does the inverse transformation.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func fromInout<A>(
  _ f: @escaping (inout A) -> Void
  ) -> ((A) -> A) {

  return { a in
    var copy = a
    f(&copy)
    return copy
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What we see here is there's a natural correspondence between `(A) -> A` functions and `(inout A) -> Void` functions. Functions from `(A) -> A` compose very nicely, so through this correspondence, we would hope that functions from `(inout A) -> Void` could share these compositional qualities.
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Introducing <>",
    timestamp: 2275,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Even though we saw that `(A) -> A` functions compose using `>>>`, we shouldn't reuse this operator because it has way too much freedom. We're looking at a much more constrained, single-type composition. So let's define a new operator. Let's start with the precedence group.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And let's define our operator.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator <>: SingleTypeComposition
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
A fun name for this operator is the "diamond" operator.

We can define the operator against `(A) -> A` simply enough:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func <> <A>(
  f: @escaping (A) -> A,
  g: @escaping (A) -> A)
  -> ((A) -> A) {

  return f >>> g
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It may looks silly to have just wrapped one operator with another, but we've constrained how it can be used and encoded some meaning: when we see this operator we know we're dealing with a single type!

Let's define `<>` for `inout` functions:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func <> <A>(
  f: @escaping (inout A) -> Void,
  g: @escaping (inout A) -> Void)
  -> ((inout A) -> Void) {

  return { a in
    f(&a)
    g(&a)
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Our previous composition works.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
decimalStyle <> currencyStyle
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Better yet, we can compose our `inout` styling functions!
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
inoutDecimalStyle <> inoutCurrencyStyle
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
What happens when we start piping values into our compositions?
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
config |> decimalStyle <> currencyStyle
config |> inoutDecimalStyle <> inoutCurrencyStyle
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Our `inout` version produces an error.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Cannot convert value of type '(inout Int) -> ()' to expected argument type '(_) -> _'
""",
    timestamp: nil,
    type: .code(lang: .plainText)
  ),
  Episode.TranscriptBlock(
    content: """
This is because `|>` doesn't yet work in the world of `inout`, but we can define an overload that does.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
  f(&a)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And now we can freely pipe values into these mutable pipelines.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
config |> inoutDecimalStyle <> inoutCurrencyStyle
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is great! We don't have to sacrifice composability to take advantage of some nice Swift features.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
We've solved this problem at the cost of yet another operator, so it's time to check the boxes.

1. Does this operator exist in Swift? Nope, so no potential for confusion there.

2. Is there prior art? Yep. It exists in Haskell, PureScript, and other languages with strong functional communities that have adopted it. It has a nice shape that points in both directions and kind of signals a joining together.

3. Is this a universal operator or is it only solving a domain specific problem? We've only defined this operator for `(A) -> A` functions and `(inout A) -> Void` functions so far, but it turns out that `<>` is used far more generally for combining two things of the same type into one, which is kind of the most fundamental unit of computation there is. We're going to encounter this operator all over the place.
""",
    timestamp: nil,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: 2597,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
It's time to slow down and ask: "What's the point?" We've encountered a lot of effects that introduced complexity into our code and made it more difficult to test. We decided to fix this by doing a little bit of upfront work to make the effects explicit in the types, both inputs and outputs, but then we broke composition. Then we introduced operators that aid in composition specifically for composing effects. Was it worth it?

We'd say so! We were able to lift our effectful code, which was untestable and difficult to reason about in isolation, up into a world where effects were explicit and we could test and understand a single line without understanding any of the lines that came before it. We did all of this without breaking composition. That's really powerful!

Meanwhile, our extra bit of upfront work should save us an immeasurable amount of time spent debugging code that has a complex web of mutation, time fixing bugs in side effects that are sprinkled everywhere, and time jumping through hoops to make code testable.

Side effects are a _huge_ topic, and we've only scratched the surface. We're going to be exploring lots of interesting ways to control side effects in the future. Stay tuned!
""",
    timestamp: nil,
    type: .paragraph
  ),
]
