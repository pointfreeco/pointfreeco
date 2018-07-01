import Foundation

let post0008_conditionalCoding = BlogPost(
  author: .stephen,
  blurb: """
TODO
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "") // TODO
    ),

    .init(
      content: """
---

> TODO

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
Swift 4 introduced the [`Codable`](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) set of protocols and made working with JSON a breeze, eliminating the need for a lot of boilerplate! Swift 4.1's [conditional conformance](https://swift.org/blog/conditional-conformance/) unlocks even more potential, and lets us delete even more boilerplate. Let's take a look at one particular example.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Expandable APIs",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
Many APIs let clients fetch more data in fewer requests by specifying a means of including related resources. For example, the Stripe API supports [expanding objects](https://stripe.com/docs/api#expanding_objects) inline where by default the response would merely return an identifier. We could represent the idea of an expandable object using the following type:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Expandable<Object: Decodable> {
  case id(String)
  case expanded(Object)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
And we could conform this type to `Decodable`, capturing the ability to decode either an identifier or an expanded value depending on the payload:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Expandable: Decodable {
  init(decoder: Decoder) throws {
    do {
      self = .id(try String(decoder: decoder))
    } catch {
      self = .expanded(try Object(decoder: decoder))
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now we can specify a variety of decodable types with expandable properties.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
struct Customer: Decodable {
  let id: String
  let email: String
}

struct Invoice {
  let id: String
  let customer: Expandable<Customer>
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This is a perfectly fine, ad hoc solution to the problem, but there's a much more general, reusable approach we could have taken.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Generalizing with Either",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
Our `Expandable` type is a specialization of another type that's typically called `Either` and defined as such:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
enum Either<Left, Right> {
  case left(Left)
  case right(Right)
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We could have even used this `Either` type to define `Expandable` using a type alias:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
typealias Expandable<Object>
  = Either<String, Object> where Object: Decodable
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
`Either` doesn't conform to `Decodable`, so we've lost the ability to use this version of `Expandable` in our decodable types, but we can recover this loss in Swift 4.1 using conditional conformance! `Either` can conform to `Decodable` as long as its associated types are decodable.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
extension Either: Decodable where Left: Decodable, Right: Decodable {
  init(decoder: Decoder) throws {
    do {
      self = .left(try Left(decoder: decoder))
    } catch {
      self = .right(try Right(decoder: decoder))
    }
  }
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Now we've fully generalized the idea of decoding different kinds of values!

What's this kind of decoding good for other than expandable properties? Well, any time we expect to decode _either_ one type _or_ another, we can use `Either`. This means we can decode API errors alongside the data types we expect. Given a struct that represents an API error:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
struct StripeError: Decodable {
  let message: String
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
We can now conditionally decode the data type we expect _or_ an API error!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
try decoder.decode(
  Either<Invoice, StripeError>.self,
  from: data
)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
It's pretty amazing that we were able to reuse our generalized solution for `Expandable` for a totally different use case. We didn't have to write any more custom decoding logic: `Either` works like an `if`—`else` statement for decoding.

That's two examples. How about a third one for good luck?
""",
      timestamp: nil,
      type: .paragraph
    ),


    .init(
      content: "Data Migration",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
It's very common to save app state to disk and decode it when the app launches. Sometimes, this format changes over time, and older client data needs to be migrated to the new format. If this decoding is handled with `Decodable`, we can capture some of this conditional logic automatically!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let appData = try decoder.decode(Either<AppData, LegacyAppData>.self, from: data)
switch appData {
case let .left(appData):
  // handle app data
case let .right(legacyAppData):
  // migrate legacy app data
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: "Conclusion",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
Conditional conformance gives us the ability to eliminate even _more_ decoding boilerplate in a completely general, reusable way. If you want to look at some real-world code, Point-Free uses this technique in [our Stripe client](https://github.com/pointfreeco/pointfreeco/blob/42d57452cbd346666931e2c6a040466f8084cf1b/Sources/PointFree/Stripe.swift#L233)!
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "", // TODO
  id: 8,
  publishedAt: .init(timeIntervalSince1970: 1_530_525_423),
  title: "Conditional Coding"
)
