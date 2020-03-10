extension Episode.Collection {
  public static let randomness = Self(
    blurb: #"""
Randomness can seem like a concept at odds with functional programming. By its very nature it is unpredictable and difficult to test. Nevertheless it quickly proves itself to be an ideal case study of composition. We will distill the idea of randomness into a single core unit (a function!) and define a bunch of operations around it that allow us to build up more and more complex notions of randomness that the Swift standard library couldn't dream of.
"""#,
    sections: [
      .init(
        blurb: #"""
Let's look at randomness under the lens of functional programming. We'll describe randomness using a simple function signature, explore some of its transformable, composable properties, and compare these APIs to the ones that ship with the Swift standard library.
"""#,
        coreLessons: [
          .init(episode: .ep30_composableRandomness),
          .init(episode: .ep31_decodableRandomness_pt1),
          .init(episode: .ep32_decodableRandomness_pt2),
        ],
        related: [
          .init(
            blurb: #"""
The `map` operation we define on the `Gen` type shows up on many, many types. In this episode we explore `map` in far more depth and see that there's something universal about its definition.
"""#,
            content: .episode(.ep13_theManyFacesOfMap)
          ),
          .init(
            blurb: #"""
We've also seen that the `zip` operation appears on a _number_ of types, as explored in this series of episodes.
"""#,
            content: .section(.mapZipFlatMap, index: 1)
          ),
        ],
        title: "Composable Randomness",
        whereToGoFromHere: #"""
Exploring composition in terms of randomness has given us a truly powerful set of APIs for generating more and more complex forms of randomness, but we have no way of testing any of them. In the next section we will show how it's possible to control randomness in predictable, testable ways.
"""#
      ),
      .init(
        blurb: #"""
It's time to make composable randomness _predictable_. We will make the `Gen` type compatible with Swift's new APIs, explore various ways of controlling those APIs, both locally and globally, and define the `flatMap` operation.
"""#,
        coreLessons: [
          .init(episode: .ep47_predictableRandomness_pt1),
          .init(episode: .ep48_predictableRandomness_pt2),
        ],
        related: [
          .init(
            blurb: #"""
These supplemental episodes take the machinery we've built so far for a fun spin by building and testing a generator of random art.
"""#,
            content: .episodes([
              .ep49_generativeArt_pt1,
              .ep50_generativeArt_pt2,
            ])
          ),
          .init(
            blurb: #"""
In this section we utilize the "environment" method of dependency injection, which was first covered and motivated in the following episodes.
"""#,
            content: .episode(.ep16_dependencyInjectionMadeEasy)
          ),
          .init(
            blurb: #"""
The `flatMap` operation we defined on `Gen` is the third of our functional toolkit trio, which we covered over the course of the following five episodes!
"""#,
            content: .section(.mapZipFlatMap, index: 2)
          ),
        ],
        title: "Predictable Randomness",
        whereToGoFromHere: #"""
We have more to say about randomness in the future. Till then, the same story has played out in our collections on [parsing](/collections/parsing) and [application architecture](/collections/composable-architecture).
"""#
      ),
    ],
    title: "Randomness"
  )
}
