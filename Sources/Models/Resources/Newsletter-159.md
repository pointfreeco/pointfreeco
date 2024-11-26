Advent of Code is here! Each day's challenge starts with parsing input data, a crucial step 
before tackling the real problem. With our [Swift Parsing][parsing-gh] library, you can effortlessly 
transform the nebulous text into first-class Swift data types, allowing you to focus on 
solving the real problem at hand!

Join us for a quick overview of how to use the Parsing library, as well as some examples of parsing
input data from 2023's Advent of Code.

# The basics of Swift Parsing

Creating a parser with the Parsing library amounts to composing together simpler parsers that the
library provides in order to form a larger, more complex parser. As an example, suppose you have
a string of data that describes the properties of a user:

```swift
let input = """
1,Blob,true
2,Blob Jr.,false
3,Blob Sr.,true
"""
```

You want to parse this nebulous string into an array of `User` types in Swift. A good first step is
to define the Swift data types that you would like to parse into. In this case, a `User` is a
struct with an integer ID, string name, and boolean for whether or not they are an admin:

```swift
struct User {
  var id: Int 
  var name: String 
  var isAdmin: Bool
}
```

Rather than trying to parse the entire multiline string all at once, let's focus on a smaller, more
tractable problem. In particular, let's first try to parse just one single line from the input.

We can do so by introducing a new type that conforms to the `Parser` protocol:

```swift
struct UserParser: Parser {
}
```

It has one requirement, which is a `body` property where we can specify the input the parser 
consumes and its output:

```swift
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
  
  }
}
```

We are using `Substring` for the input because it has an efficient API for consuming 
characters without allocating brand new strings. This `body` property is where we can start listing
the simpler parsers we want to use to consume little bits of data from the input.

> Note: It is also possible to use lower level string representations such as `UTF8View`
> and `UnicodeScalarView`. Working on those representations can be a lot more performant, but you
> have to take extra care for correctness.

For example, we can start by parsing an integer from the front of the input. This can be done by
using the `Int.parser()` that comes with the library:

```swift:3
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Int.parser()
  }
}
```

If this parser succeeds it will consume the integer from the beginning of the string, which means
the next character will be a comma. We can next parse that character:

```swift:4
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Int.parser()
    ","
  }
}
```

Next we want to consume all characters up until the next comma because that will be the name of the
user. We can do so using the `Prefix` parser that comes with the library:

```swift:5
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Int.parser()
    ","
    Prefix { $0 != "," }
  }
}
```

Once that parser consumes as much as it can we will have another comma left at the front of the 
input, and so let's parse and consume that character:

```swift:6
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Int.parser()
    ","
    Prefix { $0 != "," }
    ","
  }
}
```

Next we will parser the boolean at the end of the line using the `Bool.parser()` that comes with 
the library:

```swift:7
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Int.parser()
    ","
    Prefix { $0 != "," }
    ","
    Bool.parser()
  }
}
```

That is the basics of parsing an integer, then a comma, then a string up to the next comma, then
another comma, and finally a boolean. However, this parser currently outputs a tuple of that data,
rather than the `User` type like we specified:

> Error: Return type of property 'body' requires the types '(Int, Substring, Bool)' and 'User' be 
> equivalent

In order to bundle this tuple of data into an actual `User` we can wrap the parser in the
`Parse` parser:

```swift:3,9
struct UserParser: Parser {
  var body: some Parser<Substring, User> {
    Parse(User.init) {
      Int.parser()
      ","
      Prefix { $0 != "," }
      ","
      Bool.parser()
    }
  }
}
```

And now this compiles, and it is capable of parsing a single line of text:

```swift
try UserParser().parse("1,Blob,true")  // User(id: 1, name: "Blob", isAdmin: true)
```

Next we want to run this parser many times on a multiline input string. To do this we will first
define a new type that conforms to `Parser` that represents parsing many users:

```swift
struct UsersParser: Parser {
  var body: some Parser<Substring, [User]> {
  
  }
}
```

Then we can use the `Many` parser that comes with the library to express that we want to run a
single parser many times on an input, and we can even describe the separator in the input. In this
case it is a newline:

```swift:3-7
struct UsersParser: Parser {
  var body: some Parser<Substring, [User]> {
    Many {
      UserParser()
    } separator: {
      "\n"
    }
  }
}
```

And that is all it takes to parse the nebulous input string into first class Swift data types:

```swift
let input = """
1,Blob,true
2,Blob Jr.,false
3,Blob Sr.,true
"""

try UsersParser().parser(input)  // [User(id: 1, …), User(id: 2, …), User(id: 3, …)]
```

That is the basics of crafting complex parsers with the Parsing library. There are more tricks
to know, but you can read the documentation and look through the [examples][example-parsers]
to learn more. For now, let's take a look at a few of last year's Advent of Code problems and see
how the Parsing library could have helped.

[example-parsers]: https://github.com/pointfreeco/swift-parsing/tree/main/Sources/swift-parsing-benchmark

