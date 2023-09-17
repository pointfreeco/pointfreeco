extension Episode.Collection {
  public static var macros: Self {
    Self(
      blurb: macrosBlurb,
      sections: [
        .init(
          blurb: macrosBlurb,
          coreLessons: [
            .init(episode: .ep250_macroTesting),
            .init(episode: .ep251_macroTesting),
          ],
          isFinished: false,
          related: [],
          title: "Macros",
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
