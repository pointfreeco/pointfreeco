extension Episode.Collection {
  public static let crossPlatform = Self(
    blurb: #"""
      Did you know that Swift runs on more platforms besides just Apple's devices? It can run on 
      Windows, Android, web browsers, and Linux (Swift even powers this very website!). This 
      collection shows how to get a basic Swift app building for WebAssembly so that it can run in 
      the browser, and then demonstrates the principles necessary to share code between multiple 
      platforms.
      """#,
    sections: [
      .init(
        alternateSlug: nil,
        blurb: #"""
          Did you know that Swift runs on more platforms besides just Apple's devices? It can run on 
          Windows, Android, web browsers, and Linux (Swift even powers this very website!). This 
          collection shows how to get a basic Swift app building for WebAssembly so that it can run in 
          the browser, and then demonstrates the principles necessary to share code between multiple 
          platforms.
          """#,
        coreLessons: [
          .init(episode: .ep290_crossPlatform),
          .init(episode: .ep291_crossPlatform),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "Cross-platform Swift",
        whereToGoFromHere: nil
      )
    ],
    title: "Cross-platform Swift"
  )
}