# Examples from past Advents of Code

Here is a detail explanation of how to attack some of the parsing problems from past Advents of
Code:

## 2023, Day 4

Day 4 of 2023's Advent of Code asks you to process input data that looks like this:

```text
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

Each line corresponds to a card shown to you with two sets of numbers. The first set of numbers,
those before the "|" are the "winning" numbers, and the rest are your numbers.

It doesn't really matter what this data represents in the context of the problem. We just want to
parse this string into some first class Swift data types so that we can more easily solve the 
problem.

We will begin by defining a data type `Card` that represents all of the data of a card:

```swift
struct Card {
  var number: Int 
  var winningNumbers: Set<Int>
  var yourNumbers: Set<Int>
}
```

Note that we are using a `Set` instead of an `Array` here because part of the problem involves
taking the intersection of the two collections of numbers. Intersections are easier to do with sets,
and so it would be best to start with that data type from the beginning. 

Next we will define a parser that parse a whitespace-separated list of numbers into a set:

```swift
struct NumbersParser: Parser {
  var body: some Parser<Substring, Set<Int>> {
  }
}
```

We can again use the `Many` parser to run an `Int.parser()` repeatedly, but this time we will also
use the `Whitespace` parser as the separator since there can sometimes be multiple spaces between
numbers do to how the data is aligned:

```swift:3-7
struct NumbersParser: Parser {
  var body: some Parser<Substring, Set<Int>> {
    Many {
      Int.parser()
    } separator: {
      Whitespace()
    }
  }
}
```

However this does not compile because our parser is currently producing an array of integers, not
a set:

> Error: Return type of property 'body' requires the types '[Int]' and 'Set<Int>' be 
> equivalent

This is happening because by default the `Many` parser produces an array. However, it is possible
to configure `Many` to accumulate its results into any kind of data structure, not just arrays.

For example, we can accumulate the integers into a set like so:

```swift:3-9
struct NumbersParser: Parser {
  var body: some Parser<Substring, Set<Int>> {
    Many(into: Set<Int>()) {
      $0.insert($1)
    } element: {
      Int.parser()
    } separator: {
      Whitespace()
    }
  }
}
```

The first argument specifies the type of data structure to be accumulated into, and the second
argumnet is a closure that is invoked with each result obtained from the element parser.

With that done we can define a `CardParser` for processing an entire line from the input string.
We can first parse the string "Card " (note the trailing space), then an integer, and then a colon:

```swift
struct CardParser: Parser {
  var body: some Parser<Substring, Card> {
    Parse(Card.init) {
      "Card "
      Int.parser()
      ":"
    }
  }
}
```

After the colon there can be one or more spaces due to how the input aligns its numbers. To handle
this we can use the `Whitespace` parser, which consumes multiple whitespace characters:

```swift:7
struct CardParser: Parser {
  var body: some Parser<Substring, Card> {
    Parse(Card.init) {
      "Card "
      Int.parser()
      ":"
      Whitespace()
    }
  }
}
```

Next we can consume a set of numbers, followed by a space and "|" character, followed by more 
whitespace and then another set of numbers:

```swift:8-11
struct CardParser: Parser {
  var body: some Parser<Substring, Card> {
    Parse(Card.init) {
      "Card "
      Int.parser()
      ":"
      Whitespace()
      NumbersParser()
      " |"
      Whitespace()
      NumbersParser()
    }
  }
}
```

And then finally we can parse any number of cards by using the `Many` parser:

```swift
struct CardsParser: Parser {
  var body: some Parser<Substring, [Card]> {
    Many {
      CardParser()
    } separator: {
      "\n""
    }
  }
}
```

And that is all it takes. We now have a single parser that is capable of turning the nebulous 
input data into well-structured Swift data types:

```swift
let input = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

