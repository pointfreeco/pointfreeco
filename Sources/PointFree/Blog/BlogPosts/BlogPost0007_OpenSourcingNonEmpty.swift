import Foundation

let post0007_openSourcingNonEmpty = BlogPost(
  author: .brandon,
  blurb: """
Today we are open sourcing NonEmpty, a Swift library for modeling non-empty collection types. This small
library can help make your code safer and more expressive with very little work.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0007-open-sourcing-nonempty/poster.jpg")
    ),

    .init(
      content: """
---

> Today we are open sourcing [NonEmpty](\(gitHubUrl(to: .repo(.nonempty)))), a Swift library for modeling
non-empty collection types. This small library can help make your code safer and more expressive with very
little work.

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
We often work with collections that we know should _never_ be empty, but the types we are given in the Swift
standard library make no such guarantees. To compensate, we must sprinkle `if`'s and `guard`'s into our code
so that we can protect against the case that we know should be impossible.

We've explored the concept of "algebraic data types" a few times on this series, and it's a topic almost
entirely devoted to the endeavor of making "impossible states unrepresentable" by the compiler. Our most
recent [episode](\(url(to: .episode(.left("20-nonempty"))))) even showed how we could use algebra to
naturally lead us to a type that gives us compile-time guarantees that a collection can never be empty.

We believe that a compiler proven non-empty type is incredibly important for every developer to have at
their disposal, and so that's why today we are open sourcing our
[NonEmpty](\(gitHubUrl(to: .repo(.nonempty)))) library.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "NonEmpty",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
The core of the library is just a single generic type, `NonEmpty<C>`, which allows you to transform any
collection type `C` into a non-empty version of itself. The majority of the code in the library consists
of conformances on `NonEmpty` to make it act as much like the collection that it wraps.

Using `NonEmpty` it is very easy to model an array that is provable to _never_ be empty:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let xs = NonEmpty<[Int]>(1, 2, 3, 4)
xs.forEach { print($0) }  // 1, 2, 3, 4
xs.first + 1              // 2
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Notice that in the last line we are adding `1` directly to `xs.first`. That is possible because with the
`NonEmpty` type `first` actually returns a non-optional since it is guaranteed to produce a value, and
therefore we do not even have to think about the `nil` case.

We are not limited to only creating non-empty arrays. We can also create non-empty versions of other
collections in the standard library, like sets!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let ys = NonEmpty<Set<Int>>(1, 1, 2, 2, 3, 4)
xs.forEach { print($0) } // 1, 2, 3, 4
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
But why stop at sets? We can also model non-empty dictionaries:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let zs = NonEmptyDictionary<String, Int>(
  ("one", 1), ["two": 2, "three": 3]
)
zs["one"]  // .some(1)
zs["four"] // .none
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Heck, we may not think of things like this often, but even `String` is a collection. We can make non-empty
strings!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let greeting = NonEmpty<String>("H", "ello World")
print("\\(greeting)!") // "Hello World!"
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
All of these collections are _proven_, by the compiler, to always contain at least one value. We no longer
have to `guard` against an empty collection or worry about sending invalid data to an API. The compiler is
keeping us in check.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Applications",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
There are many applications of non-empty collection types, but it can be hard to see since the Swift standard
library does not give us this type. We don't often think about whether or not a non-empty array would be
more appropriate than a potentially empty array.

Here are just a few such applications:

### `groupBy`

We often reach for arrays in our API design because that is what we have at hand, but many times it can
be strenghtened to a non-empty array. For example, consider implementing a `groupBy` function on `Sequence`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Sequence {
  func groupBy<A>(_ f: (Element) -> A) -> [A: [Element]] {
    var result: [A: [Element]] = [:]
    for element in self {
      let key = f(element)
      if result[key] == nil {
        result[key] = [element]
      } else {
        result[key]?.append(element)
      }
    }
    return result
  }
}

Array(1...10)
  .groupBy { $0 % 3 }
// [0: [3, 6, 9], 1: [1, 4, 7, 10], 2: [2, 5, 8]]
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The implementation is pretty straightforward, and it works well enough. However, can the `[Element]` array
inside the return ever be empty? What key value in `A` could even be associated with an empty array? The
only way to generate `A` values is from `Element` values.

Indeed, the `[Element]` array can _never_ be empty, but the API isn't letting us know that. So in our code,
when we interact with this array we are invariably going to have to deal with its potential emptiness.

Let's strengthen this API by using `NonEmpty`!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Sequence {
  func groupBy<A: Hashable>(_ f: (Element) -> A) -> [A: NonEmpty<[Element]>] {
    var result: [A: NonEmpty<[Element]>] = [:]
    for element in self {
      let key = f(element)
      if result[key] == nil {
        result[key] = NonEmpty(element)
      } else {
        result[key]?.append(element)
      }
    }
    return result
  }
}

