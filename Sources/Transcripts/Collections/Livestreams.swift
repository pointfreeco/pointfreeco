import VimeoClient

extension Episode.Collection {
  public static var livestreams: Self {
    Self(
      blurb: livesteramBlurb,
      sections: [
        .init(
          blurb: livesteramBlurb,
          coreLessons: [
            .episode(.ep221_pfLive_dependenciesStacks),
            .episode(.ep267_pfLive_observationInPractice),
            .clip(Clip(vimeoVideoID: 944549956)),
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
  episodes, and perform live coding sessions on real world problems, and along the way we answer
  _lots_ of viewer questions.
  """
