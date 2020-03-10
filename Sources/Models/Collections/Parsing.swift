extension Episode.Collection {
  public static let parsing = Self(
    blurb: #"""
It's easy to write code and be completely unaware of how ubiquitous "parsing" is or how often we turn to parsers for many of our everyday tasks. We'll define what "parsing" is generally, see what functional programming has to say about it, and uncover a wonderful story of composition along the way.
"""#,
    sections: [
      .init(
        blurb: #"""
Parsing is a difficult, but surprisingly ubiquitous programming problem, and functional programming has a lot to say about it. Let's take a moment to understand the problem space of parsing, and see what tools Swift and Apple gives us to parse complex text formats.
"""#,
        coreLessons: [
          .init(episode: .ep56_whatIsAParser_pt1),
          .init(episode: .ep57_whatIsAParser_pt2),
          .init(episode: .ep58_whatIsAParser_pt3),
        ],
        related: [],
        title: "What Is Parsing?",
        whereToGoFromHere: #"""
Now that we've distilled parsing into a core, functional unit, it's time to explore its transformable, composable properties. We'll leverage [earlier learnings](/collections/map-zip-flat-map) by asking ourselves if parsers have a `map` operation, and if they have a `zip` operation, and if they have a `flatMap` operation.
"""#
      ),
      .init(
        blurb: #"""
We'll define the trio of operations that form the basis of our functional programming toolkit on the `Parser` type. They introduce a familiar means of transforming and combining more basic parsers into more and more complex parsers that can pluck data out of some seriously complicated formats.
"""#,
        coreLessons: [
          .init(episode: .ep59_composableParsing_map),
          .init(episode: .ep60_composableParsing_flatMap),
          .init(episode: .ep61_composableParsing_zip),
        ],
        related: [
          .init(
            blurb: #"""
We go much deeper exploring `map`, `zip`, and `flatMap` in this collection of episodes. Parsers aren't alone! These operations are defined on a bunch of types in the Swift standard library and other Apple frameworks, and you should be empowered to define them on your own types as well.
"""#,
            content: .collection(.mapZipFlatMap)
          )
        ],
        title: "Composable Parsing: Map, Zip, Flat‑Map",
        whereToGoFromHere: #"""
Now that we've seen that parsers have `map`, `zip`, and `flatMap` operations, it's time to take things to the next level and explore a whole bunch of what are commonly called "parser combinators": or "higher-order" functions that enhance and combine parsers in more and more interesting, complex ways.
"""#
      ),
      .init(
        blurb: #"""
It's time to explore "parser combinators": functions that enhance and combine parsers in interesting ways. They will unlock some very powerful, expressive machinery and allow us to define some truly impressive parsers with little work.
"""#,
        coreLessons: [
          .init(episode: .ep62_parserCombinators_pt1),
          .init(episode: .ep63_parserCombinators_pt2),
          .init(episode: .ep64_parserCombinators_pt3),
        ],
        related: [
          .init(
            blurb: #"""
Parsing is just one of many problems functional programming solves by defining a core, composable, transformable unit. We apply these exact same techniques to randomness and even architecture!
"""#,
            content: .collections([
              .randomness,
              .composableArchitecture,
            ])
          ),
        ],
        title: "Parser Combinators",
        whereToGoFromHere: #"""
The parsing journey isn't over yet! We'll have more to come in future episodes. Till then, the same story has played out in our collections on [randomness](/collections/randomness) and [application architecture](/collections/composable-architecture), linked above.
"""#
      ),
    ],
    title: "Parsing"
  )
}
