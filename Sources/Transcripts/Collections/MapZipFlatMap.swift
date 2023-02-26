extension Episode.Collection {
  public static let mapZipFlatMap = Self(
    blurb: #"""
      This trio of operations forms the basis of our functional programming toolkit. Each one provides a well-defined, succinct unit of transformation that helps us build up large units from smaller ones. It's no coincidence that the Swift standard library comes with these operations defined on arrays, optionals, results and more. They are truly powerful operations that can help you take your code to the next level!
      """#,
    sections: [
      .init(
        blurb: #"""
          The `map` operation is the simplest of the trio, allowing us to simply transform the underlying type contained in some generic context. However, don't let its simplicity fool you. There is a very powerful idea to be explored in the signature of the `map` function.
          """#,
        coreLessons: [
          .init(episode: .ep13_theManyFacesOfMap)
        ],
        related: [
          .init(
            blurb: #"""
              We encountered the `map` operation when exploring composable parsing. We were naturally led to this operation when we saw that it would be useful to be able to transform a parser's value without needing to actually run the parser.
              """#,
            content: .episode(.ep59_composableParsing_map)
          ),
          .init(
            blurb: #"""
              Not only can `map` be defined on types that represent parsing, but it can even be defined on types representing randomness! In this episode we showed that an entire library of randomness generators could be built out of a single random integer generator.
              """#,
            content: .episode(.ep30_composableRandomness)
          ),
          .init(
            blurb: #"""
              In this episode we introduce the idea of contravariance and show that it can be viewed through a functional lens by taking the signature of the `map` operation and giving it a little _flip_!
              """#,
            content: .episode(.ep14_contravariance)
          ),
        ],
        title: "Map",
        whereToGoFromHere: #"""
          Now that you understand the basics of the `map` operation and how it can be applied to real world library design, it's time to explore the `zip` operation. This operation allows you to do things that `map` alone is not capable of.
          """#
      ),
      .init(
        blurb: #"""
          The `zip` operation is the next powerful operation in the functional trio. It is a generalization of the `map` operation that allows you to perform `map`-like transformations on multiple generic containers at once. The `map` operation alone is incapable of doing that, and exploring this generalization leads us to some exciting new topics, such as multiple `zip` implementations and context-independent computation.
          """#,
        coreLessons: [
          .init(episode: .ep23_theManyFacesOfZip_pt1),
          .init(episode: .ep24_theManyFacesOfZip_pt2),
          .init(episode: .ep25_theManyFacesOfZip_pt3),
        ],
        related: [
          .init(
            blurb: #"""
              The `zip` operation came to our rescue in this episode where we need to be able to run multiple parsers on an input string, independent of each other. This was not possible using `map` and `flatMap` alone.
              """#,
            content: .episode(.ep61_composableParsing_zip)
          ),
          .init(
            blurb: #"""
              In [the episode before this one](/episodes/\#(Episode.ep31_decodableRandomness_pt1.slug)) we discovered that we could leverage Swift’s `Decodable` protocol to instantly unlock randomness for any decodable type, including your own custom types. However, the random values produced weren’t the easiset to work with and was difficult to customize. So, we turned to the `zip` operation to fix those problems, and came up with something surprising.
              """#,
            content: .episode(.ep32_decodableRandomness_pt2)
          ),
        ],
        title: "Zip",
        whereToGoFromHere: #"""
          You can accomplish quite a bit with the `map` and `zip` operations alone, such as transforming the underlying value of a computation, or combining multiple computations into a single one. But there are still some things they cannot accomplish, such as combining multiple computations together in such a way that later computations depend on earlier computations. This property alone is what motivates us to introduce the `flatMap` operation.
          """#
      ),
      .init(
        blurb: #"""
          The `flatMap` operation completes the functional trio, and gives us the power to sequence computations. Where `map` allowed us to transform a single computation, and `zip` allowed us to transform many independent computations at once, `flatMap` instead allows us to run one computation after another so that each subsequent computation can depend on the result of the previous one.
          """#,
        coreLessons: [
          .init(episode: .ep42_theManyFacesOfFlatMap_pt1),
          .init(episode: .ep43_theManyFacesOfFlatMap_pt2),
          .init(episode: .ep44_theManyFacesOfFlatMap_pt3),
          .init(episode: .ep45_theManyFacesOfFlatMap_pt4),
          .init(episode: .ep46_theManyFacesOfFlatMap_pt5),
        ],
        related: [
          .init(
            blurb: #"""
              When exploring ways to cook up complex form of randomness, such as randomly sized arrays of random values, we were naturally led to the concept of `flatMap`. It was exactly what we needed to allow new random values to depend on previous random values.
              """#,
            content: .episode(.ep48_predictableRandomness_pt2)
          )
        ],
        title: "Flat‑Map",
        whereToGoFromHere: #"""
          Now that you have the functional trio toolkit under your belt, it’s time to level up your understanding of how functional operations can be discovered. In this episode we introduce the idea of contravariance, and show that it can be viewed through a functional lens by taking the signature of the `map` operation and giving it a little _flip_!

          * [Contravariance](/episodes/\#(Episode.ep14_contravariance.slug))
          """#
      ),
    ],
    title: "Map, Zip, Flat‑Map"
  )
}
