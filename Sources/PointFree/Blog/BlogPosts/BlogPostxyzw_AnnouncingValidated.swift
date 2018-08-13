import Foundation

let postxywz_openSourcingValidated = BlogPost(
  author: .stephen,
  blurb: """
Today we are open sourcing Validated, a Swift library for handling multiple errors: functionality that you don't get from throwing functions and the Result type.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "TODO: poster")
    ),

        .init(
      content: """
---

> Today we are open sourcing [Validated](\(gitHubUrl(to: .repo(.validated)))), a Swift library for handling multiple errors: functionality that you don't get from throwing functions and the Result type.

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
Here we've combined a few throwing functions into a single throwing function that returns a `User`.
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
If any one of `id`, `email`, or `name` are invalid, an error is thrown.
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
      content: "Validated",
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
`Validated` provides a function, `zip(with:)`, which is responsible for converting a function that takes raw inputs into a function that takes validated inputs.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validateUser = Validated<User, String>.zip(with: User.init)
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In this case, we've created a brand new function, `validateUser`, from `User.init`, where `validateUser` operates with validated values.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
// User.init                          // validateUser
// (                                  // (
//   Int,                             //   Validated<Int, String>,
//   String                           //   Validated<String, String>,
//   String                           //   Validated<String, String>
// )                                  // )
// -> User                            // -> Validated<User, String>
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
Valid inputs yield a user wrapped in the `valid` case.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validatedUser = validateUser(
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
An invalid input yields an error in the `invalid` case.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
let validatedUser = validateUser(
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
let validatedUser = validateUser(
  validate(id: -1),
  validate(email: "blob@pointfree.co"),
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
If you want to give `Validated` a spin, then check out our
[open source repo](\(gitHubUrl(to: .repo(.validated)))).
""",
      timestamp: nil,
      type: .paragraph
    ),

  ],
  coverImage: "TODO",
  id: 9, // TODO
  publishedAt: .init(timeIntervalSince1970: 1_532_944_623), // TODO
  title: "Open Sourcing Validated"
)
