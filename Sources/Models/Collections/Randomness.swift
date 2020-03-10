extension Episode.Collection {
  public static let randomness = Self(
    blurb: #"""
Randomness can seem like a concept at odds with functional programming. By its very nature it is unpredictable and difficult to test. Nevertheless it quickly proves itself to be an ideal case study of composition. We will distill the idea of randomness into a single core unit (a function!) and define a bunch of operations around it that allow us to build up more and more complex notions of randomness that the Swift standard library couldn't dream of.
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
            content: .section(.mapZipFlatMap, index: 0)
          ),
          .init(
            blurb: #"""
TODO
"""#,
            content: .section(.mapZipFlatMap, index: 1)
          ),
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
            content: .section(.mapZipFlatMap, index: 2)
          ),
          .init(
            blurb: #"""
TODO
"""#,
            content: .episodes([
              .ep49_generativeArt_pt1,
              .ep50_generativeArt_pt2,
            ])
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