try CardsParser().parse(input)  // [Card(number: 1, …),…]
```

## 2023, Day 2

On day 2 of 2023's Advent of Code we are presented with some sample input data that looks like
so:

```text
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
```

Each line represents a "game", and multiple sets of cube reveals. For game 1 there are 3 cube 
reveals, each separated by a semicolon:

1.) The first reveal is 3 blue and 4 red.
1.) The second reveal is 1 red, 2 green and 6 blue.
1.) And the third reveal is just 2 green.

The only colors that can be revealed are red, blue and green, and each cube reveal can specify any 
number of colors.

The challenge is to compute which of these games were valid considering that the bag of cubes only
held 12 red cubes, 13 green cubes, and 14 blue cubes. However, before we can even get to the point
of solving this challenge we first need to parse this data into a friendlier format so that we
can perform a computation on the data.

We will start by defining the Swift data types that we want the parser to produce. A simple one
is an enum for the 3 possible colors:

```swift
enum CubeColor: String, CaseIterable { case blue, green, red }
```

Enums that are raw representable and `CaseIterable` get a special parser defined for them that
can parse a string into an enum case: `CubeColor.parser()`.

Next we will define a `CubeReveal` type that represents how many blue, green or red cubes were 
revealed:

```swift
struct CubeReveal {
  var blue = 0
  var green = 0
  var red = 0
}
```

And finally we will define a `Game` type that has the number of the game along with a collection
of cube reveals:

```swift
struct Game {
  var number: Int
  var cubeReveals: [CubeReveal] = []
}
```

We are now ready to start parsing our input data:

```swift
let input = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""
```

Just as we did with the users parser above, we will start by parsing something much simpler. In
this case, we will parse a single `CubeReveal`:

```swift
// "3 blue, 4 red" -> CubeReveal(blue: 3, red: 4)
struct CubeRevealParser: Parser {
  var body: some Parser<Substring, CubeReveal> {
  }
}
```

We can first parse the integer for the number of cubes, followed by a space, and then the cube
color:

```swift:4-6
// "3 blue, 4 red" -> CubeReveal(blue: 3, red: 4)
struct CubeRevealParser: Parser {
  var body: some Parser<Substring, CubeReveal> {
    Int.parser()
    " "
    CubeColor.parser()
  }
}
```

Then we want to run this many times to parse as many colors are present, each separated by a comma
and space:

```swift:4,8-10
// "3 blue, 4 red" -> CubeReveal(blue: 3, red: 4)
struct CubeRevealParser: Parser {
  var body: some Parser<Substring, CubeReveal> {
    Many {
      Int.parser()
      " "
      CubeColor.parser()
    } separator: {
      ", "
    } 
  }
}
```

This is getting close, but the data types don't match up yet:

> Error: Return type of property 'body' requires the types '[(Int, CubeColor)]' and 'CubeReveal' be 
> equivalent

We are currently parsing an array of tuples of integers and cube colors, and we somehow need to
transform that into a `CubeReveal` which has a separate integer field for each color. This 
transformation is quite simple to do, and can be done as a special initializer on `CubeReveal`:

```swift:3-11
struct CubeReveal {
  …
  init(_ quantityAndColors: [(Int, CubeColor)]) {
    for (quantity, color) in quantityAndColors {
      switch color {
      case .blue:  blue = quantity
      case .green: green = quantity
      case .red:   red = quantity
      }
    }
  }
}
```

And we can now use this initializer with the `Parse` parser to finish the cube reveal parser:

```swift:4,12
// "3 blue, 4 red" -> CubeReveal(blue: 3, red: 4)
struct CubeRevealParser: Parser {
  var body: some Parser<Substring, CubeReveal> {
    Parse(CubeReveal.init) {
      Many {
        Int.parser()
        " "
        CubeColor.parser()
      } separator: {
        ", "
      } 
    }
  }
}
```

Next let's make a `GameParser` that is capable of parsing one single line from the input:

```swift
// "Game 1: 3 blue, 4 red" -> Game(number: 1, cubeReveals: [CubeReveal(blue: 3, red: 4)])
struct GameParser: Parser {
  var body: some Parser<Substring, Game> {
  }
}
```

We can start by parsing the "Game " string from the beginning of the input, and then the game
number followed by a colon and space:

```swift:4-6
// "Game 1: 3 blue, 4 red" -> Game(number: 1, cubeReveals: [CubeReveal(blue: 3, red: 4)])
struct GameParser: Parser {
  var body: some Parser<Substring, Game> {
    "Game "
    Int.parser()
    ": "
  }
}
```

Then we will consume as many cube reveals from the line as we can, each separated by a semicolon
and a space:

```swift:7-11
// "Game 1: 3 blue, 4 red" -> Game(number: 1, cubeReveals: [CubeReveal(blue: 3, red: 4)])
struct GameParser: Parser {
  var body: some Parser<Substring, Game> {
    "Game "
    Int.parser()
    ": "
    Many {
      CubeRevealParser()
    } separator: {
      "; "
    }
  }
}
```

And then we will bundle this data into the `Game` data type:

```swift:4,13
// "Game 1: 3 blue, 4 red" -> Game(number: 1, cubeReveals: [CubeReveal(blue: 3, red: 4)])
struct GameParser: Parser {
  var body: some Parser<Substring, Game> {
    Parse(Game.init) {
      "Game "
      Int.parser()
      ": "
      Many {
        CubeRevealParser()
      } separator: {
        "; "
      }
    }
  }
}
```

One have one final parser to define, and it is the simplest. We will define a `GamesParser` that
is capable of parsing many games separated by newlines:

```swift
struct GamesParser: Parser {
  var body: some Parser<Substring, [Game]> {
    Many {
      GameParser()
    } separator: {
      "\n"
    }
  }
}
```

And that is all it takes. We now have a single parser that is capable of turning the nebulous 
input data into well-structured Swift data types:

```swift
let input = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

try GamesParser().parse(input)  // [Game(number: 1, …),…]
```

# Get started today!

That is just a small preview of what the [Parsing library][parsing-gh] is capable of. Consider using 
it in your Advent of Code projects this year, and please do give us any feedback!

[parsing-gh]: http://github.com/pointfreeco/swift-parsing
