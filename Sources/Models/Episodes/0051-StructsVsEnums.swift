import Foundation

extension Episode {
  static let ep51_structs🤝Enums = Episode(
    blurb: """
Name a more iconic duo... We'll wait. Structs and enums go together like peanut butter and jelly, or multiplication and addition. One's no more important than the other: they're completely complementary. This week we'll explore how features on one may surprisingly manifest themselves on the other.
""",
    codeSampleDirectory: "0051-structs-🤝-enums",
    exercises: _exercises,
    id: 51,
    image: "https://i.vimeocdn.com/video/801299196.jpg",
    length: 30*60 + 50,
    permission: .subscriberOnly,
    publishedAt: .init(timeIntervalSince1970: 1553493600),
    references: [
      reference(
        forEpisode: .ep4_algebraicDataTypes,
        additionalBlurb: """
Our introductory episode on algebraic data types. We introduce how structs and enums are like multiplication and addition, and we explore how this correspondence allows us to refactor our data types, simplify our code, and eliminate impossible states at compile time.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep4-algebraic-data-types"
      ),
      .init(
        author: nil,
        blurb: """
TypeScript has a feature closely related to enums and anonymous sum types. It is called "union types", and it also allows you to express the idea of choosing between many different types.
""",
        link: "https://www.typescriptlang.org/docs/handbook/advanced-types.html#union-types",
        publishedAt: nil,
        title: "TypeScript: Advanced Types"
      ),
      .init(
        author: "Marius Schulz",
        blurb: """
TypeScript's type system is also flexible enough to emulate's Swift's enums, but anonymously! Swift enums are sometimes called "variants" or "tagged unions" because each case is "tagged" with a label: for instance, the `Optional` type is tagged with `some` and `none`.
""",
        link: "https://mariusschulz.com/blog/typescript-2-0-tagged-union-types",
        publishedAt: Date(timeIntervalSince1970: 1478145600),
        title: "TypeScript 2.0: Tagged Union Types"
      ),
      .init(
        author: "Waleed Khan",
        blurb: """
An in-depth look at the differences between sum types and union types.
""",
        link: "https://waleedkhan.name/blog/union-vs-sum-types/",
        publishedAt: Date(timeIntervalSince1970: 1500868800),
        title: "Null-tracking, or the difference between union and sum types"
      ),
      .init(
        author: "Yehonathan Sharvit",
        blurb: """
OCaml supports anonymous sum types in the form of "polymorphic variants," which can describe a single, tagged case at a time.
""",
        link: "https://blog.klipse.tech/ocaml/2018/03/16/ocaml-polymorphic-types.html",
        publishedAt: Date(timeIntervalSince1970: 1521172800),
        title: "Polymorphic vs. ordinary variants in ocaml"
      ),
      .init(
        author: "Matt Diephouse",
        blurb: """
A Swift community Twitter thread about anonymous sum types.
""",
        link: "https://twitter.com/mdiep/status/877936255920619521",
        publishedAt: Date(timeIntervalSince1970: 1498104000),
        title: "Tuple : Struct :: ? : Enum"
      ),
    ],
    sequence: 51,
    title: "Structs 🤝 Enums",
    trailerVideo: .init(
      bytesLength: 51666137,
      downloadUrl: "https://player.vimeo.com/external/349952494.hd.mp4?s=4edb86b631067c4e36fdbd12c5a2ea4f53b896a5&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349952494"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
A nice feature that Swift structs have is "properties." You can access the fields inside the struct _via_ dot syntax, for example `view.frame.origin.x`. Enums don't have this feature, but try to explain what the equivalent feature would be.
"""
  ),
  .init(
    problem: """
Swift enums are sometimes called "tagged unions" because each case is "tagged" with a name. For instance, `Optional` tags its wrapped value with the `some` case, and tags the absence of a value with `none`. This is in contrast to "union" types, which merely describe the idea of choosing between many types, _e.g._ an optional string can be expressed as `string | void`, and a number _or_ a string can be expressed as `number | string`.

What can an tagged union do that a union _can't_ do? How might `string | void | void` be evaluated as a union _vs._ how might it be represented as an enum?
"""
  ),
  .init(
    problem: """
The `Either` type we use in this episode is the closest to an anonymous sum type that we get in Swift as it has no semantics, but it only supports two cases. What are some ways of supporting an "anonymous" sum of three cases? What about four? Or more? Is it possible to support three or more cases using _just_ the `Either` type?
"""
  ),
]
