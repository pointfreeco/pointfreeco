import Foundation

let post0014_openSourcingValidated = BlogPost(
  author: .stephen,
  blurb: """
Today we are open sourcing Validated, a tiny functional Swift library for handling multiple errors: functionality that you don't get from throwing functions and the Result type.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0014-open-sourcing-validated/poster.png")
    ),

        .init(
      content: """
---

> Today we are open sourcing [Validated](\(gitHubUrl(to: .repo(.validated)))), a tiny functional Swift library for handling multiple errors: functionality that you don't get from throwing functions and the Result type.

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
Swift error handling short-circuits on the first failure. Because of this, it's not the greatest option for handling things like form data, where multiple inputs may result in multiple errors.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
struct User {
  let id: Int
  let email: String
  let name: String
}

func validate(id: Int) -> Int throws {
  guard id > 0 else {
    throw Invalid.error("id must be greater than zero")
  }
  return id
}

func validate(email: String) -> String throws {
  guard email.contains("@") else {
    throw Invalid.error("email must be valid")
  }
  return email
}

func validate(name: String) -> String throws {
  guard !name.isEmpty else {
    throw Invalid.error("name can't be blank")
  }
  return name
}

func validateUser(id: Int, email: String, name: String) throws -> User {
  return User(
    id: try validate(id: id),
    email: try validate(id: email),
    name: try validate(id: name)
  )
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Here we've combined a few throwing functions into a single throwing function that may return a `User`.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let user = try validateUser(id: 1, email: "blob@pointfree.co", name: "Blob")
// User(id: 1, email: "blob@pointfree.co", name: "Blob")
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
If the `id`, `email`, or `name` are invalid, an error is thrown.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let user = try validateUser(id: 1, email: "blob@pointfree.co", name: "")
// throws Invalid.error("name can't be blank")
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Unfortunately, if several or all of these inputs are invalid, the first error wins.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let user = try validateUser(id: -1, email: "blobpointfree.co", name: "")
// throws Invalid.error("id must be greater than zero")
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: "Handling multiple errors with Validated",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
`Validated` is a [`Result`](https://github.com/antitypical/Result)-like type that can accumulate multiple errors. Let's redefine our validation functions using `Validated`.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
func validate(id: Int) -> Validated<Int, String> {
  return id > 0
    ? .valid(id)
    : .error("id must be greater than zero")
}

func validate(email: String) -> Validated<String, String> {
  return email.contains("@")
    ? .valid(email)
    : .error("email must be valid")
}

func validate(name: String) -> Validated<String, String> {
  return !name.isEmpty
    ? .valid(name)
    : .error("name can't be blank")
}
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
To accumulate errors, we use a function that we may already be familiar with: `zip`.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validInputs = zip(
  validate(id: 1),
  validate(email: "blob@pointfree.co"),
  validate(name: "Blob")
)
// Validated<(Int, String, String), String>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The `zip` function on `Validated` works much the same way it works on sequences, but rather than zipping a pair of sequences into a sequence pairs, it zips up a group of single `Validated` values into single `Validated` value of a group.

From here, we can use another function that we may already be familiar with, `map`, which takes a transform function and produces a new `Validated` value with its valid case transformed.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validUser = validInputs.map(User.init)
// valid(User(id: 1, email: "blob@pointfree.co", name: "Blob"))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
For ergonomics, a `zip(with:)` function is provided that takes both a transform and `Validated` inputs at once.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
zip(with: User.init)(
  validate(id: 1),
  validate(email: "blob@pointfree.co"),
  validate(name: "Blob")
)
// valid(User(id: 1, email: "blob@pointfree.co", name: "Blob"))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Valid inputs yield a user wrapped in the `valid` case.

Meanwhile, an invalid input yields an error in the `invalid` case.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
zip(with: User.init)(
  validate(id: 1),
  validate(email: "blob@pointfree.co"),
  validate(name: "")
)
// invalid(["name can't be blank"])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
More importantly, multiple invalid inputs yield an `invalid` case with multiple errors.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
zip(with: User.init)(
  validate(id: -1),
  validate(email: "blobpointfree.co"),
  validate(name: "")
)
// invalid([
//   "id must be greater than zero",
//   "email must be valid",
//   "name can't be blank"
// ])
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Invalid errors are held in a [non-empty array](https://github.com/pointfreeco/swift-nonempty.git) to provide a compile-time guarantee that you will never encounter an empty `invalid` case.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Conclusion",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
That's about all there is to Validated! It's a tiny API that mostly mirrors one you may already be familiar with, `zip` and `map`, and are precisely what we need to describe the notion of error accumulation.

If you want to give it a spin, check out our
[open source repo](\(gitHubUrl(to: .repo(.validated)))).
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0014-open-sourcing-validated/poster.png",
  id: 14,
  publishedAt: .init(timeIntervalSince1970: 1534485423),
  title: "Open Sourcing Validated"
)