Array(1...10)
  .groupBy { $0 % 3 }
// [0: [3, 6, 9], 1: [1, 4, 7, 10], 2: [2, 5, 8]]
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We didn't have to change much in the implementation, we get essentially the same output, but the API is
describing more about the data it returns now.

### Random Values

Swift 4.2 introduces a new random API, and apart of the API is the ability to get a random value from a
collection:

""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
[1, 2, 3, 4].randomElement() // .some(2)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Notice that the API returns an optional, and that is necessary because the array could have been empty.
But, we see right here it is definitely _not_ empty. We have provided the values right inline with an
array literal. And computing random values like this, with an inline array literal, is quite common,
so it'd be nice if we could avoid the optional since it's obvious the array is non-empty. And we can!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
NonEmptyArray(1, 2, 3, 4).randomElement() // 2
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The random API will return non-optional values when operating on the `NonEmpty` type.

### GraphQL

[GraphQL](https://graphql.org/) is a query language for APIs that's getting more and more popular. We might
write a client that generates a query from a list of fields for a GraphQL type, and we may default to using a
plain ole array or set since that’s what’s available to us in the standard library. Here's an example of
a very simple fieldset and query builder:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum UserField: String {
  case id, name, email
}

func query(_ fields: Set<UserField>) -> String {
  return (["{"] + fields.map { "\\($0.rawValue)" } + ["}"])
    .joined(separator: " ")
}

print(query([.name, .email]))
// { name email }

print(query([]))
// { }
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This last line is a programmer error and makes an invalid GraphQL query. GraphQL requires at least one
field be provided. So, the server will reject it with an error and now the client has to handle this case.

It would have been better to use a `NonEmptySet` instead of a plain `Set`. Amazingly the implementation of
`query` doesn't need to change, just the call site:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func query(_ fields: NonEmptySet<UserField>) -> String {
  return (["{"] + fields.map { "\\($0.rawValue)" } + ["}"])
    .joined(separator: " ")
}

print(query(.init(.name, .email)))
// { name email }

print(query(.init()))
// 🛑 Compile error
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We now have the compiler proving to us that it is impossible to generate an invalid GraphQL query of this
form.

### `Validated`

Let's do one more just to show how often these non-empty types pop up in every day coding!

The `Result` type is quite popular in the Swift community, and it's useful for distinguishing a successful
value from a failure.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Result<Value, Error> {
  case success(Value)
  case failure(Error)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
There's a specialization of the `Result` type that is useful and popular enough to warrant it having a new
name. It's called `Validated`, and it represents a value that has gone through some validation process. It
is either valid with the value produced, or it is invalid with a list of validation errors:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Validated<Value, Error> {
  case valid(Value)
  case invalid([Error])
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This is handy because now when validations fail we get to supply everything that went wrong, not just a
single error:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validatedPassword: Validated<String, String> = .invalid([
  "Password too short.",
  "Password must contain at least one number."
])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
However, our choice of `[Error]` for the `.invalid` case is not quite right. We chose it because that's what
we have at hand in the Swift standard library, but what would it mean to have an empty array of validation
errors?
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validatedPassword: Validated<String, String> = .invalid([])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
It says its invalid, but the array of errors is empty. So… does that mean it's valid? But… there's no value
provided so it can't be valid? 🤔

What we really wanted to do was use a non-empty array!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Validated<Value, Error> {
  case valid(Value)
  case invalid(NonEmpty<[Error]>)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now it's impossible to get into the weird state of an invalid value with no validation errors.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
Conclusion
""",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
We have now see 4 applications of the `NonEmpty` type, but there are so many more. We encourage the reader
to start looking critically at their own application code, their library APIs and their interactions with
other APIs to see where non-empty types might be appropriate. By pushing the non-emptiness requirement to
the type level you get to enforce this invariant in a single place rather than sprinkle `if`'s and `guard`'s
into your code.

If you want to give `NonEmpty` a spin, then check out our
[open source repo](\(gitHubUrl(to: .repo(.nonempty)))).
""",
      timestamp: nil,
      type: .paragraph
    ),
  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0007-open-sourcing-nonempty/poster.jpg",
  id: 7,
  publishedAt: .init(timeIntervalSince1970: 1_529_920_623),
  title: "Open Sourcing NonEmpty"
)
