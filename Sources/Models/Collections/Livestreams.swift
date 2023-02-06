extension Episode.Collection {
  public static var livestreams: Self {
    Self(
      blurb: livesteramBlurb,
      sections: [
        .init(
          blurb: livesteramBlurb,
          coreLessons: [
            .init(episode: .ep221_pfLive_dependenciesStacks)
          ],
          related: [],
          title: "Livestreams",
          whereToGoFromHere: nil
        )
      ],
      title: "Livestreams"
    )
  }
}

private let livesteramBlurb = """
  All of our livestreams, in one place. Watch us cover topics that we didn't have time for in our
  episodes, and perform live coding sessions on real world problems, and along the wya we answer
  _lots_ of viewer questions.
  """
