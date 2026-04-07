extension Episode.Collection {
  public static let beyondBasics = Self(
    blurb: #"""
      The Swift language has grown over the years and become more and more powerful. It now boosts
      a comprehensive static type system (generics, existentials…), a suite of concurrency tools
      (actors, dynamic isolation…), and most recently even ownership capabilities (consuming,
      borrowing, non-copyable types…). In "Beyond Basics" we will focus on just one part of the 
      language in order to uncover the deep theory behind that feature as well as provide
      concrete advice for writing real-world code.
      """#,
    sections: [
      .init(
        alternateSlug: nil,
        blurb: #"""
          Isolation is a static, compiler guarantee that a portion of code is free from data 
          races, which manifests itself as data corruption or runtime crashes. The primary tool 
          for creating isolation domains is Swift actors, but when dealt with incorrectly they 
          can lead to a proliferation of asynchrony in code that would otherwise not need to be 
          asynchronous. By leveraging some of Swift's most advanced tools we can squash 
          unnecessary suspension points, and write safe, synchronous, lock-free code.
          """#,
        coreLessons: [
          .init(episode: .ep357_isolation),
          .init(episode: .ep358_isolation),
          .init(episode: .ep359_isolation),
          .init(episode: .ep360_isolation),
          .init(episode: .ep361_isolation),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "Isolation",
        whereToGoFromHere: nil
      ),
    ],
    title: "Beyond Basics"
  )
}
