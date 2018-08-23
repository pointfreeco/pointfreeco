import Foundation

let ep1 = Episode(
  blurb: """
Our first episode is all about functions! We talk a bit about what makes functions special, contrasting them with the way we usually write code, and have some exploratory discussions about operators and composition.
""",
  codeSampleDirectory: "0001-functions",
  id: 1,
  exercises: [],
  image: "https://d1hf1soyumxcgv.cloudfront.net/0001-functions/0001-poster.jpg",
  length: 1219,
  permission: .free,
  publishedAt: Date(timeIntervalSince1970: 1_517_206_269),
  sequence: 1,
  sourcesFull: [
    "https://d1hf1soyumxcgv.cloudfront.net/0001-functions/hls.m3u8",
    "https://d1hf1soyumxcgv.cloudfront.net/0001-functions/webm.webm"
  ],
  sourcesTrailer: [],
  title: "Functions",
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
Thanks for joining us for the first episode of Point-Free! Point-Free is going to cover a lot of functional programming concepts so let's start by defining what a function is: a computation with an input and output.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
Let's define a function. We can define an increment function that takes an `Int` and returns an `Int`:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func incr(_ x: Int) -> Int {
  return x + 1
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
To call our function, we pass a value to it.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
incr(2) // 3
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now let's define a `square` function to square an integer:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func square(_ x: Int) -> Int {
  return x * x
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can call it in a similar fashion:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
square(2) // 4
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can even nest our function calls. In order to first increment, then square a value:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
square(incr(2)) // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is pretty simple, but it's not very common in Swift. Top-level, free functions are generally avoided in favor of methods.

We can define `incr` and `square` as methods by extending `Int`:
""",
    timestamp: 68,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Int {
  func incr() -> Int {
    return self + 1
  }

  func square() -> Int {
    return self * self
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
To use our `incr` method, we can call it directly:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2.incr() // 3
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And we can square the result by chaining our method calls:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2.incr().square() // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This reads nicely from left-to-right whereas free functions read from inside-out, and it takes more mental work to see that we call `incr` before we call `square`. This is probably why free functions are less common in Swift. A very simple expression is much more difficult to read using traditional function calls. We can imagine that a more complicated nest of function calls would be all the more difficult to unpack. Methods don't have this problem.
""",
    timestamp: 110,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Introducing |>",
    timestamp: 141,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
There are several languages out there that have free functions but retain this kind of readability by using an infix operator for function application. Swift lets us define our own operators, so let's see if we can do the same.
""",
    timestamp: 141,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator |>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Here we're defining a "pipe-forward" operator. It's based on prior art: F#, Elixir, and Elm all use this operator for function application.

To define this operator, we write a function:
""",
    timestamp: 154,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func |> <A, B>(a: A, f: (A) -> B) -> B {
  return f(a)
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's generic over two types: `A` and `B`. The lefthand side is our value, of type `A`, while the righthand side is a function from `A` to `B`. We finally return `B` by applying our value to our function.

Now we can take a value and pipe it into our free function.
""",
    timestamp: 170,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr // 3
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We should be able to take this result and pipe it into another free function:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr |> square
""",
    timestamp: 200,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
But we get an error.

```
Adjacent operators are in non-associative precedence group 'DefaultPrecedence'
```

When our operator is used multiple times in a row, Swift doesn't know which side of the operator to evaluate first. On the lefthand side, we have:
""",
    timestamp: 206,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
`2` piped into `incr` makes sense, since `incr` takes an integer. On the righthand side, we have:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
incr |> square
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Piping our `incr` function into our `square` function makes less sense: `square` expects an integer, not a function.

We need to give Swift a hint as to which expression to evaluate first. One way to do this is to wrap the lefthand expression with parentheses so it evaluates first.
""",
    timestamp: 230,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
(2 |> incr) |> square // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This works but it's kind of messy. This is a pretty simple composition, but a more complicated example would require more nested parentheses and would be more difficult to follow. Let's give Swift a better hint.

Swift lets us define the associativity of an operator by using a precedence group. Let's define a precedence group for function application:
""",
    timestamp: 240,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
precedencegroup ForwardApplication {
  associativity: left
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We gave it a left associativity to ensure that the lefthand expression evaluates first.

Now we need to make sure our operator conforms to our precedence group.
""",
    timestamp: 260,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator |>: ForwardApplication
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can now get rid of our parentheses.
""",
    timestamp: 275,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr |> square // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This looks a lot like our earlier method version:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2.incr().square() // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),



  Episode.TranscriptBlock(
    content: "Operator interlude",
    timestamp: 294,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
We've solved the readability problem of nested functions, but we have a new problem: custom operators. Custom operators aren't very common. In fact, many of us avoid them because they have a bad reputation. A typical encounter with custom operators is within a subset of the idea: overloaded operators.

For example, in C++ you can't define new operators, but you can overload existing operators the language provides. If we were to write a vector library in C++, we could overload `+` to mean the sum of two vectors and we could overload `*` to mean the dot product of two vectors. Then again, `*` could mean the cross product of two vectors, so any choice to use `*` is going to require an opinion and lead to confusion.

We would never suggest overloading multiplication with function application:
""",
    timestamp: 294,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 * incr // What does this mean!?
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It would be very difficult to encounter this in a code base and understand what it means.

Luckily we don't have this problem here. We're using a brand new operator, `|>`, which Swift has no prior knowledge about. One may argue that an operator that Swift doesn't know about is an operator that a Swift developer doesn't know about, but in this case, we're looking to prior art: F#, Elixir, and Elm all use this operator in the same way. Swift engineers that are familiar with these languages are going to be familiar with the operator. It also has a nice shape! The pipe (`|`) evokes Unix, where we pipe the output of programs as input into other programs. The arrow also goes to the right (`>`), which gives us a nice left-to-right reading. Let's look back at our usage of this operator:
""",
    timestamp: 354,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Even if we're not familiar with this operator, we can kind of piece together what's going on here.

We're going to be using operators a lot in Point-Free, so let's make sure that we're responsible and justify the symbols that we introduce. There are a few boxes we'll want tick before we should introduce a new operator:

1. We shouldn't overload an operator with existing meaning with new meaning.

2. We should leverage prior art as much as possible and make sure our operator has a nice "shape" that evokes its semantics: in this case `|>` nicely describes piping a value forward into a function.

3. We shouldn't be inventing operators to solve very domain-specific problems. We should only introduce operators that can be used and reused in very general ways.

Our `|>` operator ticks all these boxes.
""",
    timestamp: 394,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "What about autocompletion?",
    timestamp: 458,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
While operators give us this readability, we're still missing a feature that methods have: autocomplete.

In Xcode, we can refer to a value, type a dot, and be presented with a whole list of methods we can call on this value.

<!-- TODO: image? -->

We can even type a few characters to limit the list to a subset of methods, including our `incr` method.

<!-- TODO: image? -->

This is really nice for code discoverability, and is a nice win for methods, but autocomplete really doesn't have anything to do with methods. Autocomplete works with our free functions, as well.

<!-- TODO: image? -->

This is at the top-level, though, so we lose some of the scoping we get with method completion. Still, there's nothing preventing our IDEs from understanding that, given a value and `|>`, should autocomplete functions that take that value as input. Hopefully this will get better with newer versions of Xcode.
""",
    timestamp: 458,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Introducing >>>",
    timestamp: 537,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, there's something in the free function world that isn't possible in the method world: function composition. Function composition is the ability to take two functions where the output of one matches the input of another so that we can glue them together and get a whole new function. In order to embrace this, we're going to introduce another operator:
""",
    timestamp: 537,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator >>>
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is known as the "forward compose" or "right arrow" operator. Let's define it:
""",
    timestamp: 565,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in
    g(f(a))
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
It's a function that's generic over three generic parameters: `A`, `B`, and `C`. It takes two functions, one from `A` to `B`, and one from `B` to `C`, and glues them together by returning a new function that passes the value in `A` to the function that takes `A`, and passing the result, `B`, to the function that takes `B`.

Now we can take our `incr` function and forward-compose it into our `square` function:
""",
    timestamp: 572,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
incr >>> square
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We now have a whole new function from `(Int) -> Int` that increments and then squares.

We can even flip it and have a new function that squares and then increments:
""",
    timestamp: 628,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
square >>> incr
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We can call these new functions the traditional way, with parentheses:
""",
    timestamp: 10 * 60 + 40,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
(square >>> incr)(3) // 10
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This doesn't read nicely, but we should be able to use our `|>` operator to help us with that:
""",
    timestamp: 10*60+47,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr >>> square
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Unfortunately we get another error:

```
Adjacent operators are in unordered precedence groups 'ForwardApplication' and 'DefaultPrecedence'
```

We're mixing two operators and Swift doesn't know which to use first. Our functions need to compose before we can we apply a value to them. We can't apply a value to one function and compose the result with another.

We can use precedence groups to solve this problem without parentheses. Let's define a new precedence group for function composition:
""",
    timestamp: 10*60+53,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We've specified that this group has a higher precedence than `ForwardApplication` so that it will be called first. Now we just need to make our arrow operator conform:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
infix operator >>>: ForwardComposition
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Now our operators play nicely together:
""",
    timestamp: 11*60+32,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr >>> square // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Before we get too excited about this new operator, let's make sure it ticks all the boxes that justify its existence.

1. This operator does not exist in Swift currently, so no chance of overloaded confusion.

2. This operator has a lot of prior art: Haskell, PureScript, and other languages with large functional programming communities. It also has a great shape that goes from left-to-right, matching our composition.

3. Does it solve a universal problem or does it solve a domain-specific problem? The operator has three generic types, which is quite general, and function composition is a _very_ universal thing.

Looks like `>>>` ticks all our boxes!
""",
    timestamp: 11*60+50,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "Method composition",
    timestamp: 12*60+59,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
What does function composition look like in the method world? If we want to combine this functionality, we have no other choice than to extend our type again and write another method that composes each method together.
""",
    timestamp: 12*60+59,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
extension Int {
  func incrAndSquare() -> Int {
    return self.incr().square()
  }
}
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In use, we can call the new method on a value:
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2.incrAndSquare() // 9
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This works, but there's a lot going on! We've written five lines of code, used four keywords, had to specify types, and when we zoom in on the part that we care about, `square().incr()`, it's such a small part of the overall picture. When composition takes this much boilerplate and effort, we have to ask ourselves: is it even worth it?

Meanwhile, function composition is a bite-sized piece that is wholly intact without any noise:
""",
    timestamp: 13*60+25,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
incr >>> square
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
You can further see the reuse by looking at the smallest valid components. If we delete parts of function composition and application, we still have a valid program.
""",
    timestamp: 14*60+11,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr >>> square
// every composed unit still compiles:
2 |> incr
2 |> square
incr >>> square
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
With methods, we can't refer to them or their composition without a value at hand.
""",
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
// valid:
2.incr().square()

// not:
.incr().square()
incr().square()
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Because of this, they're less reusable by default!

While it can feel like we generally work with methods, not functions, in Swift, we use functions every day and we may not even think about it.

One very common function that we use every day is the initializer! It's a global function that produces a value. And all of Swift's initializers are at our disposal for function composition. We can take a previous composition and forward-compose it into a `String` initializer.
""",
    timestamp: 14*60+50,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
incr >>> square >>> String.init
// (Int) -> String
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
And we can pipe a value through to produce a string result.
""",
    timestamp: 15*60+24  ,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
2 |> incr >>> square >>> String.init // "9"
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
Meanwhile, in the method world, we can't chain the result along to our initializer. We need to change the order in which we read things by wrapping the initializer around the methods.
""",
    timestamp: 15*60+43,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
String(2.incr().square())
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
In addition to there being a lot of free functions that initializers give us, there are also a ton of functions in the standard library that take free functions as input. On `Array`, we have a method called `map`:
""",
    timestamp: 15*60+51,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3].map
// (transform: (Int) throws -> T) rethrows -> [T]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This method takes a free function from the array's element type to another type `T` and transforms every element to return a new array of `T`s.

Typically, we pass an ad hoc function here. For example, we could increment and square:
""",
    timestamp: 16*60+1,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3].map { ($0 + 1) * ($0 + 1) } // [4, 9, 16]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
When we only work with methods, we seem to avoid reusability. We're working with functions, though, and we can reuse them directly.
""",
    timestamp: 16*60+26,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3]
  .map(incr)
  .map(square)
