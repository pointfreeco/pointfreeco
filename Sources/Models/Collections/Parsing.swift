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
            .init(
              blurb: #"""
Parsing is just one of many problems functional programming solves by defining a core, composable, transformable unit. We apply these exact same techniques to randomness and even app architecture!
"""#,
              content: .collections([
                .randomness,
                .composableArchitecture,
              ])
            ),
          ],
          title: "Parser Combinators",
          whereToGoFromHere: #"""
There was more than a year break from when we first covered parsers to when we picked up the topic again, and so we dedicated a few episodes to recapping everything we accomlished last time while also making a few ergonomic improvements along the way.
"""#
        ),
        .init(
          blurb: #"""
There was more than a year break from when we first covered parsers to when we picked up the topic again, and so we dedicated a few episodes to recapping everything we accomlished last time while also making a few ergonomic improvements along the way. We also used our parser knowledge to build a CLI tool from scratch that can process and pretty print the logs output from `xcodebuild` and `swift test`.
"""#,
          coreLessons: [
            .init(episode: .ep119_parsersRecap),
            .init(episode: .ep120_parsersRecap),
            .init(episode: .ep121_parsersRecap),
            .init(episode: .ep122_parsersRecap),
          ],
          related: [
            .init(
              blurb: #"""
Parsing is just one of many problems functional programming solves by defining a core, composable, transformable unit. We apply these exact same techniques to randomness and even app architecture!
"""#,
              content: .collections([
                .randomness,
                .composableArchitecture,
              ])
            ),
          ],
          title: "Parser Recap",
          whereToGoFromHere: #"""
The zip function shows up on many types: from Swift arrays and Combine publishers, to optionals, results, and even parsers! But zip on parsers is a little unlike zip on all of those other types, and because of this it can make building parsers a little more unwieldy. Let’s explore why and how to fix it.
"""#
        ),

        .init(
          blurb: #"""
The zip function shows up on many types: from Swift arrays and Combine publishers, to optionals, results, and even parsers! But zip on parsers is a little unlike zip on all of those other types, and because of this it can make building parsers a little more unwieldy. Let’s explore why and how to fix it.
"""#,
          coreLessons: [
            .init(episode: .ep123_fluentlyZippingParsers),
          ],
          related: [
            .init(
              blurb: #"""
"""#,
              content: .collections([
                .mapZipFlatMap,
              ])
            ),
          ],
          title: "Fluently Zipping Parsers",
          whereToGoFromHere: #"""
So far, the parser library we have been building is needlessly restricted to parsing only strings. There are lots of things that we'd like to parse, such as URL requests for application routing. By generalizing the `Parser` type we will gain the ability to parse many types of inputs, and we will uncover many unexpected benefits, including the ability to make our parsers much more performant than they currently are.
"""#
        ),

        .init(
          blurb: #"""
So far, the parser library we have been building is needlessly restricted to parsing only strings. There are lots of things that we'd like to parse, such as URL requests for application routing. By generalizing the `Parser` type we will gain the ability to parse many types of inputs, and we will uncover many unexpected benefits, including the ability to make our parsers much more performant than they currently are.
"""#,
          coreLessons: [
            .init(episode: .ep124_generalizedParsing),
            .init(episode: .ep125_generalizedParsing),
            .init(episode: .ep126_generalizedParsing),
          ],
          related: [
            .init(
              blurb: #"""
Parsing is just one of many problems functional programming solves by defining a core, composable, transformable unit. We apply these exact same techniques to randomness and even app architecture!
"""#,
              content: .collections([
                .randomness,
                .composableArchitecture,
              ])
            ),
          ],
          title: "Generalization",
          whereToGoFromHere: #"""
We have built a powerful parser library with a focus on composability and generality, but there's one important facet of parsing missing: performance. We will discover how to unlock a new level of performance from our parsers, making them competitive with more ad-hoc styles of parsing.
"""#
        ),

        .init(
          blurb: #"""
Performance is particularly important for parsing because you will often need to parse megabytes, or potentially gigabytes, of data. We show that although our parser library has taken some steps towards efficiency, there is still a lot of room for improvement. We will also compare the combinator style of parsing to other more popular styles, and see that combinators can be nearly as performant as more ad-hoc styles.
"""#,
          coreLessons: [
            .init(episode: .ep127_parsingPerformance),
            .init(episode: .ep128_parsingPerformance),
            .init(episode: .ep129_parsingPerformance),
            .init(episode: .ep130_parsingPerformance),
          ],
          related: [
            .init(
              blurb: #"""
Parsing is just one of many problems functional programming solves by defining a core, composable, transformable unit. We apply these exact same techniques to randomness and even app architecture!
"""#,
              content: .collections([
                .randomness,
                .composableArchitecture,
              ])
            ),
          ],
          title: "Performance",
          whereToGoFromHere: #"""
We can further improve the ergonomics of parsing with a relatively new feature of Swift: result builders.
"""#
        ),

        .init(
          blurb: #"""
Result builders are a powerful feature of Swift that enable DSLs like SwiftUI using familiar syntax. We will explore what result builders have to say about parsing by getting an understanding of how they work before implementing a result builder layer over our parsing library.
"""#,
          coreLessons: [
            .init(episode: .ep173_parserBuilders),
            .init(episode: .ep174_parserBuilders),
            .init(episode: .ep175_parserBuilders),
          ],
          related: [],
          title: "Builders",
          whereToGoFromHere: nil
        ),

      ],
      title: "Parsing"
    )
  }
}
