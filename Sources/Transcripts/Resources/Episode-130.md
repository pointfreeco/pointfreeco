## Introduction

@T(00:00:05)
We do want to mention that inlining code is not the be all to end all when it comes to performance. Firstly there are no guarantees what code is automatically inlined, and even if you inline everything specifically, that can come with its own costs. This is why benchmarking is so important, so you can measure these differences, and in particular benchmarking at both a micro and macro scale is important, as we have by measuring both smaller and larger parsers, because each scale can have its own performance characteristics.

## Composable CSV parsing

@T(00:00:45)
So at this point we could keep converting more and more parsers, but there won't be too many big lessons to be had in doing that. We may learn a few things about API design and making the friendliest interface as possible, but the conversion of all of our parsers to this new protocol is going to be mostly mechanical.

@T(00:01:03)
So, instead what we are going to do is ask "what's the point?" Now surely we don't need to justify why we are improving the performance of parsers. That's just a net benefit to users of our parser library, and it's even amazing that we were able to get these boosts in performance without substantially changing the way we approach parsing problems.

@T(00:01:22)
However, what does need to be justified is using our combinator-based parser library over other forms of parsing, especially when performance is a concern. We feel we have put together a convincing case of why you'd want to use parser combinators over other forms of parsing if composition, code use, and managing complexity is important to you, but we haven't done such a good job of comparing the performance of the various styles of parsing. And if you are working on a problem where performance is crucial, then you may be willing to give up a little bit of the beauty of parser combinators if what you get out of it is speed.

@T(00:38:16)
So, can we honestly recommend people use the combinator-style of parsing instead of other methods that may be more performant?

@T(00:02:01)
Yes, yes we can. We are now going to demonstrate that all of the hard work we have done in our parser combinator library has brought us within a stone's throw of the performance of more ad-hoc, hand-rolled parsers, and it's quite surprising and impressive to see.

@T(00:02:29)
To explore this we are going to build yet another parser from scratch. There's a parser that is ubiquitous in the field of parsing due to its simplicity in description, yet it's subtle difficulty to get right. There are many implementations of this parser in various styles, and so that makes it perfect for us to benchmark our combinators against.

@T(00:02:49)
We will be parsing "comma separated values", or CSV for short. It's a very simple text format that allows you to describe tabular data.

@T(00:03:04)
For example, a table of users might look like this:

```swift
let csv = """
id,name,isAdmin
1,Blob,true
2,Blob Jr,false
3,Blob Sr,true
"""
```

@T(00:03:10)
The fields of the document are separated by commas, and the rows of the document are separated by newlines.

@T(00:03:20)
Each field in a CSV document can be one of two styles: either a plain field or a quoted field. Currently all the fields in this CSV string are plain, but we could also add quotes:

```swift
let csv = """
id,name,isAdmin
1,"Blob",true
2,"Blob Jr",false
3,"Blob Sr",true
"""
```

@T(00:03:36)
These quotes don't change the content of the document, it's just an alternate way of expressing the same data.

@T(00:03:41)
The quotes are important because they allow you to put commas in a field value, which otherwise would be interpreted as a delimiter between two fields:

```swift
let csv = """
id,name,isAdmin
1,"Blob",true
2,"Blob Jr",false
3,"Blob Sr",true
4,"Blob, Esq.",false
"""
```

@T(00:04:04)
That is the basics of the CSV standard we will be parsing right now. There are more edge cases to look out for, such as delimiting rows by either newlines or line feeds, as well as handling quotations inside a quoted field. For example, technically this is valid CSV:

```swift
let csv = """
id,name,isAdmin
1,"Blob",true
2,"Blob Jr",false
3,"Blob Sr",true
4,"Blob, ""Esq.""",false
"""
```

@T(00:04:36)
We are not going to handle these things right now because we already have a lot of work ahead of us, but rest assured it can be done.

@T(00:04:42)
We'd like to parse these kinds of strings into a two-dimensional array of strings:

```swift
// [[String]]
```

@T(00:04:53)
Where the outer array holds each parsed line, and the inner array holds each parsed field.

@T(00:04:59)
Let's get benchmarking! We'll create a new file and start building some parsers for comparison. We'll start with the simplest model of parsing: using our `Parser` type and using the `Substring` abstraction. We can start by declaring up front the final parser we want to build, which is a parser of substrings to a two-dimension array of strings:

```swift
let csv: Parser<Substring, [[String]]>
```

@T(00:05:34)
But because we want our benchmark to focus on the performance of the parser type and how parsers are pieced together, let's not muddy things with the cost of converting `Substring` to `String`, and simply leave the fields intact.

```swift
let csv: Parser<Substring, [[Substring]]>
```

@T(00:05:49)
And working our way back, what we should be able to create a `csv` parser from a `line` parser and the `zeroOrMore` combinator:

```swift
let line: Parser<Substring, [Substring]>
let csv = line.zeroOrMore(separatedBy: "\n")
```

@T(00:06:20)
How do we create a line parser? Well, we can introduce a `field` parser and call `zeroOrMore` on it:

```swift
let field: Parser<Substring, Substring>
let line = field.zeroOrMore(separatedBy: ",")
```

@T(00:06:41)
And we can even break the `field` parser down into smaller pieces, because we want to handle both quoted fields and simple, unquoted fields. We can stub out a parser for each one and use the `oneOf` combinator to combine them.

```swift
let quotedField: Parser<Substring, Substring>
let plainField: Parser<Substring, Substring>
let field = Parser.oneOf(quotedField, plainField)
```

So `field` will first try to parse a quoted field, and if that fails, it will fall back to parsing a plain, unquoted field.

@T(00:07:22)
Just two parsers to go. To parse a single plain field off the beginning of a document we can simply scan forward until we encounter a comma or a newline:

```swift
let plainField = Parser<Substring, Substring>
  .prefix(while: { $0 != "," && $0 != "\n" })
```

