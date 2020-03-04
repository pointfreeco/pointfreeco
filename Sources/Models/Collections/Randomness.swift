extension Episode.Collection {
  public static let randomness = Self(
    blurb: #"""
TODO
"""#,
    sections: [
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep30_composableRandomness),
          .init(episode: .ep31_decodableRandomness_pt1),
          .init(episode: .ep32_decodableRandomness_pt2),
        ],
        related: [
          .init(
            blurb: #"""
TODO
"""#,
            content: .episode(.ep13_theManyFacesOfMap)
          ),
          // TODO: Zip, Flat-Map?
        ],
        title: "Composable Randomness",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep47_predictableRandomness_pt1),
          .init(episode: .ep48_predictableRandomness_pt2),
        ],
        related: [
          .init(
            blurb: #"""
TODO
"""#,
            content: .episode(.ep49_generativeArt_pt1)
          ),
          .init(
            blurb: #"""
TODO
"""#,
            content: .episode(.ep50_generativeArt_pt2)
          ),
        ],
        title: "Predictable Randomness",
        whereToGoFromHere: #"""
TODO
"""#
      ),
    ],
    title: "Randomness"
  )
}
