extension Episode.Collection {
  public static var parsing: Self {
    Self(
      blurb: #"""
Parsing is a surprisingly ubiquitous problem in programming. Every time we construct an integer or a URL from a string, we are technically doing parsing. After demonstrating the many types of parsing that Apple gives us access to, we will take a step back and define the essence of parsing in a single type. That type supports many wonderful types of compositions, and allows us to break large, complex parsing problems into small, understandable units.
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
We'll define the functional trio of operations on the `Parser` type: `map`, `zip` and `flatMap`. They introduce a familiar means of transforming and combining simple parsers into more and more complex parsers that can extract out first class data from nebulous blobs of data.
"""#,
          coreLessons: [
            .init(episode: .ep59_composableParsing_map),
            .init(episode: .ep60_composableParsing_flatMap),
            .init(episode: .ep61_composableParsing_zip),
          ],
          related: [
            .init(
              blurb: #"""
The `Parser` type isn't the only type that supports `map`, `zip` and `flatMap` operations. There are many types that can be transformed in similar ways, and even the Swift standard library and Apple frameworks ship with many examples. This collection of episodes explores this topic deeply, and hopes to empower you to define these operations on your own types as well.
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
            // TODO: bring back when we figure out recursive references
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
The parsing journey isn't over yet! We'll have more to come in future episodes. Till then, the same story has played out in our collections on [randomness](/collections/randomness) and [application architecture](/collections/composable-architecture), where we define a core type to express a certain domain and then explore all of the kinds of composition that type supports.
"""#
        ),
      ],
      title: "Parsing"
    )
  }
}
