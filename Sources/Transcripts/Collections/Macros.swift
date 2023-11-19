extension Episode.Collection {
  public static var macros: Self {
    Self(
      blurb: macrosBlurb,
      sections: [
        .init(
          blurb: """
            Macros can generate code for your application that is then compiled by Swift, and as
            such it is very important to test macros deeply. If a macro generates invalid Swift
            code you can be left with mystifying compiler errors. We explore a variety of techniques
            for testing and debugging macros.
            """,
          coreLessons: [
            .init(episode: .ep250_macroTesting),
            .init(episode: .ep251_macroTesting),
          ],
          related: [],
          title: "Testing and debugging macros",
          whereToGoFromHere: """
            Now that we know how to test and debug macros, let's apply these ideas to improve a
            concept that we explored many years ago: case paths.
            """
        ),
        .init(
          blurb: """
            Case paths are a powerful concept that we introduced many years ago, and they aim to
            bring key path-like affordances to enums and their cases. They never fully lived up
            to their potential, but macros allow us to completely reimagine how they are defined
            and used.
            """,
          coreLessons: [
            .init(episode: .ep257_macroCasePaths),
            .init(episode: .ep258_macroCasePaths),
          ],
          related: [],
          title: "Macro case paths",
          whereToGoFromHere: nil
        )
      ],
      title: "Macros"
    )
  }
}

private let macrosBlurb = """
  Swift 5.9 brings a powerful new feature to the language: macros. They allow you to implement new
  functionality into the language as if it was built directly in the language itself. However, they
  can be tricky to get right, and as such one needs to write an extensive test suite to make sure
  you have covered all of the subtle and nuanced edge cases that are possible.
  """
