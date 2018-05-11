import Foundation

let post0004_overtureSetters = BlogPost(
  author: .brandon,
  // TODO: this blurb is for twitter, so maybe it should be a bit shorter
  blurb: """
This week’s episode explored providing a friendlier API to functional setters, and improved their
performance by leveraging Swift’s value mutation semantics. To make these ideas accessible to everyone
we have updated our Overture library to add these helper functions and more!
""",
  contentBlocks: [
    .init(
      content: """
> This week’s [episode](TODO) explored providing a friendlier API to functional setters, and improved
their performance by leveraging Swift’s value mutation semantics. To make these ideas accessible to everyone
we have updated our [Swift Overture](\(gitHubUrl(to: .repo(.overture)))) library to add these
helper functions and more!

---

We released [Swift Overture](\(gitHubUrl(to: .repo(.overture)))), a library for embracing
function composition, a little over a month ago, and the reception has been great! It has helped people
see that function composition is an important tool to have at your disposal, and that Swift actually has
some really nice features to support composition (generics, free functions, variadics, etc.).

Today we are happy to announce that we have made the first major addition to the Overture since its initial
release: functional setters! The first release had the `prop` helper we discussed in
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
let celebrateBirthday = ageSetter(incr)

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
That is already really powerful, but as we explored in this [week’s episode](TODO), the ergonomics of using
the API is quite right, and it creates a copy for each setter, so it could be more performant.

So, in the newest release of [Overture](\(gitHubUrl(to: .repo(.overture)))) we have added more
key path helpers to make the API friendlier:

TODO: the over/set/mver/mut helpers are all gonna take key paths in Overture right?
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(age: 20, name: "Blob")
let newUser = with(user, concat(
  over(\\.age, incr),
  set(\\.name, "Older Blob")
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In this snippet we create a user, and then transform that user by mapping over their age to increment it,
and then set their name to a new value. The `over` and `set` helpers… TODO

If this particular snippet happen to be in a performance critical code path we might be a little wary of
having to create two copies of the user to apply these transformations, one for the `over` and another for
the `set`. Fortunately with a very small tweak we can fuse the two transformations into a single copy and mutation!


TODO: I dont actually know what the API is gonna look like in overture so just sketching something
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: """
import Overture

let user = User(age: 20, name: "Blob")
let newUser = with(user, concat(
  mver(\\.age, incr),
  mut(\\.name, "Older Blob")
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
This means it’s super simple to opt in and out of mutation whenever you see fit.
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
There’s one type of setter that we’ve covered a lot in our episodes (see
[episode #7]((https://www.pointfree.co/episodes/ep7-setters-and-key-paths))), and that’s the `map`
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
  over(\\.age, incr),
  set(\\.name, "Older Blob"),
  over(compose(prop(\\.favoriteFoods), map)) { $0 + " & Salad" }
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In this snippet we have `compose`'d the setter `prop(\\.favoriteFoods)` with the `map` setter so that we
can dive into that array and then apply the transformation `$0 + " & Salad"` (ole Blob is getting older
and so needs to eat healthier 🙂).

This is already super impressive, but we are now creating 3 copies of the user to apply these
transformations. Amazingly, we can make a few small changes and do all of this work with a single fused
transformation that operates on one copy of the user:

TODO: I also don’t know if this is correct, but just sketching…
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
  mver(\\.age, incr),
  mut(\\.name, "Older Blob"),
  mver(concat(prop(\\.favoriteFoods), mutEach)) { $0 + " & Salad" }
))
""",
      timestamp: nil,
      type: .code(lang: .swift)
    ),

    .init(
      content: """
In the last transformation we “mutate over” (`mver`) the user’s favorite foods (`prop(\\.favoriteFoods)`)
and then mutate each food (`mutEach`). All of this work happens in place on one single copy of the user.
""",
      timestamp: nil,
      type: .paragraph
    ),

    .init(
      content: "Overture",
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
  // Here is a carbon image we could use. To add to S3 do:
  //
  // https://carbon.now.sh/?bg=rgba(121,242,176,1)&t=duotone-dark&wt=none&l=swift&ds=true&dsyoff=20px&dsblur=33px&wc=true&wa=true&pv=65px&ph=61px&ln=false&fm=Hack&fs=18px&si=false&code=import%2520Overture%250A%250Alet%2520user%2520%253D%2520User(age%253A%252020%252C%2520name%253A%2520%2522Blob%2522)%250A%250A%252F%252F%2520Transform%2520user%2520inline%250Alet%2520newUser%2520%253D%2520with(user%252C%2520concat(%250A%2520%2520over(%255C.age%252C%2520incr)%252C%250A%2520%2520set(%255C.name%252C%2520%2522Older%2520Blob%2522)%250A))%250A%250A%252F%252F%2520Extract%2520transformation%250Alet%2520celebrateBirthday%2520%253D%2520concat(%250A%2520%2520over(%255CUser.age%252C%2520incr)%252C%250A%2520%2520set(%255C.name%252C%2520%2522Older%2520Blob%2522)%250A)%250Alet%2520newUser%2520%253D%2520with(user%252C%2520celebrateBirthday)&es=2x&wm=false
  //
  // * Add to bucket https://s3.amazonaws.com/pointfreeco-blog/posts/0004-overture-functional-setters
  // * Make public
  // * Use cloudfront url
  coverImage: "TODO",
  id: 4,
  publishedAt: .init(timeIntervalSince1970: 1_526_291_823),
  title: "Overture: Now with Functional Setters"
)
