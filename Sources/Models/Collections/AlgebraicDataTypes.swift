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
TODO
"""#,
          content: Section.Related.Content.episode(.ep20_nonEmpty)
        )
      ],
      title: "Algebraic Data Types",
      whereToGoFromHere: #"""
TODO
"""#
    )
  )
}
