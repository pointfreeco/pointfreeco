import Foundation

let post0004_overtureSetters = BlogPost(
  author: .brandon,
  blurb: """
Announcing Overture 0.2.0! This release is all about setters: functions that allow us to build complex
transformations out of smaller units.
""",
  contentBlocks: [

    .init(
      content: "",
      timestamp: nil,
      type: .image(src: "https://d1iqsrac68iyd8.cloudfront.net/posts/0004-overture-functional-setters/0004-poster-1.jpg")
    ),

    .init(
      content: """
---

> This week's [episode](https://www.pointfree.co/episodes/ep15-setters-ergonomics-performance) explored providing a friendlier API to functional setters, and improved
their performance by leveraging Swift's value mutation semantics. To make these ideas accessible to everyone
we have updated our [Swift Overture](\(gitHubUrl(to: .repo(.overture)))) library to add these
helper functions and more!

---
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
We released [Swift Overture](\(gitHubUrl(to: .repo(.overture)))), a library for embracing
function composition, a little over a month ago, and the reception has been great! It has helped people
see that function composition is an important tool to have at your disposal, and that Swift has
some really nice features to support composition (generics, free functions, variadics, module namespaces, etc.).

Today we are happy to announce that we've made the first major addition to the Overture since its inception:
functional setters! The first release had the `prop` helper we discussed in
[episode #7](https://www.pointfree.co/episodes/ep7-setters-and-key-paths), which helps lift Swift writeable
key paths into the world of functional setters:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

// ((String) -> String) -> (User) -> User
let userNameSetter = prop(\\User.name)

// ((Int) -> Int) -> (User) -> User
let ageSetter = prop(\\User.age)

// Transforms a user by incrementing their age.
let celebrateBirthday = ageSetter { $0 + 1 }

// Apply multiple transformations to a user.
let user = User(age: 20, name: "Blob")
let newUser = with(user, concat(
  celebrateBirthday,
  userNameSetter { _ in "Older Blob" }
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
That is already really powerful, but as we explored in this [week's episode](https://www.pointfree.co/episodes/ep15-setters-ergonomics-performance), the ergonomics of using
the API isn't quite right, and it creates a copy for each setter application, so its performance could be improved.

In the newest release of [Overture](\(gitHubUrl(to: .repo(.overture)))) we've added more
key path helpers to make the API friendlier:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(age: 20, name: "Blob")
let newUser = with(user, concat(
  over(\\.age) { $0 + 1 },
  set(\\.name, "Older Blob")
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In this snippet we create a user, we use Overture's `over` and `set` helpers to transform a user by mapping
_over_ their age to increment it, then _set_ their name to a new value. The `over` helper takes a function
that transforms existing values, while `set` replaces an existing value with a brand new one.

If this particular snippet happen to be in a performance critical code path we might be a little wary of
having to create two copies of the user to apply these transformations, one for the `over` and another for
the `set`. Fortunately with a very small tweak we can fuse the two transformations into a single copy and mutation!
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(age: 20, name: "Blob")
let newUser = with(user, concat(
  mver(\\.age) { $0 += 1 },
  mut(\\.name, "Older Blob")
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
The `mver` and `mut` helpers are mutating versions of `over` and `set`. In our example, we need to update our
first setter to use in-place mutation: we merely swap `+` for `+=`. Our second setter requires no changes
other than updating `set` to `mut`. We can read this as: mutate over (`mver`) the user's age and add one to
it, then mutate (`mut`) the user's name to `"Older Blob"`.

This means it's super simple to opt in and out of mutation whenever you see fit.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "More complicated setters",
      timestamp: nil,
      type: .title
    ),

    .init(
      content: """
There's one type of setter that we've covered a lot in our episodes (see
[episode #7](https://www.pointfree.co/episodes/ep7-setters-and-key-paths)), and that's the `map`
setter on arrays and optionals. It is precisely what allows you to dive deeper into those structures and
make transformations while leaving everything else fixed. In our episodes we have used the backwards
composition operator `<<<` in order to facilitate this, but in Overture we can use `compose`:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(
  age: 20,
  favoriteFoods: ["Tacos", "Nachos"],
  name: "Blob"
)

let newUser = with(user, concat(
  over(\\.age) { $0 + 1 },
  set(\\.name, "Older Blob"),
  over(compose(prop(\\.favoriteFoods), map)) { $0 + " & Salad" }
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In this snippet we have `compose`d the setter `prop(\\.favoriteFoods)` with the `map` setter so that we
can dive into that array and then apply the transformation `$0 + " & Salad"` (ole Blob is getting older
and needs to eat healthier 🙂).

This is already super impressive, but we are now creating 3 copies of the user to apply these
transformations. Amazingly, we can make a few small changes and do all of this work with a single fused
transformation that operates on one copy of the user:
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(
  age: 20,
  favoriteFoods: ["Tacos", "Nachos"],
  name: "Blob"
)

let newUser = with(user, concat(
  mver(\\.age) { $0 += 1 },
  mut(\\.name, "Older Blob"),
  mver(compose(mprop(\\.favoriteFoods), mutEach)) { $0 += " & Salad" }
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In the last transformation we "mutate over" (`mver`) the user's favorite foods (`mprop(\\.favoriteFoods)`)
and then mutate each (`mutEach`) food. All of this work happens in place on one single copy of the user.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "🎼 Overture",
      timestamp: nil,
      type: .title
    ),

    .init(
    content: """
This is only the beginning of Overture and functional setters. We will be making more episodes,
posting more content on [Point-Free Pointers](\(url(to: .blog(.index)))), and improving the Overture to
be the most versatile Swiss army knife of function composition in Swift. Stay tuned!
""",
    timestamp: nil,
    type: .paragraph
    ),

  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0004-overture-functional-setters/0004-poster-1.jpg",
  id: 4,
  publishedAt: .init(timeIntervalSince1970: 1_526_291_823 + 60*60*24),
  title: "Overture: Now with Functional Setters"
)
