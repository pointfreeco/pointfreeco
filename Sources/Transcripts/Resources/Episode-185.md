## Introduction

@T(00:00:05)
Over the next few episodes we will give a tour of [swift-parsing](https://github.com/pointfreeco/swift-parsing), which has just had a [significant release](https://github.com/pointfreeco/swift-parsing/releases/0.9.0) that introduces printing capabilities. Parsing and printing are two sides of the same coin, and yet libraries rarely if ever offer a unified solution to both problems.

@T(00:00:21)
Parsing is a surprisingly ubiquitous problem in programming. The goal of parsing is to turn nebulous blobs of data into well-structured data. Whenever we construct an integer or a URL from a string, we are technically doing parsing.

@T(00:00:33)
But every time we solve a parsing problem there is a corresponding printing problem waiting to be solved. This allows us to turn our well-structured data back into nebulous data, which allows us to serialize data to disk and send data over the network.

@T(00:00:46)
The Swift programming language ships with a couple of tools for parsing some basic string formats into proper data types, and even ships with some tools for formatting certain data types back into a string. But there is no unified, cohesive and composable solution to parsing and printing.

@T(00:01:02)
Until now. swift-parsing makes it possible for you to build your own unified parser-printers. It allows you to build large, complex parsers in a concise syntax, and if done carefully, you will magically get a printer out of it for free.

@T(00:01:16)
It’s honestly pretty amazing to see as it is not uncommon for one to build a parser for some domain, often in an ad-hoc manner by just splitting or manipulating strings, and then in a completely different ad-hoc manner write a printer to convert that domain back to a string. It’s then our responsibility to make sure that the logic scattered among parser and printer remain in sync so that any changes or bug fixes to one are made in the other. But unified parser-printers solve these problems and more.

@T(00:01:45)
In this next series of episodes we would like to give a tour of the library by showing how to build three parser-printers from scratch. But if you’re interested in the underlying design of the library we have [a back catalogue of episodes](/collections/parsing) that build the library from first principles that you may want to check out.

@T(00:02:03)
In this series we’ll start with a little demo inspired by one of last year’s [Advent of Code](https://adventofcode.com) challenges, then we’ll move onto a bank transaction parser-printer inspired by some of the new regex string processing that Apple is working on, and finally we will create a URL router that can be used to simultaneously power a web server and an iOS application’s API client.

## The library

@T(00:02:29)
Let’s start by opening up the package to see how it’s structured. If we hop to the `Package.swift` file we’ll see that it comes with two modules:

@T(00:02:38)
- First there’s `Parsing`, which is the main library that houses all of the parser-printer code.

@T(00:02:43)
- And there’s also something called `_URLRouting` which is an unreleased draft of a routing library built on top of parser-printers. For now it should be considered experimental, as its APIs are less stable than the rest of the library’s, but we will be taking a deeper look at the library later in this tour.

@T(00:03:03)
The package also has a playground, which is a great place to take the library for a spin and perform some experiments.

## Advent of Code

@T(00:03:10)
So, let’s start writing our first parser.

@T(00:03:13)
Last year on [day 13 of Advent of Code](https://adventofcode.com/2021/day/13) there was a fun problem that asked you to compute how dots on a piece of paper moved after performing a fold on the paper. The data for what dots are on the paper and where the fold is going to take place was given in a textual format:

```txt
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
```

@T(00:03:44)
This is the perfect problem for parsers. We want to process this nebulous blob of data into something well-structured, like first-class Swift structs and enums, and then we can write a function to compute where the dots move to as the folds are performed.

@T(00:03:58)
Let’s copy this text over to our playground and assign it to an input string that we want to parse:

```swift
let input = """
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"""
```

@T(00:04:08)
We will start with a quick domain modeling exercise where we cook up some types to represent the data we see in the textual format. The first thing that stands out is the comma-separated integers which represent the (x, y) coordinates of dots on the paper.

@T(00:04:22)
So, we can create a struct that holds onto an `x` and `y` field of type `Int` that represents a dot on the paper:

```swift
struct Dot {
  let x, y: Int
}
```

@T(00:04:27)
Then we can represent the folds first with an enum to describe the direction the fold is happening:

```swift
enum Direction {
  case x, y
}
```

@T(00:04:39)
And then a fold is the direction we are folding, as well as how far down the page or across the page we are folding:

```swift
struct Fold {
  let direction: Direction
  let position: Int
}
```

@T(00:04:54)
And finally we can create a data type that represents all of the instructions for the problem, which is the collection of dots on the page and the collection of folds that will be performed:

```swift
struct Instructions {
  let dots: [Dot]
  let folds: [Fold]
}
```

@T(00:05:11)
That completes the domain modeling exercise. Now we can start cooking up parsers for transforming the textual data into these data types.

@T(00:05:20)
We can attack this problem by incrementally describing how we want to parse small bits from the front of the input string. The way one does that with the library is to open up a parsing context using the `Parse` type:

```swift
Parse {

}
```

@T(00:05:41)
Inside this trailing closure we can list a bunch of parsers in order to run them one after another and collect their outputs into a tuple. This is the fundamental way we can break large parsing problems down into smaller parsing problems.

@T(00:05:58)
So we could start by first trying to parse an integer from the beginning of the input using a parser that ships with the library:

```swift
Parse {
  Int.parser()
}
```

@T(00:06:11)
`Int.parser()` is a parser that attempts to extra numeric digits from the beginning of the string in order to form an integer, and if it succeeds it consumes those characters and otherwise it fails.

@T(00:06:22)
And then after that we can try consuming the comma:

```swift
Parse {
  Int.parser()
  ","
}
```

@T(00:06:36)
And then after that we can try parsing another integer:

```swift
Parse {
  Int.parser()
  ","
  Int.parser()
}
```

@T(00:06:41)
And just like that we already have a parser that can extract two integers from a string that is formatted in a specific way. We can see this by assigning the parser to a variable and running it on some sample input:

```swift
let dot = Parse {
  Int.parser()
  ","
  Int.parser()
}

try dot.parse("6,10")   // (6, 10)
```

@T(00:07:06)
It seems to work!

@T(00:07:07)
So we have our first working parser, and it seems simple enough, but there is actually quite a bit happening behind the scenes so let’s break it down:

@T(00:07:14)
The `Parse` type acts as an entry point into what is known as “result builder” syntax. This is a feature of Swift that was launched alongside SwiftUI that gives us a nice syntax for building up complex, deeply nested values while preserving all of the static typing info.

@T(00:07:31)
Under the hood, the library’s result builder takes all of the parsers you list and forms a whole new parser whose job is to run each of the parsers, one after the other on the input, and bundle all of their outputs into a tuple.

@T(00:07:49)
However, you may notice that we are running 3 parsers on this input string and yet only get a tuple with 2 elements:

```swift
try dot.parse("6,10")   // (6, 10)
```

@T(00:07:56)
We would expect 3 based on the description we just gave.

@T(00:08:00)
However, the result builders do a little bit of extra work to make using parsers more ergonomic. Some parsers do not output anything of interest to us. They are just run to perform some logic and consume from the input. This is the case with the comma parser, whose job is just to make sure the input begins with a comma, and if it does it consumes the comma and if it doesn’t it fails to parse.

@T(00:08:24)
Such parsers return `Void` when run, which is the special type in Swift that has only one value and hence acts as a stand-in for a value that doesn’t matter. These `Void` values aren’t useful to us, and we certainly wouldn’t want to get a `Void` value in the middle of our tuple when parsing:

```swift
try dot.parse("6,10")   // (6, (), 10)
```

@T(00:08:44)
The result builders that power this syntax automatically discards any `Void` values that a parser may produce.

@T(00:08:54)
You may notice that we had to use `try` when invoking the `parse` method, and that’s because parsers have the option to fail by throwing errors. For example, what if we fed some bad data to the dot parser, such as omitting the second number after the comma:

```swift
do {
  try dot.parse("6,")
} catch {
  print(error)
}
```

```txt
error: unexpected input
 --> input:1:3
1 | 6,
  |   ^ expected at least 1 digit
```

@T(00:09:15)
This catches an error and prints a message to the console of what went wrong, and the library tries its best to give a nice description of what it expected.

@T(00:09:22)
There are two small improvements we can make to this parser already. First, we don’t actually expect to have to deal with negative numbers in our input, and in fact it would probably be an error if we received an input with a negative number. So we can switch to a slightly more efficient and precise parser which just consumes a number of digits from the beginning of the input:

```swift
let dot = Parse {
  Digits()
  ","
  Digits()
}
```

@T(00:09:56)
Further, producing tuples from a parser isn’t super ergonomic. We’d far prefer to have that tuple of data bundled up into our own data types, like the `Dot` struct we defined a moment ago.

@T(00:10:11)
The `Parse` type takes an optional argument that can be used to transform the tuple it extracts into another type, and if we pass the `Dot`'s initializer:

```swift
let dot = Parse(Dot.init) {
  Digits()
  ","
  Digits()
}
```

@T(00:10:30)
…this will pass along the two integers extracted straight to the `Dot` initializer, will now means we are parsing actual dot struct values rather than tuples:

```swift
do {
  try dot.parse("6,10")   // Dot(x: 6, y: 10)
} catch {
  print(error)
}
```

@T(00:10:52)
Next we can try parsing an entire collection of dots from the input by repeatedly running the `dot` parser until it fails. We do this by using the `Many` parser, which is specified by the element parser we want to run repeatedly, as well as the separator parser we want to run between each invocation of the element parser:

```swift
let dots = Many {
  dot
} separator: {
  "\n"
}
```

@T(00:11:31)
And already this can parse an entire array of dots from the input:

```swift
try dots.parse("""
6,10
0,14
9,10
0,3
""")
// [{x 6, y 10}, {x 0, y 14}, {x 9, y 10}, {x 0, y 3}]
```

@T(00:11:46)
We are already consuming a good portion of the input string. All that is left is parsing the fold instructions.

@T(00:11:57)
We can break this down just like we did for the dot. We can construct a parser that first consumes “fold along “, then a direction, then an equal sign, and then an integer for the position of the fold:

```swift
let fold = Parse {
  "fold along "
   // Direction?
  "="
  Digits()
}
```

@T(00:12:37)
The only tricky parser is figuring out how to parse the direction. We want to consume either an “x” or “y” string literal, and then transform that into a `Direction.x` or `Direction.y` enum value.

@T(00:12:50)
One way to do this is to use the `OneOf` parser, which allows you to specify multiple parsers and it will run one after another, but stop at the first succeeds and return that output. So, we could use `OneOf` to describe each case of the `Direction` enum:

```swift
let fold = Parse {
  "fold along "
   // Direction?
  OneOf {
    "x"
    "y"
  }
  "="
  Digits()
}
```

@T(00:13:29)
However, as we said before, the string literal parsers “x” and “y” are “void” parsers, which means their output is `Void`. We want to coalesce those void values to a `Direction` value, and we can do so by using the `.map` operator on parsers in order to transform the void output value to a new value:

```swift
let fold = Parse {
  "fold along "
   // Direction?
  OneOf {
    "x".map { Direction.x }
    "y".map { Direction.y }
  }
  "="
  Digits()
}
```

@T(00:14:16)
This does work and certainly gets the job done...

```swift
try fold.parse("fold along y=7")
// (.y, 7)
```

@T(00:14:28)
...but there’s a better way.

@T(00:14:30)
If we make it so our enum is represented by strings and conforms to `CaseIterable`, which means the compiler generates an array holding all cases for us, then we can immediately derive a parser from it with no work at all.

@T(00:14:46)
So let’s do that:

```swift
enum Direction: String, CaseIterable {
  case x, y
}
```

@T(00:14:56)
And now all of that messy, ad-hoc `OneOf` work can be squashed down into a single line:

```swift
let fold = Parse {
  "fold along "
  Direction.parser()
  "="
  Digits()
}
```

@T(00:15:08)
And it works just as it did before.

@T(00:15:15)
By utilizing this compiler-generated code, we're also less likely to introduce bugs, for example had we accidentally mapped a parser to the wrong value.

@T(00:15:41)
Notice that running the parser products a tuple with 2 elements even though we are running 4 parsers. This is because the result builder has automatically discarded the two `Void` values produced by the `"fold along "`" and `"="`" parsers.

@T(00:15:54)
And just like before we can bundle up this tuple of values into the `Fold` data type by passing its initializer to the `Parse` entry point:

```swift
let fold = Parse(Fold.init) {
  "fold along "
  Direction.parser()
  "="
  Digits()
}
```

@T(00:16:09)
And now we are parsing `Fold` values rather than tuples:

```swift
try fold.parse("fold along y=7")
// Fold(direction: .y, position: 7)
```

@T(00:16:16)
And if the input is malformed we also get a nice error message:

```swift
do {
  try fold.parse("fold along z=7")
} catch {
  print(error)
}
```

```txt
error: unexpected input
--> input:1:12
1 | fold along z=7
  |            ^ expected "x"
  |            ^ expected "y"
```

@T(00:16:29)
Just like with dots, we can parse many folds using the `Many` parser:

```swift
let folds = Many {
  fold
} separator: {
  "\n"
}
```

@T(00:16:46)
And finally we can bring everything together by parsing an `Instructions` value that first parses all the dots it can, then parses the double newline separator and then finally parsers as many folds as it can:

```swift
let instructions = Parse(Instructions.init) {
  dots
  "\n\n"
  folds
}
```

@T(00:17:25)
And amazingly we can now process the full input that we get from Advent of Code:

```swift
try instructions.parse(input)
// Instructions(
//   dots: [{x 6, y 10}, …],
//   folds: [{y, position 7} …]
// )
```

@T(00:17:46)
In just a few dozen lines we have been able to parse the Advent of Code challenge input into first class Swift data types, and now we are perfectly set up to complete the challenge by writing a function that computes where the dots move to after performing the folds to the paper.

## Printing

@T(00:18:05)
But the really amazing thing is that with just a few changes to this parser we can almost magically turn it into a printer.

@T(00:18:13)
A printer can be thought of as the “inverse” of parsing. It should undo all the work that a parser does to transform a nebulous blob of data into something well-structured by turning that well-structured data back into a nebulous blob.

@T(00:18:24)
And when we say printing should be the “inverse” of parsing we mean it. If you parse some input to obtain some output, and then turn right back around and print that output, you should obtain the input you started with. And similarly, if you print some output to some input and then try right away to parse that input, you should obtain the same output that you started with.

@T(00:18:43)
We call this property “round-tripping”, and by making sure that all of our tiny parser-printers satisfy this property we can have greater confidence that when we piece them together to form large, complex parser-printers that they behave as we expect.

@T(00:18:56)
So let’s see what it takes to make the instructions parser into a printer…

@T(00:19:03)
So, if the `instructions` parser we defined a moment ago was also a printer, it would mean we could invoke a `print` method on it, and pass it an `Instructions` value in order to get back a string input that Advent of Code could have sent to us. In fact, we should be able to invoke it on the output we got from parsing:

```swift:2:fail
let output = instructions.parse(input)
try instructions.print(output)
```

@T(00:19:21)
If only if it were that easy.

@T(00:19:23)
Not all parsers are necessarily printers right away. Sometimes we need to do a little extra work to make them printers, and that shouldn’t be too surprising because parser-printers are a bidirectional process for turning unstructured data into structured data and back, but when constructing parsers we are only thinking of a single direction, that of transforming unstructured into structured data.

@T(00:19:44)
Luckily most of the parsers that ship with the library are also printers, and so many times right out of the box you can print with a parser you construct without doing anything more. And when that is not the case the library comes with a bunch of tools that cover the most common situations of needing to upgrade one directional transformations into bidirectional transformations.

@T(00:20:03)
For example, the `dot` parser before we enhanced it to bundle the tuple of integers into a `Dot` struct was already a printer and we didn’t even know it. This means you can print a tuple of integers into a string of comma-separated integers:

```swift
let dotTuple = Parse {
  Digits()
  ","
  Digits()
}

dotTuple.print((3, 1))   // "3,1"
```

@T(00:20:36)
We can even use the `ParsePrint` entry point into result builder syntax to make it very clear what we want to do:

```swift
let dotTuple = ParsePrint {
  Digits()
  ","
  Digits()
}
```

@T(00:20:44)
No extra work needed to be done because all of the parsers involved in this expression are also parser-printers, and so everything just works for free. The `Digits` parser is a parser-printer, the `","` parser is a parser-printer, and the parser that is being constructed in the background to support result builder syntax for running all three of these parsers, one after another, is also a parser-printer. Since everything involved in this expression is a parser-printer it means the entire composed thing is also a parser-printer.

@T(00:21:12)
However, the moment we re-introduce the transformation for bundling the tuple of integers into a `Dot` struct we lose printability:

```swift:1:fail
let dot = ParsePrint(Dot.init) {
  Digits()
  ","
  Digits()
}
```

@T(00:21:23)
The reason this is happening is because the `Dot` initializer is a one directional transformation that can turn a tuple of two integers into a `Dot` value. This works great for parsing because the parser extracts out the two integers from the input string and then we pass that along to the `Dot` initializer. But, this process is not printer-friendly.

@T(00:21:41)
Remember that printing is the inverse of parsing, and so goes in the opposite direction. We want to print a `Dot` value to a string, and to do so we need to first transform the `Dot` value into a tuple of two integers, and then each of those integers can be handed to the `Digits` printer.

@T(00:21:57)
So, to transform the tuple of integers into a `Dot` in a printer-friendly way, we must actually supply transformations that go in both directions: one from tuples to `Dot`s and another from `Dot`s to tuples. In fact, the compiler error message is even giving us a hint about this:

> Error: Type '(Int, Int) -> Dot' cannot conform to 'Conversion’

@T(00:22:18)
Conversions are how the library expresses the idea of a bidirectional transformation between two types, and the `ParsePrint` argument forces you to pass a conversion rather than a plain function in order to preserve printability.

@T(00:22:30)
The library ships with a tool that allows you to easily derive a conversion between two integers and the `Dot` data type. It’s called `.memberwise` and can turn `Dot`'s default, memberwise initializer into a conversion:

```swift
let dot = ParsePrint(.memberwise(Dot.init)) {
  Digits()
  ","
  Digits()
}
```

@T(00:22:45)
This now compiles and allows us to print actual `Dot` values rather than tuple values:

```swift
dot.print(Dot(x: 3, y: 10))   // "3,10"
```

@T(00:22:57)
So now `dot` is a parser-printer and we only had to make one small change, that of using a `.memberwise` conversion rather than a function.

@T(00:23:06)
So, now the `dot` parser is also a parser-printer. And the moment that happened the `dots` parser magically also became a parser-printer:

```swift
try dots.print([
  Dot(x: 3, y: 1),
  Dot(x: 2, y: 0),
  Dot(x: 1, y: 4),
])
// "3,1\n2,0\n1,4"
```

@T(00:23:28)
This happened because the `Many` parser becomes a printer if all the parsers you supply to it are also printers.

@T(00:23:42)
We are getting really close to making all of our parsers into parser-printers. Next we have the `fold` parser, which can be made into a parser-printer by just using the `.memberwise` initializer again:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
  "fold along "
  Direction.parser()
  "="
  Digits()
}
```

@T(00:23:57)
And with that the `fold` parser is already a parser-printer:

```swift
try fold.print(Fold(direction: .x, position: 5)
// "fold along x=5"
```

@T(00:24:11)
Because all of the parsers in `fold` are also parser-printers, including the direction parser.

@T(00:24:17)
The `folds` parser is now a parser-printer, because all the parsers in the `Many` are parser-printers.

@T(00:24:22)
Which means that all that is left is the `instructions` parser, which can be made into a parser-printer by using another `.memberwise` conversion:

```swift
let instructions = ParsePrint(.memberwise(Instructions.init)) {
  dots
  "\n\n"
  folds
}
```

@T(00:24:32)
And just like that we can now print and entire set of instructions back into the string format that defines the instructions:

```swift
try instructions.print(output)   // "6,10\n0,14\n…"
```

@T(00:24:42)
It even printed the _exact_ input string we started with:

```swift
try instructions.print(output) == input   // true
```

@T(00:24:46)
This is pretty amazing. Not only did we get a parser up and running pretty quickly with just a handful of lines of code, but we were then able to instantly convert it to a parser-printer with just 3 small changes to the code. Each change we simply had to swap out using the `Parse` entry point with the `ParsePrint` entry point, and swap out the function transformation with a `.memberwise` conversion.

@T(00:25:11)
That’s all it took and now, almost as if by magic, we can parse and print with the exact same code. The parsing and printing code are linked together in a fundamental way so that if you need to fix a bug in one you are immediately confronted with what it means to fix in the other. You do not need to main two separate chunks of code that independently do parsing and printing, and you don’t have to remember to keep changes to them in sync with each other.

@T(00:25:35)
In fact, suppose for a moment that the textual format of the instructions changed at some point. Rather than saying “fold along“ they want to spice things up with some emoji:

```txt
fold ➡️ x=1
```

@T(00:25:46)
If our parser and printer code was separate we would have to make sure to fix this in two different places. But since we have a unified parser-printer we can just fix it in a single spot:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
  "fold ➡️ "
  Direction.parser()
  "="
  Digits()
}
```

## Performance

@T(00:26:17)
It’s amazing to see how we could build a unified parser-printer with small units that ship with the library, and because of the round-tripping property we can be confident that our large, complex parser-printer works as expected. And whenever we need to update the logic or fix a bug there is only one single place to do so.

@T(00:26:36)
So we’ve now seen how we can tune our parsers so that they can also be printers.

@T(00:26:41)
Let’s round out this episode by describing how we can further tune our parsers for performance. Currently our parsers work on a high-level representation of strings, but it’s possible to drop down to a lower-level representation to squeeze out some performance. So, let’s take a look at that.

@T(00:26:58)
Currently, all of the parsers we’ve built work on the level of substrings, which is a dedicated type in Swift that allows you to efficiently hold onto a portion of some larger string. It’s essentially just a pair of indices, the start and end, that point to characters in some other string. This makes substrings extremely cheap to copy around since you are just copying these indices, not the full storage of the string. And it makes it efficient to drop characters from the beginning since it can just move the index forward.

@T(00:27:28)
For example, we could create a really large string of thousands of characters:

```swift
let string = String(repeating: "A", count: 10_000)
```

@T(00:27:38)
And then get access to a view of a subset of this string by dropping a few of the first and last characters:

```swift
let substring = string.dropFirst(10).dropLast(10)
```

@T(00:27:51)
This `substring` value isn’t a whole new string with 20 less characters than `string`. Rather it just consists of a pointer to the original backing string, as well as start and end indices that define what subset of the original string we are focused on.

@T(00:28:16)
Although substrings are a lot more efficient to deal with than strings, they still have some performance problems, but for good reason. Strings and substrings are collections of characters, and a character is an extended grapheme cluster which closely resembles an actual visible character on the screen.

@T(00:28:31)
So, when we see a string like `"café"`" we just see that the “e” has an accent on it, and that is all. However, the “e” with an acute accent can be represented in two different ways. Either as a single unicode character:

```swift
"\u{00E9}"   // "é"
```

@T(00:28:55)
Or as an “e” next to a combining character that represents the acute accent:

```swift
"e\u{0301}"   // "é"
```

@T(00:29:12)
When dealing with strings we don’t have to worry about these differences because Swift squashes it all down for us into one normalized representation. In fact, these characters, as strings, are equal even though they look quite different:

```swift
"\u{00E9}" == "e\u{0301}"   // true
```

@T(00:29:27)
The work that Swift is doing to normalize these representations is really nice and makes working with strings much easier, but it comes at a performance cost. It means that characters are variable width, which means that many operations that work on collections of characters, such as dropping the first `n` elements, become O(n) rather than the O(1) we’d hope for.

@T(00:29:46)
One can opt out of the niceties of unicode normalization in order to gain some performance by dropping down to a lower-level representation of strings in Swift known as `UTF8View`s. Like substring it is a view into some string defined by start and end indices, but unlike substrings it is focused on the collection of UTF-8 bytes that make up the string. Collections of bytes are much simpler to traverse over, and so many operations become faster O(1) algorithms.

@T(00:30:14)
However, with better performance comes more complexity. For example, the two different representations of “e” with acute accent that we considered a moment ago are not equal as `UTF8View`s. If we just access the `UTF8View` for each string the playground does some work to show something nice:

```swift
"\u{00E9}".utf8    // "é"
"e\u{0301}".utf8   // "é"
```

@T(00:30:33)
But that is actually hiding the true story from us. If we convert the `UTF8View` collection to a plain array we will see what is really happening:

```swift
Array("\u{00E9}".utf8)    // [195, 169]
Array("e\u{0301}".utf8)   // [101, 204, 129]
```

@T(00:30:44)
And these sequences are not equal:

```swift
"\u{00E9}".utf8.elementsEqual("e\u{0301}".utf8)   // false
```

@T(00:30:56)
Even though as a sequence of characters they are equal:

```swift
"\u{00E9}".utf8.elementsEqual("e\u{0301}".utf8)   // false
"\u{00E9}".elementsEqual("e\u{0301}")             // true
```

@T(00:31:03)
So, these are the tradeoffs to working with `Substring`s versus `UTF8View`s. One is simpler to use but less performant, the other is more performant but also more complex to use.

@T(00:31:12)
Luckily for us, swift-parsing makes it easy to work on any string abstraction level you want because it is fully generic over the type of input it operates on. This means you can write your parsers on the substring level if you want the simplicity and don’t need the performance, or you can write your parsers on the `UTF8View` level if you really need the performance. You can even temporarily leave one abstraction level in the middle of your parsing to work on another abstraction level.

@T(00:31:36)
Let’s take a look at how to convert our instructions parser to work on the level of UTF8. We’re going to create a new lexical scope to work in so that we can copy-and-paste our previous parsers without causing compiler errors:

```swift
do {
  …
}
```

And in a moment we will even benchmark these new parsers.

@T(00:32:12)
We can start by looking at the `dot` parser:

```swift
let dot = ParsePrint(.memberwise(Dot.init)) {
  Digits()
  ","
  Digits()
}
```

@T(00:32:15)
This is currently inferred to be a substring parser because the string literal `","`" is a substring, and then `Digits` has an initializer that allows it to work on substrings.

@T(00:32:28)
We can make one small change to this parser to instantly turn it into a `UTF8View` parser:

```swift
let dot = ParsePrint(.memberwise(Dot.init)) {
  Digits()
  ",".utf8
  Digits()
}
```

@T(00:32:37)
The `UTF8View` type is a parser just as the `String` type is a parser, and now by type inference the `Digits` type is constructed via a different initializer that knows how to work with UTF-8. That’s all it takes.

@T(00:33:05)
In fact, all of our parsers are this easy to convert over. Like the `dots` parser just needs to make sure to use UTF-8 for the separator and terminator parsers:

```swift
let dots = Many {
  dot
} separator: {
  "\n".utf8
}
```

@T(00:33:16)
And just like that we have a dots parser that works on the level of UTF-8 code units.

@T(00:33:18)
The `fold` parser is just as simple:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
  "fold ➡️ ".utf8
  Direction.parser()
  "=".utf8
  Digits()
}
```

Again, the `Direction.parser()` and `Digits` parser all leverage type inference to choose a different overload that makes them work with UTF-8 rather than substrings.

@T(00:33:24)
And finally the `folds` parser can be made to work on UTF-8:

```swift
let folds = Many {
  fold
} separator: {
  "\n".utf8
}
```

@T(00:33:30)
That’s all it takes. It almost seems too easy, and for this example it was incredibly easy, but it is worth noting that if we were doing more complex parsing, especially if we needed to worry about strings that have multiple representations as UTF-8 code units, such as the “e” with an acute accent.

@T(00:33:50)
Luckily for us we don’t have any of that in our current parser, but let’s for a moment suppose we didn’t know 100% for certain that there was only one representation of “➡️” as a collection of bytes. Perhaps there’s two. This means that since we are hardcoding one of those representations in the parser like so:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
  "fold ➡️ "
  Direction.parser()
  "=".utf8
  Digits()
}
```

…that this parser will not recognize the other representation even though visually it looks exactly the same. It’s just that at the byte level they are different.

@T(00:34:28)
We could of course use `OneOf` to try parsing each of the types of representations:

```swift
OneOf { "➡️".utf8; "➡️".utf8; … }
```

@T(00:34:41)
But that still requires us to know all the ins and outs of unicode to be certain we got all of the representations.

@T(00:34:50)
Better would be if we could temporarily leave the `UTF8View` world, travel to the `Substring` world, where unicode normalization is taken care of us automatically, run our parser, and then return back to the `UTF8View` world. And this is absolutely possible.

@T(00:35:08)
We can use the `From` parser-printer to temporarily leave one world to work in another world, and we do so by supply a conversion, in this case a conversion from `UTF8View` to `Substring`, which the library helpfully ships with. And then inside the `From` parser-printer’s builder context we can run a parser on the `Substring` level:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
   // OneOf { "➡️"; "➡️"; … }
  From(.substring) { "fold ➡️ " }
  Direction.parser()
  "=".utf8
  Digits()
}
```

@T(00:35:49)
With that one small change we are parsing only the small "fold ➡️ " segment as a substring, and hence taking a small performance hit, and then everything else is parsed as a `UTF8View`, and so can be quite performant.

@T(00:36:05)
If we wanted to be really pedantic we could even just parse the “➡️” character on the the level of UTF- 8 and leave everything else as substring:

```swift
let fold = ParsePrint(.memberwise(Fold.init)) {
  "fold "
  From(.substring) { "➡️ " }
  Direction.parser()
  "=".utf8
  Digits()
}
```

@T(00:36:17)
Let’s first undo this `From(.substring)` change because it isn’t actually doing much for us. As far as we know there is only one representation of “➡️” as a collection of bytes.

@T(00:36:31)
But, is the performance gain really that significant when using `UTF8View`? Let’s benchmark to find out!

@T(00:36:42)
We'll copy-and-paste all of our parsers over to the library's benchmarks target. We'll do it in the `main.swift` file of the executable, do a little clean up, and switch our active target to the benchmarks.

@T(00:37:12)
And then we'll stub out two benchmarks that test the substring parser and the `UTF8View` parser:

```swift
…  // Domain models, like Dot, Direction, Fold, and Instructions

let input = …  // Advent of Code input string

benchmark("AoC13: Substring") {
  … // Substring parsers
}

benchmark("AoC13: UTF8View") {
  …  // UTF8View parsers
}
```

@T(00:38:01)
In each benchmark we will exercise the appropriate parser with a precondition that minimally asserts that we got what we expected:

```swift
benchmark("AoC13: Substring") {
  … // Substring parsers

  let output = try instructions.parse(input)
  precondition(output.dots.count == 18)
}

benchmark("AoC13: UTF8View") {
  …  // UTF8View parsers

  let output = try instructions.parse(input)
  precondition(output.dots.count == 18)
}
```

@T(00:38:42)
Running the benchmark suite we see that amazingly the `UTF8View` parser is already over twice as fast as the substring parser:

```txt
running AoC13: Substring... done! (1464.53 ms)
running AoC13: UTF8View... done! (1981.64 ms)

name             time         std        iterations
---------------------------------------------------
AoC13: Substring 13083.000 ns ±   9.09 %      98967
AoC13: UTF8View   5125.000 ns ±   6.91 %     274324
Program ended with exit code: 0
```

@T(00:39:02)
Both are actually quite fast, but it’s amazing to see that with just a few small changes we are able to parse on a lower level representation of strings and eke out some extra performance.

## Next time: swift-parsing vs. Apple's Regex DSL

@T(00:39:13)
So, that’s the basics of writing your first parser with our library, and then making a few small changes in order to magically turn it into a printer and tune its performance.

@T(00:39:24)
And so everything looks really cool, but also, this little Advent of Code parsing problem is only barely scratching the surface of what the library is capable of. Let’s tackle something a little meatier, and even better it will give us an opportunity to explore a little bit of the experimental string processing APIs that Apple is polishing up right as we speak.

@T(00:39:43)
If you follow the [Swift forums](https://forums.swift.org) closely you may have noticed there have been a lot of pitches and discussions about the future of string processing in Swift, primarily focused on regular expressions. There is even a result builder syntax for building regular expressions in a nice, DSL style, which is great because regular expressions tend to be very terse and cryptic.

@T(00:40:03)
Regular expressions, or “regex” for short, are a super compact syntax for describing patterns that you want to try to match on strings in order to capture substrings. It is an extremely powerful, though terse, way to search strings for complex patterns, and they have been around in computer science for a very, very long time.

@T(00:40:21)
Let’s take a look at an example from some of Apple’s pitches so that we can understand how regexes works in a particular situation, what Apple’s tools bring to the table, and how we can approach the same problem using swift-parsing...next time!.