// [4, 9, 16]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
We didn't have to open up a new ad hoc function or specify arguments, and this is known as "point-free" style. When we define functions and specify arguments, even `$0`, these arguments are known as "points". Programming in the "point-free" style emphasizes a focus on functions and composition so that we don't have to even refer to the data being operated on. That's what this series was named after!

Mapping over our array with `square` before mapping over the resulting array with `incr` is equivalent to function composition! We can just map once and forward-compose `incr` into `square`:
""",
    timestamp: 16*60+39,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: """
[1, 2, 3].map(incr >>> square) // [4, 9, 16]
""",
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: """
This is really cool! We can see a relationship that our composition operator has with `map` that would have been difficult to see with methods. Here, `map` distributes over `>>>` composition: the composition of `map` twice over two functions is the composition of two functions over a `map`. There are a lot of patterns like this and we'll be exploring them in the future!
""",
    timestamp: 17*60+31,
    type: .paragraph
  ),



  Episode.TranscriptBlock(
    content: "What’s the point?",
    timestamp: 1114,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: """
Let's slow down and ask ourselves: _what's the point?_ Why are we doing all of this? In this episode we've introduced _two_ custom operators and polluted the global namespace with free functions. Why not continue to use the methods we know and love?

Hopefully the code we've written today has made a strong case for introducing functions into our workflows: functions compose in ways that methods cannot. Composing functionality with methods requires a lot more work and boilerplate, and trying to see that composition afterwards requires filtering that noise. With just a couple operators, we unlock a world of composition that we didn't have before, and we retain a lot of the readability we expect!

Swift also doesn't really have a "global namespace" that we need to be worried about. We can scope our functions in a lot of different ways:

- We can define functions that are private to a file.
- We can define functions that are static members on structs and enums.

- We can define functions that are scoped to modules. We can use several libraries that define the same function name, but qualify them by the library's module name.

I think it's safe to say: "Don't fear the function."

We're going to be using functions a lot on Point-Free. It's hard to imagine an episode in which we're not going to be using free functions. We'll be building very complex systems that under the hood are just functions and composition. It's really beautiful and exciting to see how it all works and how everything pieces together. Function composition will continue to help us see things that we couldn't have seen without it.

That's enough for this episode, though. Stay tuned!
""",
    timestamp: 18*60+33,
    type: .paragraph
  )
]
