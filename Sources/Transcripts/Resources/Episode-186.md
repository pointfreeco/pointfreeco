## Introduction

@T(00:00:05)
So, that’s the basics of writing your first parser with our library, and then making a few small changes in order to magically turn it into a printer and tune its performance.

@T(00:00:16)
And so everything looks really cool, but also, this little Advent of Code parsing problem is only barely scratching the surface of what the library is capable of. Let’s tackle something a little meatier, and even better it will give us an opportunity to explore a little bit of the experimental string processing APIs that Apple is polishing up right as we speak.

@T(00:00:35)
If you follow the [Swift forums](https://forums.swift.org) closely you may have noticed there have been a lot of pitches and discussions about the future of string processing in Swift, primarily focused on regular expressions. There is even a result builder syntax for building regular expressions in a nice, DSL style, which is great because regular expressions tend to be very terse and cryptic.

@T(00:00:55)
Regular expressions, or “regex” for short, are a super compact syntax for describing patterns that you want to try to match on strings in order to capture substrings. It is an extremely powerful, though terse, way to search strings for complex patterns, and they have been around in computer science for a very, very long time.

## ACH regex

@T(00:01:13)
Let’s take a look at an example from some of Apple’s pitches so that we can understand how regexes works in a particular situation, what Apple’s tools bring to the table, and how we can approach the same problem using swift-parsing.

@T(00:01:28)
One example used in Apple’s proposals has to do with a list of bank transactions that we want to extract structured data from:

```txt
CREDIT    04062020    PayPal transfer    $4.99
CREDIT    04032020    Payroll            $69.73
DEBIT     04022020    ACH transfer       $38.25
DEBIT     03242020    IRS tax payment    $52249.98
```

@T(00:01:39)
The first column is whether the transaction was a credit or debit, the second column is the date in a month-day-year format, the third column is the name of the transaction, and the last column is the amount of the transaction.

@T(00:01:53)
The regex for processing this string and extracting out that information is pretty intense, but once you know the ins and outs of regexes it’s mostly straightforward to decipher:

```txt
(CREDIT|DEBIT)\s+(\d{2}\d{2}\d{4})\s+([\w\s]+\w)\s+(\$\d+\.\d{2})
```

@T(00:02:03)
First of all we want to match either “CREDIT” or “DEBIT” from the beginning of the string, and then one or more spaces after it:

```txt
(CREDIT|DEBIT)\s+
```

@T(00:02:11)
The parentheses are called a “capture group” and will make the matched string available to us once we run the regex on our input string.

@T(00:02:17)
Next we want to match the date, which consists of two digits for the month, two digits for the day, and four digits for the year, followed by one or more spaces:

```txt
(\d{2}\d{2}\d{4})\s+
```

@T(00:02:29)
Then we want to match the name of the transaction by matching a bunch of words separated by spaces, followed by one or more spaces:

```txt
([\w\s]+\w)\s+
```

@T(00:02:38)
And finally we want to match the money amount of the transaction by matching a dollar sign, followed by one or more digits, followed by a period, and then exactly two digits:

```txt
(\$\d+\.\d{2})
```

@T(00:02:49)
And then Swift could expose APIs that allows us to iterate over all the matches of this regex so that we can process them:

```swift
let statement = """
  CREDIT    04062020    PayPal transfer    $4.99
  CREDIT    04032020    Payroll            $69.73
  DEBIT     04022020    ACH transfer       $38.25
  DEBIT     03242020    IRS tax payment    $52249.98
  """

for match in statement.matches(of: statementPattern) {
  …
}
```

@T(00:03:01)
And then in the `for` loop, the `match` value holds everything captured by the regex:

```swift
for match in statement.matches(of: statementPattern) {
  let (line, kind, date, description, amount) = match.output
  …
}
```

@T(00:03:26)
It’s worth noting that all of these captures are just strings, and that’s all we could possibly hope for because regex does not have the concept of types. We will always be responsible for layering on additional logic to transform these captures into something more well-structured.

@T(00:03:41)
Currently this does not compile, but someday soon it will.

@T(00:03:44)
So, it is a little intense, and there are some quirks and subtleties that you have to become familiar with to wield it successfully, though it’s also very powerful.

@T(00:03:54)
But then Apple’s proposals took things a bit further. They introduced a result builder style DSL for creating regular expressions without dealing with the esoteric syntax that we see above, and it gives them opportunities to add some new features that are not possible with plain regex.

@T(00:04:10)
They start by defining some types that represent the data they want to extract from the bank statement:

```swift
enum TransactionKind: String {
  case credit = "CREDIT"
  case debit = "DEBIT"
}

struct Date {
  var month, day, year: Int
  init?(mmddyy: String) { … }
}

struct Amount {
  var valueTimes100: Int
  init?(twoDecimalPlaces text: String) { … }
}
```

@T(00:04:32)
Apple doesn’t provide the implementations of these failable initializers in the proposal, but we will talk about these in a moment.

@T(00:04:38)
Then they build a regex using Swift code in style that looks quite similar to how parsers are constructed with our library:

```swift
let statementPattern = Regex {
   // Parse the transaction kind.
  TryCapture {
    ChoiceOf {
      "CREDIT"
      "DEBIT"
    }
  } transform: {
    TransactionKind(rawValue: String($0))
  }
  OneOrMore(.whitespace)
   // Parse the date, e.g. "01012021".
  TryCapture {
    Repeat(.digit, count: 2)
    Repeat(.digit, count: 2)
    Repeat(.digit, count: 4)
  } transform: { Date(mmddyyyy: String($0)) }
  OneOrMore(.whitespace)
   // Parse the transaction description, e.g. "ACH transfer".
  Capture {
    OneOrMore(.custom([
      .characterClass(.word),
      .characterClass(.whitespace)
    ]))
    CharacterClass.word
  } transform: { String($0) }
  OneOrMore(.whitespace)
  "$"
   // Parse the amount, e.g. `$100.00`.
  TryCapture {
    OneOrMore(.digit)
    "."
    Repeat(.digit, count: 2)
  } transform: { Amount(twoDecimalPlaces: String($0)) }
}
// Regex<(Substring, TransactionKind, Date, String, Amount)>
```

@T(00:04:46)
It’s a lot, but it’s also a lot more understandable and powerful than the cryptic regex syntax. We can clearly see we are capturing the credit/debit info at the beginning:

```swift
TryCapture {
  ChoiceOf {
    "CREDIT"
    "DEBIT"
  }
} transform: {
  TransactionKind(rawValue: String($0))
}
```

@T(00:05:00)
Then we skip all the whitespace:

```swift
OneOrMore(.whitespace)
```

@T(00:05:02)
Then we capture the date and skip more whitespace after:

```swift
TryCapture {
  Repeat(.digit, count: 2)
  Repeat(.digit, count: 2)
  Repeat(.digit, count: 4)
} transform: { Date(mmddyyyy: $0) }
OneOrMore(.whitespace)
```

@T(00:05:06)
Then we capture the transaction name as space-separated words, as well as skip any whitespace following the last word:

```swift
Capture {
  OneOrMore(.custom([
    .characterClass(.word),
    .characterClass(.whitespace)
  ]))
  CharacterClass.word
} transform: { String($0) }
OneOrMore(.whitespace)
```

@T(00:05:12)
And finally we skip the dollar sign and capture the money amount of the transaction:

```swift
"$"
// Parse the amount, e.g. `$100.00`.
TryCapture {
  OneOrMore(.digit)
  "."
  Repeat(.digit, count: 2)
} transform: { Amount(twoDecimalPlaces: String($0)) }
```

@T(00:05:19)
One interesting thing to note is the use of the `transform` trailing closure in each of these captures:

```swift
} transform: { TransactionKind(rawValue: String($0)) }
…
} transform: { Date(mmddyyyy: $0) }
…
} transform: { Amount(twoDecimalPlaces: String($0)) }
```

@T(00:05:25)
This is a nice feature that the regex builder library has that is not possible in plain regex. Once a string is extracted via a regex match it allows you to further transform that string into something more well-structured, like a Swift enum or struct.

@T(00:05:40)
In fact, these initializers are all failable for turning a string into something more well-structured:

```swift
enum TransactionKind: String {
  case credit = "CREDIT"
  case debit = "DEBIT"

  /* init?(rawValue: String) { … } */
}

struct Date {
  var month, day, year: Int
  init?(mmddyyyy: String) { … }
}

struct Amount {
  var valueTimes100: Int
  init?(twoDecimalPlaces text: Substring) { … }
}
```

@T(00:05:47)
What’s interesting about these initializers is that they are basically parsers. Just defined in an ad hoc manner. They take a string as input and try to return something more well-structured. So even if you are using regex in order to match patterns on a string and extract out substrings, you still eventually have a parsing problem ahead of you.

@T(00:06:07)
Once you’ve built your regex pattern you can use it to find all the matches just like before:

```swift
for match in statement.matches(of: statementPattern) {
  let (line, kind, date, description, amount) = match.output
  …
}
```

@T(00:06:12)
But now, since we have transformed the captures we have some actual types for the captures, not just plain strings:

```swift
for match in statement.matches(of: statementPattern) {
  let (line, kind, date, description, amount) = match.output
  kind as TransactionKind
  date as Date
  amount as Amount
  …
}
```

@T(00:06:19)
So that’s a very brief preview of some really powerful string processing tools that will be coming to Swift soon.

## ACH parser

@T(00:06:25)
However, this isn’t the only way to attack this problem. As we have seen many times now, our parsing library is also great at transforming unstructured strings, such as this bank statement, into something more well-structured. And not only that, but if we are careful in how we construct this parser we will magically also get a printer out of it so that we can print our data types back into a bank statement.

@T(00:06:49)
We already have the models set up for us since Apple’s sample code defined the models. One thing we will do differently is we will get rid of all the failable initializers. That is all logic that we want baked into the parsers themselves, rather than having two separate passes like what was done with the regex.

@T(00:07:31)
Apple’s proposed regex DSL uses the `Regex` type as an entry point into builder syntax for building a regular expression:

```swift
let statementPattern = Regex {
  …
}
```

@T(00:07:39)
In swift-parsing, the `Parse` type is used as an entry point into parser builder syntax:

```swift
let statementParser = Parse {
}
```

@T(00:07:55)
The first thing being captured in the regex is the string `"CREDIT"` or `"DEBIT"`, which is then converted into a `TransactionKind` via the failable initializer that comes with raw representable types:

```swift
// Parse the transaction kind.
TryCapture {
  ChoiceOf {
    "CREDIT"
    "DEBIT"
  }
} transform: {
  TransactionKind(rawValue: String($0))
}
```

@T(00:08:11)
Our parsing library has a very similar way of writing this code by using the `OneOf` parser instead of the `ChoiceOf` regex component.

@T(00:08:17)
But we can also utilize  a powerful parser that ships with the library, that allows you to derive a parser for any raw-representable enum, so long as it is case-iterable.

@T(00:08:23)
So, let’s make `TransactionKind` case-iterable:

```swift
enum TransactionKind: String, CaseIterable {
  …
}
```

@T(00:08:28)
Once that is done the `TransactionKind` type automatically picks up a `.parser()` static method that automatically does the work we are doing manually with `OneOf`:

```swift
let statementParser = Parse {
  TransactionKind.parser()
}
```

> Error: Ambiguous use of 'parser(of:)'

@T(00:08:35)
The `TransactionKind` parser is very general and can work on many kinds of input. While this input can usually be inferred from other parsers used alongside it, we can also be very explicit by specifying the input we wanna parse:

```swift
let statementParser = Parse {
  TransactionKind.parser(of: Substring.self)
}
```

@T(00:09:29)
After extracting the transaction kind, Apple’s regex skips over one or more whitespace characters:

```swift
OneOrMore(.whitespace)
```

@T(00:09:37)
Our parsing library has a dedicated `Whitespace` parser that can do this work:

```swift
Whitespace()
```

@T(00:09:43)
And it can be configured with a length, represented by a range expression or integer:

```swift
Whitespace(1...)
```

@T(00:09:53)
Although consuming all whitespace probably isn’t the most correct thing to do. Whitespace consists of more than just single spaces. It also consists of newlines, line feeds and more. We can configure our `Whitespace` parser to only consume horizontal whitespace to make sure we aren’t accidentally consuming things we don’t expect:

```swift
Whitespace(1..., .horizontal)
```

@T(00:10:16)
Next we have the date to parse, which Apple’s regex accomplished by extracted two digits, then two more, then four, and then invoked a failable initializer on `Date` to pass all 8 digits:

```swift
// Parse the date, e.g. "01012021".
TryCapture {
  Repeat(.digit, count: 2)
  Repeat(.digit, count: 2)
  Repeat(.digit, count: 4)
} transform: { Date(mmddyyyy: $0) }
```

@T(00:10:36)
We can do something similar using the `Digits` parser, which allows us to parse a certain number of number characters from the beginning of the input as an integer:

```swift
Parse {
  Digits(2)
  Digits(2)
  Digits(4)
}
```

@T(00:10:52)
This produces 3 integers, one for the month, day and year, which is exactly what the `Date` initializer takes. We can even pass that initializer directly to the `Parse` entry point in order to bundle those three integers into a `Date` value:

```swift
Parse(Date.init(month:day:year:)) {
  Digits(2)
  Digits(2)
  Digits(4)
}
```

@T(00:11:27)
Passing functions to the `Parse` entry point is analogous to using the `transform` argument in the `TryCapture` regex builder.

@T(00:11:40)
After we have parsed the date we can again consume one or more horizontal spaces by using the `Whitespace` parser:

```swift
Whitespace(1..., .horizontal)
```

@T(00:11:47)
Next we need to parse the description of the transaction. The regex to accomplish this was quite complex:

```swift
Capture {
  OneOrMore(.custom([
    .characterClass(.word),
    .characterClass(.whitespace)
  ]))
  CharacterClass.word
} transform: { String($0) }
OneOrMore(.whitespace)
"$"
```

@T(00:11:55)
It captures as many word characters and space characters as possible, and then skips over any trailing whitespace when it reaches a dollar sign symbol.

@T(00:12:05)
There’s a tool that comes with our parsing library that can basically accomplish this, but in a different manner. We can use the `PrefixUpTo` to consume everything up until the dollar sign:

```swift
PrefixUpTo("$")
```

@T(00:12:20)
However, this will also capture the whitespace between the last word and the dollar sign. But, we can `.map` on the parser in order to perform some clean up work in order to trim that trailing whitespace:

```swift
PrefixUpTo("$").map { $0.trimmingCharacters(in: .whitespaces) }
```

@T(00:12:45)
It gets the job done, but it’s not a very precise tool, and it’s a bummer to have to perform that clean up work. In fact, that clean up work is going to get even more complicated once we worry about printing because we’ll need to cook up a bidirectional version of this map closure in order to preserve printing.

@T(00:13:10)
Another way to do this is in a style more similar to the regex where we parse off many words separated by whitespace. Now regex has the concept of a word character:

```txt
([\w\s]+\w)\s+
```

@T(00:13:28)
This is a character that can be “reasonably” said to be part of a word. It has a very concise definition in terms of unicode categories, but it’s also surprisingly complex.

@T(00:13:39)
The regex DSL specifies word characters via something called a “character class”:

```swift
.characterClass(.word)
```

@T(00:13:44)
Character classes are a new concept that Apple is introducing with their regex work, which you can think of as a kind of modern replacement for character sets from Foundation. They will ship a character class that describes all word characters, which as we mentioned before is quite a complex subset of the full Unicode standard.

@T(00:14:05)
We unfortunately don’t have easy access to determining if a character is a word character, at least not unless this character class API is released publicly, but for now we can approximate it by just taking letters and numbers from the beginning of the input:

```swift
Prefix(1...) { $0.isLetter || $0.isNumber }
```

@T(00:14:50)
Further, we can get many words separated by whitespaces by using the `Many` parser:

```swift
Many(1...) {
  Prefix(1...) { $0.isLetter || $0.isNumber }
} separator: {
  Whitespace(1..., .horizontal)
}
```

@T(00:15:14)
Now this parser technically produces an array of words that it was able to consume from the input. So we would need to further massage this data to join all the words together in a single string:

```swift
Many(1...) {
  Prefix(1...) { $0.isLetter || $0.isNumber }
} separator: {
  Whitespace(1..., .horizontal)
}
.map { $0.joined(separator: " ") }
```

@T(00:15:37)
But in doing so we will lose the exact whitespace that occurred between each word. We just have to hard-code that a single space occurs between each word, even though technically any number of spaces could occur.

@T(00:15:51)
There is a better way. There is a parser that ships with the library that we have never discussed in episodes, but it is super handy. It’s called `Consumed` and it runs a parser on the input, discards whatever that parser output, and instead outputs what the parser consumed from the input.

@T(00:16:16)
This allows us to simply capture all of the input that the `Many` parser was able to consume, which is all the words up to the dollar sign:

```swift
Consumed {
  Many(1...) {
    Prefix(1...) { $0.isLetter || $0.isNumber }
  } separator: {
    Whitespace(1..., .horizontal)
  }
}
```

@T(00:17:05)
The `Consumed` parser is quite similar to what the regex DSL’s `Capture` type does, and in fact was directly inspired by it.

@T(00:17:17)
Apple’s regex DSL also transforms the captured substring into a proper `String`:

```swift
Capture {
  …
} transform: { String($0) }
```

@T(00:17:28)
So, let’s also do that in our parser:

```swift
Consumed {
  …
}
.map(String.init)
```

@T(00:17:37)
Further, after we consume all of the words we can also consume all the whitespaces after the last word:

```swift
Consumed {
  Many(1...) {
    Prefix(1...) { $0.isLetter || $0.isNumber }
  } separator: {
    Whitespace(1..., .horizontal)
  }
}
.map(String.init)
Whitespace(1..., .horizontal)
```

@T(00:17:49)
After consuming the words and whitespace we can move onto parsing the transaction amount from the input, beginning with the dollar sign:

```swift
…
Whitespace(1..., .horizontal)
"$"
```

> Error: Extra argument in call

@T(00:17:54)
However, with this new parser added to the builder closure we have hit the limit of how many parsers can be put into a parser builder context. We unfortunately have to restrict the number to just 6 parsers due to the explosion of overloaded functions that make parser builder syntax possible. This restriction is only temporary, and in the next version of Swift (5.7) we will be able to dramatically increase this thanks to a new feature of result builders, and once Swift achieves variadic generics we will be able to move the restriction entirely.

@T(00:18:28)
One quick way to work around this limitation right now is to just group some parsers into their own `Parse` blocks, which is essentially what one has to do in SwiftUI when you run into similar limitations:

```swift
let statementParser = Parse {
   // Parse the transaction kind.
  Parse {
    TransactionKind.parser(of: Substring.self)
    Whitespace(1..., .horizontal)
  }
   // Parse the date, e.g. "01012021".
  Parse(Date.init(month:day:year:)) {
    Digits(2)
    Digits(2)
    Digits(4)
    Whitespace(1..., .horizontal)
  }
   // Parse the transaction description, e.g. "ACH transfer".
  Parse {
    Consumed {
      Many(1...) {
        Prefix(1...) { $0.isLetter || $0.isNumber }
      } separator: {
        Whitespace(1..., .horizontal)
      }
    }
    .map(String.init)
    Whitespace(1..., .horizontal)
  }
   // Parse the amount, e.g. `$100.00`.
  Parse {
    "$"

  }
}
```

@T(00:19:00)
We could even break some of these `Parse { … }` blocks out into their own variables which may also help readability. But, now things are building, which means we can try parsing the transaction amount.

@T(00:19:19)
Recall that in Apple’s sample code they use several regex components to capture any number of digits, followed by a decimal point, followed by exactly two digits, and then they hand that string off to an initializer of `Amount` to do some further parsing to turn the string into an actual instance.

```swift
// Parse the amount, e.g. `$100.00`.
TryCapture {
  OneOrMore(.digit)
  "."
  Repeat(.digit, count: 2)
} transform: { Amount(twoDecimalPlaces: $0) }
```

@T(00:19:59)
We are going to do all of this work directly in the parser instead by first parsing a dollar sign, then as many digits as possible, followed by a decimal point, and then exactly two digits:

```swift
Parse {
  "$"
  Digits()
  "."
  Digits(2)
}
```

@T(00:20:12)
This parses a tuple of integers representing the dollars and cents, and so we have to do a little massaging of this data to turn it into an `Amount` value. We can do so by providing a transformation function up front to the `Parse` type:

```swift
Parse { dollars, cents in
  Amount(valueTimes100: dollars*100 + cents)
} with: {
  "$"
  Digits()
  "."
  Digits(2)
}
```

@T(00:20:46)
And we now have a full parser that can process a single line from the bank statement:

```swift
let statementParser = Parse {
   // Parse the transaction kind.
  Parse {
    TransactionKind.parser(of: Substring.self)
    Whitespace(1..., .horizontal)
  }
   // Parse the date, e.g. "01012021".
  Parse(Date.init(month:day:year:)) {
    Digits(2)
    Digits(2)
    Digits(4)
    Whitespace(1..., .horizontal)
  }
   // Parse the transaction description, e.g. "ACH transfer".
  Parse {
    Consumed {
      Many {
        Prefix(1...) { $0.isLetter || $0.isNumber }
      } separator: {
        Whitespace(1..., .horizontal)
      }
    }
    .map(String.init)
    Whitespace(1..., .horizontal)
  }
   // Parse the amount, e.g. `$100.00`.
  Parse { dollars, cents in
    Amount(valueTimes100: dollars*100 + cents)
  } with: {
    "$"
    Digits()
    "."
    Digits(2)
  }
}
```

@T(00:21:01)
In fact, `statementParser` is probably not the best name for this parser anymore, so let’s rename it:

```swift
let transaction = Parse {
  …
}
```

@T(00:21:07)
Now technically we have recreated the regex from Apple’s sample code. Their regex only processed a single line, and then they repeatedly ran the regex against the statement string to extract out as much transaction info as possible:

```swift
for match in statement.matches(of: statementPattern) {
  let (line, kind, date, description, amount) = match.output
  …
}
```

@T(00:21:22)
But we can stay in the world of parsing a little longer by building a full bank statement parser that parses out an array of line items:

```swift
let statement = Many {
  lineItem
} separator: {
  "\n"
}
```

@T(00:21:37)
We can give this parser a spin on our input bank statement string:

```swift
let input = """
  CREDIT    04062020    PayPal transfer    $4.99
  CREDIT    04032020    Payroll March      $69.73
  DEBIT     04022020    ACH transfer       $38.25
  DEBIT     03242020    IRS tax payment    $52249.98
  """
try statement.parse(input)
// [(credit, {month 4, day 6, year 2020}, "PayPal transfer", {valueTimes100 499}), …]
```

@T(00:21:45)
And we will see it correctly extracted each line item from the statement and bundled the data into an array of tuples.

@T(00:21:50)
We can even take this one step further by defining a proper data type to represent a transaction, and then bundle the tuple into that type:

```swift
struct Transaction {
  let kind: TransactionKind
  let date: Date
  let description: String
  let amount: Amount
}

let transaction = Parse(Transaction.init) {
  …
}
```

@T(00:22:18)
And now we are parsing an array of transaction values rather than unstructured tuples.

@T(00:22:54)
Translating this regex into a parser wasn’t so bad, in some cases it was even a little nicer, and amazingly they both take basically the same number of lines to define. So they are both really concise and compact ways to describe very nuanced ways of extracted structured data out of strings.

## ACH printer

@T(00:23:12)
But one of the biggest distinguishing factors of Apple’s regex DSL and swift-parsing is that our library allows you to build parsers in such a way that they can format their output back into a string. This means with little work we can transform an array of transactions back into a bank statement string.

@T(00:23:29)
In fact, many of the parsers we wrote are already printer-friendly. There are only a few small tweaks we need to make to make the entire parser into a printer.

@T(00:23:40)
We can do this in small steps by starting with the leaf parsers in the expression and try converting them to parser-printers. We can do this by swapping out uses of the `Parse` entry point with the `ParsePrint` entry point, and if something in that builder closure is not a printer then the compiler will complain and give us an opportunity to fix it.

@T(00:23:59)
Sometimes we get lucky and a parser is already a printer, for example the transaction kind parser:

```swift
ParsePrint {
  TransactionKind.parser(of: Substring.self)
  Whitespace(1..., .horizontal)
}
```

@T(00:24:04)
The fact that this still compiles means that everything inside the `ParsePrint` closure is a printer. And indeed, the tools that ship with the library that allow us to turn any raw representable, case-iterable enum into a parser, and that allow us to consume whitespace have both been built with printing in mind. The `TransactionKind` parser will simply turn the enum value back into its raw string for printing, and the whitespace parser will print the minimum amount of space needed to satisfy the parser:

```swift
try ParsePrint
{
  TransactionKind.parser(of: Substring.self)
  Whitespace(1..., .horizontal)
}
.print(.credit)  // "CREDIT "
```

@T(00:24:35)
We could even decide to give the transaction kind a little bit of breathing room by overriding the default whitespace printing behavior to use a tab instead:

```swift
try ParsePrint
{
  TransactionKind.parser(of: Substring.self)
  Whitespace(1..., .horizontal).printing("\t")
}
.print(.credit)  // "CREDIT        "
```

@T(00:24:59)
Next we have the date parser, and if we try to upgrade it to a parser-printer we get a compiler error:

```swift:1:fail
ParsePrint(Date.init(month:day:year:)) {
  Digits(2)
  Digits(2)
  Digits(4)
  Whitespace(1..., .horizontal)
}
```

@T(00:25:06)
This is not a parser-printer because the transformation we are providing to turn the 3-tuple of digits into a `Date` is one-directional. That worked fine when doing only parsing, but when printing we need to be able to go the other direction to turn a `Date` back into a 3-tuple.

@T(00:25:21)
We do this in the library by using “conversions”, which describe bidirectional transformations between types. The library even ships with a tool that allows one to derive a conversion from any struct’s default, memberwise initializer:

```swift
ParsePrint(.memberwise(Date.init(month:day:year:))) {
  Digits(2)
  Digits(2)
  Digits(4)
  Whitespace(1..., .horizontal)
}
```

@T(00:25:35)
And now this compiles, and we could even use the `.printing` operator again to give some breathing room after the date:

```swift
ParsePrint(.memberwise(Date.init(month:day:year:))) {
  Digits(2)
  Digits(2)
  Digits(4)
  Whitespace(1..., .horizontal).printing("\t")
}
```

@T(00:25:47)
We can even run this parser-printer in isolation to make sure it does what we expect:

```swift
try ParsePrint(.memberwise(Date.init))
{
  Digits(2)
  Digits(2)
  Digits(4)
  Whitespace(1..., .horizontal).printing("\t")
}
.print(.init(month: 4, day: 20, year: 2022))  // "04202022        "
```

@T(00:26:05)
Notice that it even padded the 4 to be “04” because the `Digits(2)` parser knows it should only print things that can be processed by the parser.

@T(00:26:15)
Now we can try turning the description parser into a printer. We can start by turning the `Parse` entry point into a `ParserPrint` entry point and see what happens:

```swift:1:fail
ParsePrint {
  Consumed {
    Many {
      Prefix(1...) { $0.isLetter || $0.isNumber }
    } separator: {
      Whitespace(1..., .horizontal)
    }
  }
  .map(String.init)
  Whitespace(1..., .horizontal)
}
```

@T(00:26:23)
This fails to compile because again we are using a one-directional `.map` operation to transform the `Substring` consumed into a `String`. To preserve printing capabilities we need to map with a conversion that can transform substrings into strings and strings into substrings. Luckily the library comes with such a conversion, and it’s very succinct to provide with dot syntax:

```swift
ParsePrint {
  Consumed {
    …
  }
  .map(.string)
  Whitespace(1..., .horizontal)
}
```

@T(00:26:48)
And like the other two fields, it might be nice to add a tab space after the transaction description to give some breaking room.

```swift
ParsePrint {
  Consumed {
    …
  }
  .map(.string)
  Whitespace(1..., .horizontal).printing("\t")
}
```

@T(00:26:57)
We’re down to the last field, which is the amount of the transaction. We can try upgrading the `Parse` entry point to be a `ParsePrint`, but of course it isn’t going to work because we are again using a one-directional transformation for turning dollars and cents into an `Amount` value:

```swift:1:fail:1:fail
ParsePrint { dollars, cents in
  Amount(valueTimes100: dollars*100 + cents)
} with: {
  "$"
  Digits()
  "."
  Digits(2)
}
```

@T(00:27:11)
In order to preserving printing we need to supply a bidirectional transformation. One that cannot only turn dollars and cents into an `Amount`, but also turn an amount into dollars and cents.

@T(00:27:23)
This is the first example of needing to supply a fully custom conversion because the library of course does not ship with such a domain-specific kind of transformation. We can do this directly in line by calling `.convert` and supplying apply and unapply transformations:

```swift
ParsePrint(
  .convert(
    apply: <#(Input) -> Output?#>,
    unapply: <#(Output) -> Input?#>
  )
) {
  "$"
  Digits()
  "."
  Digits(2)
}
```

@T(00:27:49)
The apply direction turns dollars and cents into an `Amount`, which is the work we were previously doing:

```swift
ParsePrint(
  .convert(
    apply: { dollars, cents in Amount(valueTimes100: dollars*100 + cents) },
    unapply: <#(Output) throws -> Input#>
  )
) {
  "$"
  Digits()
  "."
  Digits(2)
}
```

@T(00:27:56)
But now we have to somehow do the inverse of this operation. Given an `Amount`, which represents a money value measured in cents, we need to convert it back to dollars and cents. There is actually a method in the standard library that does this for us, and it’s called `quotientAndRemainder`:

```swift
unapply: { amount in amount.valueTimes100.quotientAndRemainder(dividingBy: 100) }
```

@T(00:28:22)
This method returns a tuple of, as the name suggests, the quotient and the remainder when dividing by 100. The quotient is the whole part from dividing the cents by 100, which is precisely dollars. And the remainder is how much was remaining after dividing by 100 and truncating the decimal place.

@T(00:28:39)
For example, the quotient and remainder from dividing 320 by 100 is 3 and 20:

```swift
320.quotientAndRemainder(dividingBy: 100)  // (3, 20)
```

@T(00:28:51)
So that represents 3 dollars and 20 cents.

@T(00:28:55)
And amazingly, with this one small change we now have a parser that can also print.

@T(00:29:04)
Which means finally we can we can make the entire `transaction` parser into a printer by swapping out the `Parse` entry point for a `ParsePrint`, and using the `.memberwise` conversion helper instead of passing the `Transaction` initializer directly to the entry point:

```swift
let transaction = ParsePrint(.memberwise(Transaction.init)) {
  …
}
```

@T(00:29:18)
This compiles, which means everything inside has officially been made into a parser-printer, and also means we can now print transactions into a single line item string:

```swift
try transaction.print(
  .init(
    kind: .credit,
    date: .init(month: 4, day: 20, year: 2022),
    description: "Point-Free",
    amount: .init(valueTimes100: 18_00)
  )
)
// "CREDIT        04202022        Point-Free        $18.00"
```

@T(00:29:48)
And now that `transaction` is a parser-printer it means that `statement` is also a parser-printer by virtue of the fact of how the `Many` parser can be turned into a printer.

@T(00:29:55)
This means we can print an entire array of transactions back into a bank statement string:

```swift
let output = statementParser.parse(input)
print(try statementParser.print(output))
```
```
CREDIT       04062020        PayPal transfer     $4.99
CREDIT       04032020        Payroll March       $69.73
DEBIT        04022020        ACH transfer        $38.25
DEBIT        03242020        IRS tax payment     $52249.98
```

@T(00:30:18)
We made 4 small changes to the parser in order to turn it into a printer, and all 4 had to do with turning one-direction map operations into bidirectional map operations. Even better, 3 of those bidirectional transformations shipped with the library so there really wasn’t any additional work we needed to do, and the other conversion needed to be written by hand, but for good reason:

@T(00:30:42)
It needed to describe a subtly-modeled domain in which a money value is stored as cents. It may have seemed complicated to undo the work of converting dollars and cents to just cents, but that is work that would have needed to be done no matter how you decided to do printing. The fact is that we are holding money as cents, and so if in the future we want to print the dollars and cents separately we have no choice but to do a little math.

@T(00:31:07)
So, we think this is pretty amazing. It only took a few small changes to the parser to magically unlock printing capabilities. One single object encapsulates the process of turning unstructured data into structured data, and turning that structured data back into unstructured data.

@T(00:31:23)
Before we leave this example, let’s take a quick moment to convert it into a UTF-8 parser. Currently it is operating on the level of `Substring`, which makes it easy to get something working since we don’t have to think about UTF-8 normalization, but it also comes with a slight performance penalty. It turns out it doesn’t take much work to convert it to work on the level of UTF-8, where we lose the convenience of working on a high-level string abstraction but gain some performance.

@T(00:31:42)
We can start by changing any hard code string literals to be `UTF8View`s, such as when printing the tab character:

```swift
Whitespace(1..., .horizontal).printing("\t".utf8)
```

@T(00:31:55)
Or when referring to the “$” and “.” characters:

```swift
ParsePrint(
  …
) {
  "$".utf8
  Digits()
  ".".utf8
  Digits(2)
}
```

@T(00:31:59)
With those changes there is only one compiler error, and it is complaining on our description parser that we are mixing together `Substring` and `UTF8View` parsers:

> Error: Static method 'buildBlock' requires the types 'Substring' and 'Substring.UTF8View' be equivalent

@T(00:32:09)
This is happening because the whitespace parser has now been made into a `UTF8View` parser, but the `Prefix` parser is working on `Substring` still because it is invoking `Character` specific APIs such as `isLetter` and `isNumber`.

@T(00:32:26)
Unfortunately there is no way to call such APIs on the elements of a `UTF8View` because those elements are just simple `UInt8` bytes, and it’s possible for letters to be made up of multiple bytes.

@T(00:32:38)
But, luckily for us, the library ships with a tool that allows us to temporarily leave the UTF8 world to parse on the substring level, and then return to the UTF8 world. And it’s even printer friendly. It’s called `From`, and you provide to it a conversion for converting back and forth between UTF8 and whatever world you want to work in, in this case substring:

```swift
From(.substring) { … }
```

And then inside the parser builder closure you can do any parsing you want on the level of substring:

```swift
From(.substring) {
  Prefix(1...) { $0.isLetter || $0.isNumber }
}
```

@T(00:33:07)
And now everything compiles. Not only that, everything still runs exactly as it did before. We can still parse and print just as we were doing when we were handling substrings.

@T(00:33:18)
So this is pretty amazing. We have built a parser that mimics what Apple’s sample code does with regexes, but we were able to slightly tweak the parser so that it was also a printer, and then, with a few more tweaks we made it so that it works on a lower level string representation, UTF-8, which is even more performant.

@T(00:33:35)
It’s also interesting to compare these two approaches for extracting data out of a string. Regular expressions are really good at describing ways of finding subtle and nuanced patterns in a string. However, once you capture those substrings you still have a mini-parsing problem on your hands because you typically want to turn those substrings into something more well structured, like numbers, dates, or custom struct and enum data types, and that work must be done in code that is entirely separate from the regex pattern you construct.

@T(00:34:04)
On the other hand, parsers are really good at describing how to incrementally consume bits from the beginning of a string and turn those bits into data types. This is great for breaking down the process of parsing into many tiny steps that concentrate on just one task, and great for extracting out high level, first class data types along the way. Further, as we have now seen a few times, parsers also have a chance at becoming printers, which has no equivalent in the world of regular expressions. However, parsers are not as good as finding nuanced patterns in strings as regular expressions are, and so if that is necessary for your domain it may be difficult to use parsers.

@T(00:34:43)
All of this is to say that parsing and regular expressions form an overlapping Venn diagram where either tool can be used to solve certain problems, and then other problems are best solved with one tool or the other. There is no universal solution here.

## Next time: URL routing

@T(00:34:58)
There is one other problem area where parser-printers really shine that unfortunately regular expressions can’t really help out with, and that’s when needing to process inputs that aren’t strings. All of the problems we have considered so far in this tour, including the Advent of Code example and the bank statement parser, have operated on simple string inputs, and of course the idea of regular expressions only makes sense for strings.

@T(00:35:20)
However, there are times we want to extract information from things that are not simple strings. An example of this we have touched upon a number of times in Point-Free is URL routing. This is the process of taking a nebulous, incoming URL request, which includes a path, query params, request body data, headers and more, and turning it into something more well-structured so that we know where in our app our website the user wants to go.

@T(00:35:45)
There are many open source libraries out there that aim to solve this problem, but there’s another side to URL routing that isn’t talked about much. And that’s how do you do the reverse where you want to turn your well-structured data back into a URL request. This is very important when building websites where you need to be able to create valid URLs to pages on your site.

@T(00:36:05)
Let’s quickly recap the problem space of URL routing for our viewers since some watching this episode may not have been following our past episodes, and then let’s show what our parser library has to say about routing.