@T(00:08:01)
Whereas to parse a quoted field we need to first detect that we start with a quote, and then parse everything up until the next quote, making sure to also consume the trailing quote:

```swift
let quotedField = Parser<Substring, Void>.prefix("\"")
  .take(.prefix(while: { $0 != "\"" }))
  .skip("\"")
```

@T(00:09:08)
This is pretty incredible. We have built a CSV parser in just 8 lines of code, and these 8 lines read very well and succinctly describe exactly what they do.

@T(00:09:18)
Let's get a benchmark in place for our first attempt at CSV parsing. First we'll paste in a bigger CSV document to play around with. We found this on a website that has lots of sample CSV documents of varying sizes. [This one](https://github.com/pointfreeco/episode-code-samples/blob/main/0130-parsing-performance-pt4/string-performance/Sources/string-performance/CsvSample.swift) is 1,000 rows and about 71kb.

@T(00:09:48)
And now we can get a basic benchmark in place:

```swift
import Benchmark

let csvSuite = BenchmarkSuite(name: "CSV") { suite in
  suite.benchmark("Parser: Substring") {
    var input = csvSample[...]
    let output = csv.run(&input)
    precondition(output!.count == 1000)
    precondition(output!.allSatisfy { $0.count == 5 })
  }
}
```

@T(00:10:44)
Here we have gotten a little more strict with our preconditions. We are not only requiring that we parsed 1,000 rows, but also each row must have exactly 5 columns.

@T(00:10:52)
Let's add this suite to our main.swift benchmarks and run:

```swift
Benchmark.main([
  // copyingSuite,
  // intParserSuite,
  // raceSuite,
  // xcodeLogsSuite,
  // closureSuite,
  // protocolSuite,
  csvSuite,
])
```

```txt
running CSV: Parser: Substring... done! (2303.50 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8174693.500 ns ±   9.76 %        148
Program ended with exit code: 0
```

@T(00:11:08)
OK, that takes about 8 milliseconds, which for a 71kb document means we are parsing at a rate of about 8 megabytes per second. That seems pretty fast, but also we have nothing to compare it to.

@T(00:11:22)
Let's employ the first performance trick which is to simply convert the parser to work on UTF-8. We don't need any of the power of the substring API, so it should be pretty straightforward to convert.

@T(00:11:48)
We can start by introducing a `do` block so our parser names don't conflict with the ones we just defined.

```swift
do {

}
```

@T(00:12:08)
And in here we can copy, paste, and sprinkle in some explicit `.prefix` operators and UTF-8 code units:

```swift
do {
  let quotedField = Parser<Substring.UTF8View, Void>
    .prefix("\""[...].utf8)
    .take(.prefix(while: { $0 != .init(ascii: "\"") }))
    .skip(.prefix("\""[...].utf8))
  let plainField = Parser<Substring.UTF8View, Substring.UTF8View>
    .prefix(while: {
      $0 != .init(ascii: ",") && $0 != .init(ascii: "\n")
    })
  let field = Parser.oneOf(quotedField, plainField)
  let line = field.zeroOrMore(separatedBy: .prefix(","[...].utf8))
  let csv = line.zeroOrMore(separatedBy: .prefix("\n"[...].utf8))

  suite.benchmark("Parser: UTF8") {
    var input = csvSample[...].utf8
    let output = csv.run(&input)
    precondition(output!.count == 1000)
    precondition(output!.allSatisfy { $0.count == 5 })
  }
}
```

@T(00:13:38)
And now when we run benchmarks:

```txt
running CSV: Parser: Substring... done! (2311.00 ms)
running CSV: Parser: UTF8... done! (1579.38 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8234883.000 ns ±   8.65 %        155
CSV.Parser: UTF8      1967454.000 ns ±  11.64 %        666
Program ended with exit code: 0
```

@T(00:13:44)
Pretty impressive. A 4x performance improvement from just one tiny change in our parser. Now we can parse about 35 megabytes per second.

@T(00:13:55)
One thing to note is that these parsers differ slightly. Our substring parser returns `[[Substring]]`, but our UTF8 parser returns `[[Substring.UTF8View]]`. We could introduce a `map` operation to convert each field to `String`, but we want our benchmark to focus on the performance of our combinators and don't want to muddy things by introducing the overhead of a string initializer.

## Parsing with mutating methods

@T(00:14:20)
So by tweaking just a few small things in our use of the `Parser` type over to UTF-8 we were able to see a substantial improvement. One would hope that `ParserProtocol` would improve things even more.

@T(00:14:34)
But before doing that let's explore what some more ad-hoc, hand-rolled parsers look like.

@T(00:14:44)
Let's start with one of the more popular ways of writing parsers in Swift, which is to create a collection of mutating helper methods that can represent the process of consuming bits of the string to produce a value. We can start with a stub of a method on `Substring.UTF8View` that represents the work to parse the full CSV document:

@T(00:15:02)
We can start with a stub of a method on `Substring.UTF8View` that represents the work to parse the full CSV document:

```swift
extension Substring.UTF8View {
  mutating func parseCSV() -> [[Substring.UTF8View]] {
    var results: [[Substring.UTF8View]] = []

    return results
  }
}
```

@T(00:15:48)
Inside here we want to consume as many lines as we can from the document, until the string is empty. We can do that with a `while` loop:

```swift
mutating func parseCsv() -> [[Substring.UTF8View]] {
  var results: [[Substring.UTF8View]] = []
  while !self.isEmpty {

  }
  return results
}
```

@T(00:16:01)
Then in the loop we can try parsing a single line, as well as the trailing newline if there is one. To do this we will create another mutating helper that is responsible for parsing a single line of fields:

```swift
mutating func parseCsv() -> [[Substring.UTF8View]] {
  var results: [[Substring.UTF8View]] = []
  while !self.isEmpty {
    results.append(self.parseLine())
    if self.first == .init(ascii: "\n") {
      self.removeFirst()
    }
  }
  return results
}

mutating func parseLine() -> [String] {
  fatalError()
}
```

@T(00:16:58)
So now we need to implement the `parseLine` method.

@T(00:17:01)
Inside here we need to consume as many fields as we can from the document, until we get to a newline or get to the end of the file. This will look similar to the `parseCSV` method where we create an array of results, and then perform a look to get all the fields:

```swift
mutating func parseLine() -> [Substring.UTF8View] {
  var fields: [Substring.UTF8View] = []

  while ??? {
    ???
  }

  return fields
}
```

@T(00:17:28)
This time we will do an infinite loop so that we make sure to get all the fields, and we'll call out to yet another helper that is responsible for parsing a single field, and once that's done we need to make sure to consume the comma delimeter. We also need to make sure to break out the infinite loop once there are no more fields to parse, which we can tell by the fact that the next character is not a comma:

```swift
mutating func parseLine() -> [Substring.UTF8View] {
  var fields: [Substring.UTF8View] = []
  while true {
    fields.append(self.parseField())
    if self.first == .init(ascii: ",") {
      self.removeFirst()
    } else {
      break
    }
  }
  return fields
}

mutating func parseField() -> Substring.UTF8View {
  fatalError()
}
```

@T(00:18:36)
So now we just have to implement the `parseField` method. Remember that parsing a field falls into one of two categories: you either parse a quoted field or a plain field. So let's get some stubs in for those and implement `parseField` using them:

```swift
mutating func parseField() -> Substring.UTF8View {
  if self.first == .init(ascii: "\"") {
    return self.parseQuotedField()
  } else {
    return self.parsePlainField()
  }
}

mutating func parseQuotedField() -> Substring.UTF8View {
  fatalError()
}

mutating func parsePlainField() -> Substring.UTF8View {
  fatalError()
}
```

@T(00:19:25)
OK, now we are down to implementing `parseQuotedField` and `parsePlainField`.

@T(00:19:29)
To parse a quoted field we just need to consume the quote, then consume everything up to the next quote, and then consume the trailing quote:

```swift
mutating func parseQuotedField() -> Substring.UTF8View {
  self.removeFirst()
  let field = self.prefix { $0 != .init(ascii: "\"") }
  self.removeFirst(field.count)
  self.removeFirst()
  return field
}
```

@T(00:20:07)
And the plain field parser just takes everything until a newline or comma is encountered:

```swift
mutating func parsePlainField() -> Substring.UTF8View {
  let field = self.prefix {
    $0 != .init(ascii: "\n") && $0 != .init(ascii: ",")
  }
  self.removeFirst(field.count)
  return field
}
```

@T(00:20:36)
And that completes the implementation of this hand-rolled parser. So how does it perform? Let's write another benchmark:

```swift
suite.benchmark("Mutating methods") {
  var input = csvSample[...].utf8
  let output = input.parseCsv()
  precondition(output.count == 1000)
  precondition(output.allSatisfy { $0.count == 5 })
}
```

```txt
running CSV: Parser: Substring... done! (2341.16 ms)
running CSV: Parser: UTF8... done! (1539.34 ms)
running CSV: Mutating methods... done! (1452.20 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8260476.500 ns ±  11.48 %        156
CSV.Parser: UTF8      1997701.000 ns ±  14.19 %        623
CSV.Mutating methods   926742.500 ns ±  17.15 %       1376
Program ended with exit code: 0
```

@T(00:21:14)
Very interesting. The mutating method style of parsing is even faster.

@T(00:21:24)
On the one hand it's a bit of a bummer that this hand-rolled parser is nearly twice as fast as our combinators. However, on the other hand it's also pretty impressive that our combinators were even able to get this close to the performance of a hand-rolled parser.

@T(00:21:38)
I think it's pretty well accepted that writing parsers in a flat, imperative style should massively outperform parser combinators. This seems reasonable since combinators are an abstraction over the nitty-gritty work of consuming and extracting information from strings, and even worse they are built up from highly nested escaping closures, which comes with extra costs.

@T(00:21:59)
However, our combinator style is just 50% of the speed of the ad-hoc style, and the code for the combinators is far more straightforward. It's declarative in that we get to describe at a very high level how we want to process the input string, where as the ad-hoc parser needs to juggle a bunch of internal mutable state to build up its results.

## Parsing in an unrolled loop

@T(00:22:19)
So, I think the performance of these two styles of parsing are close enough that you might actually consider using version that has more maintainable code even though it is slightly slower. It really does seem that Swift does a very good job at optimizing the way the cost of the abstraction we have put on top of the string manipulation code.

@T(00:22:37)
But let's push things further.

@T(00:22:39)
There's another style of parsing that can sometimes be even more efficient than the mutating methods we just explored. In fact, this mutating method we just created isn't technically much different from our parser combinators. We can even see a lot of the same shapes under the hood, such as `parseCSV` and `parseLine` kinda being like a `zeroOrMore` and `parseField` being like a `oneOf`. Really all we've done is just unrolled the combinators to be methods, and we lost all of the code reuse and composability.

@T(00:23:11)
But there's another style of parsing that is much different from combinators and the mutating methods that tends to be even faster. In this style we linearly loop over the entire string while keeping track of some state that determines various things, such as if we are currently inside a quotation or not.

@T(00:23:43)
So let's start with a function to express this new parser:

```swift
func loopParseCSV(_ input: String) -> [[Substring.UTF8View]] {
}
```

@T(00:23:59)
In this function we will keep track of a few mutable variables. For the array of results that we will build up as we loop over the string:

```swift
var results: [[Substring.UTF8View]] = []
```

@T(00:24:09)
As well as the current start and end index of the portion of the string we are currently building up to be a field that is added to the results:

```swift
var startIndex = input.utf8.startIndex
var endIndex = startIndex
```

@T(00:24:31)
Next we loop over every code unit in the string and switch on it:

```swift
for c in input.utf8 {
  switch c {

  }
}
```

@T(00:24:44)
Whenever we encounter a comma in the string we will take everything between the start and end index and append it to the last result in the array, as well as reset the start index to be right after the end index so that we can start building up a new buffer for the next field:

```swift
case .init(ascii: ","):
  results[results.count - 1].append(input.utf8[startIndex ..< endIndex])
  startIndex = input.utf8.index(after: endIndex)
```

@T(00:25:34)
We will do something similar when we come across a newline, except we will further append a new row to the array of results:

```swift
case .init(ascii: "\n"):
  results[results.count - 1].append(input.utf8[startIndex ..< endIndex])
  startIndex = input.utf8.index(after: endIndex)
  result.append([])
```

@T(00:26:08)
Otherwise there's no other special characters to consider, and so we can just break:

```swift
default:
  break
```

@T(00:26:13)
After we're done with the switch we need to advance the `endIndex` by one so that we can consume more and more of the string:

```swift
endIndex = input.utf8.index(after: endIndex)
```

@T(00:26:34)
And then finally after the loop we need to take whatever else was left between the start and end indices, add it to the array of results, and return the results:

```swift
result[results.count - 1].append(input.utf8[startIndex ..< endIndex])

return result
```

@T(00:26:53)
That's a basic version of a CSV parser in this style. It's quite a bit more indirect than the other styles of parsing. We are keeping track of 3 pieces of mutable state, and it's hard to grok how all of it evolves over time.

@T(00:27:12)
But even worse, it's not even correct right now. We've completely ignored quoted fields. To see that this really is a problem, let's write a benchmark:

```swift
suite.benchmark("Imperative loop") {
  let output = loopParseCSV(csvSample)
  precondition(output.count == 1000)
  precondition(output.allSatisfy { $0.count == 5 })
}
```

> Error: Thread 1: Swift runtime failure: index out of range

@T(00:27:57)
We got caught on something, although not the precondition we expected. It looks like we forgot to start things off with an empty first row that can be appended to. Instead of starting with an array it should have been an array of a single array:

```swift
var results: [[Substring.UTF8View]] = []
```

@T(00:28:15)
And with that out of the way...

> Error: Thread 1: Swift runtime failure: precondition failure

@T(00:28:23)
We hit our precondition. Seems like we are parsing a row that does not have exactly 5 columns. This is happening because some of the rows in our sample CSV document have quoted fields that contain commas, and so our new parser is not handling those properly.

@T(00:28:56)
So let's fix it.

@T(00:28:57)
We need to introduce some additional mutable state so that we know when we are currently inside a quoted field, which we can use to know when it's time to flush the current string between the start and end indices to the results array:

```swift
var isInQuotes = false
```

@T(00:29:17)
Then we'll be on the look out for when we encounter a quote so that we can toggle this boolean:

```swift
case .init(ascii: "\""):
  isInQuotes.toggle()
```

@T(00:29:29)
And the way we'll use this boolean is to only allow flushing a field to the results array if we are not in a quotation:

```swift
case .init(ascii: ","):
  guard !isInQuotes else { continue }
  result[result.endIndex-1].append(input.utf8[startIndex ..< endIndex])
  startIndex = input.utf8.index(after: endIndex)

case .init(ascii: "\n"):
  guard !isInQuotes else { continue }
  result[result.endIndex-1].append(input.utf8[startIndex ..< endIndex])
  startIndex = input.utf8.index(after: endIndex)
  result.append([])
```

> Correction: Whoops! This code actually introduces a bug, where `continue` prevents the `endIndex` from advancing. While this is a good demonstration of how hard it is to maintain code like this, it wasn't intended 😬! A more resilient `precondition` could have caught this, though!

@T(00:30:06)
Now when we run benchmarks we don't hit the precondition:

```txt
running CSV: Parser: Substring... done! (2381.16 ms)
running CSV: Parser: UTF8... done! (1544.82 ms)
running CSV: Mutating methods... done! (1440.87 ms)
running CSV: Imperative loop... done! (2423.19 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8237204.000 ns ±  13.07 %        162
CSV.Parser: UTF8      2051995.500 ns ±  13.97 %        604
CSV.Mutating methods   957482.000 ns ±  17.25 %       1309
CSV.Imperative loop    867210.000 ns ±  16.86 %       1533
Program ended with exit code: 0
```

@T(00:30:13)
It seems to only be a tiny bit faster. This was pretty surprising to us when we saw this. We assumed that this more barebones, imperative style of parsing would be quite a bit faster than the mutating methods, but it seems that Swift does a very good job at optimizing any overhead from calling methods.

@T(00:30:43)
However, this new imperative style isn't even as correct as the other parsers are. Right now when we encounter a quoted field we are accidentally keep the quotation marks inside the field value.

@T(00:30:56)
So if we had the CSV document:

```swift
// 1,"Blob",true
```

@T(00:31:00)
The imperative parser would produce an array of results like this:

```swift
// [["1", "\"Blob\"", "true"]]
```

@T(00:31:15)
This is because although we are doing extra work detecting entering and leaving the quotations, we aren't doing any extra work to make sure we don't flush those characters to the results array. Doing that will make this code even more complicated, so we aren't even going to bother. We will leave it as an exercise for the viewer.

## Composable parsing with a protocol

@T(00:31:47)
But now that we've properly explored the space of alternative methods of parsing, let's focus our attention back on our parser combinators. We still haven't created a CSV parser using the new `ParserProtocol` API, and we would hope that it would give us a bit of a performance boost since it is capable of inlining more things than the `Parser` struct can.

@T(00:32:13)
If we look at the current parser combinator expression for the CSV parser we will see that there are a lot of helpers defined on the `Parser` type that we haven't yet ported to the `ParserProtocol`.

@T(00:32:25)
For example, the quoted field parser uses `.prefix` and `.prefix(while:)`:

```swift
let quotedField = Parser<Substring.UTF8View, Void>
  .prefix("\""[...].utf8)
  .take(.prefix(while: { $0 != .init(ascii: "\"") }))
  .skip(.prefix("\""[...].utf8))
```

@T(00:32:44)
Let's port these parser functions over to the parser protocol by defining some new types that conform to it.

@T(00:32:56)
We can start with `.prefix(while:)` by creating a struct called `PrefixWhile`:

```swift
struct PrefixWhile: ParserProtocol {
}
```

@T(00:33:04)
This parser, like the `First` parser we defined before it, will work on any collection, so we can introduce another `Input` generic and constrain it in similar ways:

```swift
struct PrefixWhile<Input>: ParserProtocol
where
  Input: Swift.Collection,
  Input.SubSequence == Input
{
}
```

@T(00:33:26)
And this parser will return a collection of output of the same type:

```swift
typealias Output = Input
```

@T(00:33:41)
In order for the parser to do its job it needs to hold onto a predicate on the collection's element:

```swift
let predicate: (Input.Element) -> Bool
```

@T(00:34:05)
And then finally we can implement the `run` method to do the work, which is basically the same implementation as our `.prefix(while:)` combinator:

```swift
func run(_ input: inout Input) -> Output? {
  let output = input.prefix(while: self.predicate)
  input.removeFirst(output.count)
  return output
}
```

@T(00:34:31)
And with this defined we can start using it. We'll get a new protocol benchmark into our CSV suite, copying and pasting from the UTF-8 benchmark, and translating each parser as we go. Starting with the plain field parser:

```swift
let plainField = PrefixWhile<Substring.UTF8View> {
  $0 != .init(ascii: ",") && $0 != .init(ascii: "\n")
}
```

@T(00:35:29)
Interestingly the syntax of this expression has gotten a little less noisy. We no longer have to explicitly write out the input and output of the parser. We just specify what type of collection it operates on and the input and output is automatically determined under the hood.

@T(00:35:41)
The quoted field parser has a few additional things we haven't yet ported to the parser protocol:

```swift
let quotedField = Parser<Substring.UTF8View, Void>
  .prefix("\""[...].utf8)
  .take(.prefix(while: { $0 != .init(ascii: "\"") }))
  .skip(.prefix("\""[...].utf8))
```

@T(00:35:51)
The `.prefix` combinator is easy enough to define, and we'll just paste the final type:

```swift
struct Prefix<Input>: ParserProtocol
where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element: Equatable
{
  typealias Input = Collection
  typealias Output = Void

  let possiblePrefix: Collection

  init(_ possiblePrefix: Collection) {
    self.possiblePrefix = possiblePrefix
  }

  func run(_ input: inout Input) -> Output? {
    guard input.starts(with: self.possiblePrefix)
    else { return nil }
    input.removeFirst(self.possiblePrefix.count)
    return ()
  }
}
```

@T(00:36:04)
The quoted field parser also utilizes the `take` and `skip` methods for gluing multiple parsers together. To define the `.skip` combinator we need to accomplish two things. First we need to create a new type to conform to `ParserProtocol` that represents the concept of parsing two things and then skipping the output of the second. We'll paste in the final type for that:

```swift
struct SkipSecond<Parser1, Parser2>: ParserProtocol
where
  Parser1: ParserProtocol,
  Parser2: ParserProtocol,
  Parser1.Input == Parser2.Input
{
  typealias Input = Parser1.Input
  typealias Output = Parser1.Output

  let p1: Parser1
  let p2: Parser2

  func run(_ input: inout Input) -> Output? {
    let original = input

    guard let output1 = self.p1.run(&input)
    else { return nil }

    guard self.p2.run(&input) != nil
    else {
      input = original
      return nil
    }

    return output1
  }
}
```

@T(00:36:49)
And then to expose a method version of this parser we extend the `ParserProtocol` and return this `SkipSecond` type from it:

```swift
extension ParserProtocol {
  func skip<P>(_ parser: P) -> SkipSecond<Self, P>
  where P: ParserProtocol, P.Input == Input {
    .init(p1: self, p2: parser)
  }
}
```

@T(00:36:59)
And with this we can now write our quoted field parser like so:

```swift
let quotedFieldProtocol = Prefix("\""[...].utf8)
  .take(PrefixWhile { $0 != .init(ascii: "\"") })
  .skip(Prefix("\""[...].utf8))
```

This has gotten quite a bit less noisy that our other quoted field parser thanks the fact that we don't need to specify the generics on the first `Prefix`.

@T(00:37:21)
However, this isn't quite right. Right now the first `Prefix` produces a `Void` value, and the `.take` will bundle that `Void` value and the output of the `PrefixWhile` into a tuple. We handle this situation in our `Parser` struct by defining an overload of `.take` that discards that `Void` value automatically.

@T(00:37:36)
Let's do the same for the `ParserProtocol`. We will define a new conformance that represents the idea of running two parsers but then discarding the output of the first:

```swift
struct SkipFirst<Parser1, Parser2>: ParserProtocol
where
  Parser1: ParserProtocol,
  Parser2: ParserProtocol,
  Parser1.Input == Parser2.Input
{
  typealias Input = Parser1.Input
  typealias Output = Parser2.Output

  let p1: Parser1
  let p2: Parser2

  func run(_ input: inout Input) -> Output? {
    let original = input

    guard self.p1.run(&input) != nil
    else { return nil }

    guard let output2 = self.p2.run(&input)
    else {
      input = original
      return nil
    }

    return output
  }
}
```

@T(00:38:01)
And then we will define a method version of this operator that only works when the output of the receiver is `Void`:

```swift
extension ParserProtocol where Output == Void {
  func take<P>(_ parser: P) -> SkipFirst<Self, P>
  where P: ParserProtocol, P.Input == Input {
    .init(p1: self, p2: parser)
  }
}
```

@T(00:38:20)
Next we have the field parser, which simply tries the quoted field parsers, and if that fails tries the plain field parser:

```swift
let field = Parser.oneOf(quotedField, plainField)
```

@T(00:38:28)
We don't currently have the `.oneOf` combinator ported to the `ParserProtocol`, but it's simple enough to do:

```swift
struct OneOf<Parser1, Parser2>: ParserProtocol
where
  Parser1: ParserProtocol,
  Parser2: ParserProtocol,
  Parser1.Input == Parser2.Input,
  Parser1.Output == Parser2.Output
{
  typealias Input = Parser1.Input
  typealias Output = Parser1.Output

  let p1: Parser1
  let p2: Parser2

  init(_ p1: Parser1, _ p2: Parser2) {
    self.p1 = p1
    self.p2 = p2
  }

  func run(_ input: inout Input) -> Output? {
    if let output = self.p1.run(&input) { return output }
    if let output = self.p2.run(&input) { return output }
    return nil
  }
}
```

@T(00:38:44)
One difference from the `oneOf` combinator is that it is no longer variadic in the number of parsers it takes. This is because we still want to be able to combine parsers of different types as long as their input and output types are the same. So if we wanted to combine 3 or more parsers we would have to start nesting our `OneOf`s. This nesting can ultimately be avoided by introducing a more fluent API, and we have exercises to do just that.

@T(00:39:29)
And now we can simply do:

```swift
let fieldProtocol = OneOf(quotedFieldProtocol, plainFieldProtocol)
```

@T(00:39:41)
And finally we have the single line and full CSV document parsers, which are just `.zeroOrMore`'s with a simple prefix:

```swift
let lineUtf8 = fieldUtf8
  .zeroOrMore(separatedBy: .prefix(","[...].utf8))
let csvUtf8 = lineUtf8
  .zeroOrMore(separatedBy: .prefix("\n"[...].utf8))
```

@T(00:39:48)
Defining a `ZeroOrMore` type to conform to the `ParserProtocol` is straightforward, so we will paste the final result here:

```swift
struct ZeroOrMore<Upstream, Separator>: ParserProtocol
where
  Upstream: ParserProtocol,
  Separator: ParserProtocol,
  Upstream.Input == Separator.Input
{
  typealias Input = Upstream.Input
  typealias Output = [Upstream.Output]

  let upstream: Upstream
  let separator: Separator

  func run(_ input: inout Input) -> Output? {
    var rest = input
    var outputs = Output()
    while let output = self.upstream.run(&input) {
      rest = input
      outputs.append(output)
      if self.separator.run(&input) == nil {
        return outputs
      }
    }
    input = rest
    return outputs
  }
}
```

@T(00:40:13)
And we can introduce the `zeroOrMore` method by extending the parser protocol to return an instance of `ZeroOrMore`:

```swift
extension ParserProtocol {
  func zeroOrMore<Separator>(
    separatedBy separator: Separator
  ) -> ZeroOrMore<Self, Separator> {
    .init(upstream: self, separator: separator)
  }
}
```

@T(00:40:23)
And now we can finish our protocol version of the CSV parser by simply changing `.prefix` to `Prefix`:

```swift
let lineProtocol = fieldProtocol
  .zeroOrMore(separatedBy: Prefix(","[...].utf8))
let csvProtocol = lineProtocol
  .zeroOrMore(separatedBy: Prefix("\n"[...].utf8))
```

@T(00:40:36)
Comparing these two CSV parsers side-by-side shows that they are basically the same shapes:

```swift
let plainField = Parser<Substring.UTF8View, Substring.UTF8View>
  .prefix(while: { $0 != .init(ascii: ",") && $0 != .init(ascii: "\n") })
let quotedField = Parser<Substring.UTF8View, Void>.prefix("\""[...].utf8)
  .take(.prefix(while: { $0 != .init(ascii: "\"") }))
  .skip(.prefix("\""[...].utf8))
let field = Parser.oneOf(quotedField, plainField)
let line = field.zeroOrMore(separatedBy: .prefix(","[...].utf8))
let csv = line.zeroOrMore(separatedBy: .prefix("\n"[...].utf8))

…

let plainField = PrefixWhile<Substring.UTF8View> {
  $0 != .init(ascii: ",") && $0 != .init(ascii: "\n")
}
let quotedField = Prefix("\""[...].utf8)
  .take(PrefixWhile { $0 != .init(ascii: "\"") })
  .skip(Prefix("\""[...].utf8))
let field = OneOf(quotedField, plainField)
let line = field.zeroOrMore(separatedBy: Prefix(","[...].utf8))
let csv = line.zeroOrMore(separatedBy: Prefix("\n"[...].utf8))
```

@T(00:40:47)
The protocol version may have even removed a bit of extra noise, which is nice.

@T(00:40:53)
Let's now benchmark this new parser:

```swift
suite.benchmark("ParserProtocol") {
  var input = csvSample[...].utf8
  let output = csvProtocol.run(&input)
  precondition(output!.count == 1000)
  precondition(output!.allSatisfy { $0.count == 5 })
}
```

```txt
running CSV: Parser: Substring... done! (2303.73 ms)
running CSV: Parser: UTF8... done! (1579.55 ms)
running CSV: ParserProtocol... done! (1339.01 ms)
running CSV: Mutating methods... done! (1427.38 ms)
running CSV: Imperative... done! (1315.53 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8118878.500 ns ±  10.16 %        150
CSV.Parser: UTF8      2049882.000 ns ±  12.46 %        627
CSV.ParserProtocol    1149975.000 ns ±  15.88 %        985
CSV.Mutating methods   929586.000 ns ±  18.61 %       1329
CSV.Imperative loop    847062.000 ns ±  18.19 %       1337
Program ended with exit code: 0
```

@T(00:41:09)
OK, very interesting. The protocol style of parsing has provided us a nearly 2x improvement in speed over the `Parser` type, and we're now only 20-30% slower than the ad-hoc, hand-rolled parsers.

## Adding carriage return support

@T(00:41:29)
It's super impressive that we have come within striking distance of the speed of ad-hoc, hand-rolled parsers using the protocol-based combinators. You may be a little disappointed that we don't have a big grand reveal here by somehow getting better performance than the hand-rolled parsers, but let's take a moment to reflect on what we've actually accomplished here.

@T(00:41:53)
What we have right now are essentially three different styles of parsing CSV documents. We have a bunch of ad-hoc mutating methods on `Substring.UTF8View`, a super inlined, unrolled parsers that just linearly iterates over the string while keep track of a bunch of state, and then finally we have parser combinators that represent one small unit of parsing and then they are pieced together to form a large parser.

@T(00:42:17)
The mutating method style is about 20% faster than our combinators, and then the unrolled parser is about 5% faster than the mutating methods. This is the difference of being able to parse about 60 megabytes per second or 80 megabytes per second. If you need to parse hundreds of megabytes of data, then these differences could really add up.

@T(00:42:41)
But there's another dimension to evaluate these pieces of code by, and that's maintainability. Which one are you going to be able to fix bugs quickly and add new features 6 months from now? If the faster code is difficult to maintain, then maybe it's worth taking a 20% speed hit.

@T(00:43:04)
Let's explore this real quick by adding a new feature to our parsers: we are going to recognize both line feed and carriage return plus line feed as ways to delimit rows in a CSV document. Currently we only support line feeds, which makes are parsers quite simple, but we could receive CSV documents from many different types of operating systems which use either flavor of newline.

@T(00:43:39)
Let's start with our simplest parser: the `Substring` parser built with the `Parser` struct. The first parser we need to update is the `plainField` parser because it currently scans characters until it encounters a comma or a newline:

```swift
let plainFieldSubstring = Parser<Substring, Substring>
  .prefix(while: { $0 != "," && $0 != "\n" })
```

@T(00:43:56)
We need to add carriage return plus line feed to this so that we delimit the field properly. Because we are dealing with `Substring` here we know that `$0` is of type `Character`, which is a single grapheme cluster that has been fully normalized. In this abstraction, a carriage return with line feed is a single character, and so we can simply do:

```swift
let plainField = Parser<Substring, Substring>
  .prefix(while: { $0 != "," && $0 != "\n" && $0 != "\r\n" })
```

@T(00:44:33)
Even though it seems like "\r\n" is two characters next to each other, that all gets squashed down to a single character. That is really powerful.

@T(00:44:43)
Next we have the CSV parser, which takes zero or more fields separated by newlines:

```swift
let csv = line.zeroOrMore(separatedBy: "\n")
```

@T(00:44:48)
This too needs to be beefed up to work with carriage returns. What we can do is first try parsing the line feed as the separator, and if that fails we can fallback to trying to parse the carriage return plus line feed:

```swift
let csvSubstring = lineSubstring
  .zeroOrMore(separatedBy: .oneOf("\n", "\r\n"))
```

@T(00:44:55)
Pretty simple again. This is an example of us really being able to lean on `Substring`'s powers to make our parser really simple.

@T(00:45:09)
Before moving on let's make sure it works. Let's add a carriage return to a random row in our CSV sample:

```txt
9789384716165,...,2\r
```

@T(00:45:24)
And the substring CSV parser should properly handle this case. To prove it, let's beef its precondition.

```swift
precondition(
  output!.allSatisfy { $0.count == 5 && $0.last?.last != "\r" }
)
```

@T(00:45:57)
And if we run benchmarks the "Parser: Substring" benchmark does not fail. If we update the UTF-8 precondition...

```swift
precondition(
  output!.allSatisfy {
    $0.count == 5 && $0.last?.last != .init(ascii: "\r")
  }
)
```

@T(00:46:34)
...it _does_ fail, and that's because that parser is not properly handling carriage returns, so let's fix it.

@T(00:46:44)
First we need to fix the `plainField` parser. But things are tricky now. We cannot simply do something similar to what we did for the substring parser:

```swift
let plainFieldUtf8 = Parser<Substring.UTF8View, Substring.UTF8View>
  .prefix(while: {
    $0 != .init(ascii: ",")
      && $0 != .init(ascii: "\n")
      && $0 != .init(ascii: "\r\n")
  })
```

@T(00:47:05)
This is because `"\r\n"` is not a single ASCII code unit. We need a way to simultaneously check two consecutive code units at the same time. There's a chance that we could possible create a custom `.prefix(while:)` combinator that gives us both the current previous code unit so that we could do that logic, but there's a simpler way.

@T(00:47:34)
After parsing a line we can simply detect if the last field of the line has a trailing carriage return. If it does it means the line ended in a `\r\n` and so we should trim that last `\r`:

```swift
let lineUtf8 = fieldUtf8
  .zeroOrMore(separatedBy: .prefix(","[...].utf8))
  .map { fields -> [Substring.UTF8View] in
    var fields = fields
    fields[fields.count - 1].removeLast()
    return fields
  }
```

@T(00:48:29)
And we will only execute this logic if the last field contains a trailing carriage return:

```swift
.map { fields -> [Substring.UTF8View] in
  guard fields.last?.last == .init(ascii: "\r")
  else { return fields }

  var fields = fields
  fields[fields.count - 1].removeLast()
  return fields
}
```

@T(00:48:49)
Now the work we're doing here is a bit messy and we do think it'd be worth cooking up a custom combinator to more declaratively tackle the problem. However, it's also quite amazing that we are able to inject this custom logic with a simple `map` function.

@T(00:49:23)
And that's all we need to do! Unlike the `Substring` parser, we don't need to worry about splitting on `"\r\n"` in `zeroOrMore` because we've already trimmed the carriage returns in the `map`.

@T(00:49:47)
Now when we run benchmarks we get past the "Parser: UTF8" benchmark! But when we introduce the precondition to the protocol benchmark we get stuck. This can be fixed in almost exactly the same way as the previous parser, except we actually don't have the `.map` operator for `ParserProtocol`. We haven't needed it thus far, but it's easy enough to add so we will copy and paste it in:

```swift
struct Map<Upstream, Output>: ParserProtocol
where Upstream: ParserProtocol {
  typealias Input = Upstream.Input
  let upstream: Upstream
  let transform: (Upstream.Output) -> Output

  func run(_ input: inout Input) -> Output? {
    self.upstream.run(&input).map(self.transform)
  }
}

extension ParserProtocol {
  func map<NewOutput>(
    _ transform: @escaping (Output) -> NewOutput
  ) -> Map<Self, NewOutput> {
    .init(upstream: self, transform: transform)
  }
}
```

@T(00:51:23)
And now we can `.map` on the `line` parser:

```swift
let lineProtocol = ZeroOrMore(
  fieldProtocol, separatedBy: Prefix(","[...].utf8)
)
.map { fields -> [Substring.UTF8View] in
  guard fields.last?.last == .init(ascii: "\r")
  else { return fields }

  var fields = fields
  fields[fields.count - 1].removeLast()
  return fields
}
```

@T(00:51:30)
Now when we run benchmarks we get past the parser protocol, but when we update the mutating method benchmark we will get stuck on its precondition. So let's fix it to support carriage returns, as well. The simplest way is to take inspiration from the combinator solution, where we can simply trim it from the line as it's parsed.

```swift
if fields.last?.last == .init(ascii: "\r") {
  fields[fields.count - 1].removeLast()
}
```

@T(00:52:26)
And now that passes, as well!

@T(00:52:40)
We're now on our last parser, the loop CSV parser. This is a tricky one to fix. Since we are considering each code unit at a time in the loop, it's hard to look at two consecutive code units at the same time.

@T(00:53:11)
To do this we need to track some additional state. We need a boolean that lets us know if we are currently inside a carriage return, which we flip to `true` when we encounter a `\r` and flip to false for any other character. We can then use this boolean for when we encounter a `\n` so that we know what to do.

@T(00:53:38)
So let's introduce a new piece of mutable state:

```swift
var isInCarriageReturn = false
```

@T(00:53:45)
Flip it to `true` when we encounter a carriage return:

```swift
case .init(ascii: "\r"):
  isInCarriageReturn = true
```

@T(00:53:50)
And flip it to `false` for all other characters other than newlines:

```swift
case .init(ascii: "\""):
  isInCarriageReturn = false
  …

case .init(ascii: ","):
  isInCarriageReturn = false
  …

default:
  isInCarriageReturn = false
  break
}
```

@T(00:54:09)
When we encounter a `\n` we can check if we are currently in a carriage return, for if we are we need to take one less character from the input when adding it to the results array:

```swift
case .init(ascii: "\n"):
  defer { isInCarriageReturn = false }
  guard !isInQuotes else { continue }

  let newEndIndex = isInCarriageReturn
    ? input.utf8.index(before: endIndex)
    : endIndex

  result[result.endIndex-1].append(
    input.utf8[startIndex ..< newEndIndex]
  )
  startIndex = input.utf8.index(after: endIndex)
  result.append([])
```

@T(00:55:10)
And now when we run we finally get a passing benchmark:

```txt
running CSV: Parser: Substring... done! (2401.73 ms)
running CSV: Parser: UTF8... done! (1560.84 ms)
running CSV: Protocol... done! (1427.59 ms)
running CSV: Mutating methods... done! (1405.55 ms)
running CSV: Imperative... done! (2473.31 ms)

name                  time           std        iterations
----------------------------------------------------------
CSV.Parser: Substring 8476047.000 ns ±  12.06 %        158
CSV.Parser: UTF8      2046065.000 ns ±  14.42 %        613
CSV.ParserProtocol    1229079.000 ns ±  16.30 %        991
CSV.Mutating methods   943130.000 ns ±  16.10 %       1293
CSV.Imperative loop    908423.000 ns ±  18.56 %       1492
Program ended with exit code: 0
```

@T(00:55:21)
All the numbers have gotten a little bit slower, but they are relatively about the same.

@T(00:55:41)
But I think it's pretty clear which of these blocks of code is more maintainable and would be easier to fix bugs and add features to many months in the future. Our combinator parser is only about 15 lines of code, and very succinctly describes how a CSV document is composed.

@T(00:56:11)
The mutating methods are pretty straightforward too, but you are responsible for managing some mutable state and it's not made up of composable pieces.

@T(00:56:31)
And the unrolled loop version is just very cryptic and hard to understand.

## Conclusion

@T(00:56:43)
It's also worth mentioning that these parsers are still not 100% CSV compliant. There are more edge cases to worry about. However, we still feel that these benchmarks are fair because each version parsers the same subset of CSV. It's not like one is doing more work than the others to be more correct, for that would make for an unfair benchmark. Further, the work each is doing is quite similar, just with varying layers of abstraction on top of them. In the loop version we have everything unrolled and inlined, in the mutating methods version we compartmentalize pieces of work into methods, and in the combinator version we compartmentalize pieces into separate values that can be combined together.

@T(00:57:58)
So, we feel that we have really accomplished something pretty great here. We have shown that by combining all of our tricks for eking as much performance as possible out of parser combinators gets us to a place where we are only about 20% slower than more conventional approaches, but the code is much more understandable and easier to maintain. We think this is a big win and means you don't have to be afraid of using parser combinators if performance is a priority for you. They can actually have quite good performance!

@T(00:58:37)
Until next time...
