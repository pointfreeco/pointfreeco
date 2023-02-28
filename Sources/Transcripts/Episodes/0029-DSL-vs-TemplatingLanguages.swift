import Foundation

extension Episode {
  static let ep29_dslsVsTemplatingLanguages = Episode(
    blurb: """
      Templating languages are the most common way to render HTML in web frameworks, but we don't think they \
      are the best way. We compare templating languages to the DSL we previously built, and show that \
      the DSL fixes many problems that templates have, while also revealing amazing compositions that were \
      previously hidden.
      """,
    codeSampleDirectory: "0029-dsls-vs-templating-languages",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 476_109_800,
      downloadUrls: .s3(
        hd1080: "0029-1080p-fe9bbd82f00d455db867ce9e7b179dfa",
        hd720: "0029-720p-b02cb4cd722a4fe5bba1db2b94c88fac",
        sd540: "0029-540p-cb45617a087f4d56b07d72f15d0dee1f"
      ),
      vimeoId: 351_397_245
    ),
    id: 29,
    length: 33 * 60 + 17,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_536_559_023),
    references: [.openSourcingSwiftHtml],
    sequence: 29,
    title: "DSLs vs. Templating Languages",
    trailerVideo: .init(
      bytesLength: 47_720_856,
      downloadUrls: .s3(
        hd1080: "0029-trailer-1080p-80ecf6f5a4aa447097817210814b9442",
        hd720: "0029-trailer-720p-0d397593d6c34a51b5a887cf27f6109e",
        sd540: "0029-trailer-540p-7c192a32291045c2ac05321fe1de3947"
      ),
      vimeoId: 351_396_562
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 29)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      In this episode we expressed a lot of HTML “views” as just plain functions from some data type into the
      `Node` type. In past episodes we saw that functions `(A) -> B` have both a `map` and `contramap` defined, the
      former corresponding to post-composition and the latter pre-composition. What does `map` and `contramap`
      represent in the context of an HTML view `(A) -> Node`?
      """),

  .init(
    problem: """
      When building a website you often realize that you want to be able to reuse an outer "shell" of a view,
      and plug smaller views into it. For example, the header, nav and footer would consist of the "shell", and
      then the content of your homepage, about page, contact page, etc. make up the inside. This is a kind of
      "view composition", and most templating languages provide something like it (Rails calls it layouts,
      Stencil calls it inheritance).

      Formulate what this form of view composition looks like when you think of views as just functions of the
      form `(A) -> Node`.
      """),

  .init(
    problem: """
      In previous episodes on this series we have discussed the `<>` (diamond) operator. We have remarked that this
      operator comes up anytime we have a nice way of combining two values of the same type together into a third
      value of the same type, i.e. functions of the form `(A, A) -> A`.

      Given two views of the form `v, w: (A) -> [Node]`, it is possible to combine them into one view. Define
      the diamond operator that performs this operation: `<>: ((A) -> [Node], (A) -> [Node]) -> (A) -> [Node]`.
      """),

  .init(
    problem: """
      Right now any node is allowed to be embedded inside any other node, even though certain HTML semantics
      forbid that. For example, the list item tag `<li>` is only allowed to be embedded in unordered lists `<ul>`
      and ordered lists `<ol>`. We can't enforce this property through the `Node` type, but we can do it through
      the functions we define for constructing tags. The technique uses something known as _phantom types_, and it's
      similar to what we did in our [`Tagged`](/episodes/ep12-tagged) episode. Here is a series of exercises to show
      how it works:

        * First define a new `ChildOf` type. It's a struct that simply wraps a `Node` value, but most importantly
      it has a generic `<T>`. We will use this generic to control when certain nodes are allowed to be embedded
      inside other nodes.
        * Define two new types, `Ol` and `Ul`, that will act as the phantom types for `ChildOf`. Since we do not
      care about the contents of these types, they can just be simple empty enums.
        * Define a new protocol, `ContainsLi`, and make both `Ol` and `Ul` conform to it. Again, we don't care
      about the contents of this protocol, it is only a means to tag `Ol` and `Ul` as having the property that
      they are allowed to contain `<li>` elements.
        * Finally, define three new tag functions `ol`, `ul` and `li` that allow you to nest `<li>`'s inside
      `<ol>`'s and `<ul>`'s but prohibit you from putting `li`'s in any other tags. You will need to use the
      types `ChildOf<Ol>`, `ChildOf<Ul>` and `ContainsLi` to accomplish this.
      """),

]
