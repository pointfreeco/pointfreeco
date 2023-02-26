extension Episode.Collection {
  public static let algebraicDataTypes = Self(
    section: .init(
      blurb: #"""
        There is a wonderful correspondence between Swift's type system and algebra that we are all familiar with from grade school. By understanding this correspondence we can understand our data structures at a much higher level, and this allows us to remove invalid states from our types, thus making things we want to be impossible, actually impossible.
        """#,
      coreLessons: [
        .init(episode: .ep4_algebraicDataTypes),
        .init(episode: .ep9_algebraicDataTypes_exponents),
        .init(episode: .ep19_algebraicDataTypes_genericsAndRecursion),
      ],
      related: [
        Episode.Collection.Section.Related(
          blurb: #"""
            Using algebraic data types as our guiding light we are able to model a collection type in Swift which is compiler-proven to be non-empty. That is, you are not allowed to construct an instance of this type unless you prove that it contains at least one element.
            """#,
          content: .episode(.ep20_nonEmpty)
        )
      ],
      title: "Algebraic Data Types",
      whereToGoFromHere: #"""
        Once you see that enums and structs correspond to addition and multiplication from algebra, and therefore are deeply related concepts, you might wonder what else is there to their connection? Well, quite a bit, and we have an entire collection of episodes dedicated to discovering more about what unites enums and structs:

        * [Enums and Structs](/collections/enums-and-structs)
        """#
    )
  )
}
