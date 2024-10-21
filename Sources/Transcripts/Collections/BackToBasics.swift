extension Episode.Collection {
  public static let backToBasics = Self(
    blurb: #"""
      The Swift language has grown over the years and become more and more powerful. It now boosts
      a comprehensive static type system (generics, existentials…), a suite of concurrency tools
      (actors, dynamic isolation…), and most recently even ownership capabilities (consuming,
      borrowing, non-copyable types…). In "Back to basics" we will focus on just one part of the 
      language in order to uncover the deep theory behind that feature as well as provide
      concrete advice for writing real-world code.
      """#,
    sections: [
      .init(
        alternateSlug: nil,
        blurb: #"""
          The `Equatable` and `Hashable` protocols in Swift seem simple enough, but they have
          certain laws that must be upheld when implementing conformances. Learn about the notions
          of "equivalence relation" and "well-definedness" in order to understand why they are 
          so important, and dive deep into what makes a correct (and incorrect) conformance to
          these protocols.
          """#,
        coreLessons: [
          .init(episode: .ep297_equatable),
          .init(episode: .ep298_equatable),
          .init(episode: .ep299_equatable),
          .init(episode: .ep300_equatable),
        ],
        isHidden: false,
        related: [],
        title: "Equatable and Hashable",
        whereToGoFromHere: nil
      )
    ],
    title: "Back to basics"
  )
}
