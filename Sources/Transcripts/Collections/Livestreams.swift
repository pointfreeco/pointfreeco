extension Episode.Collection {
  public static var livestreams: Self {
    Self(
      blurb: livestreamBlurb,
      sections: [
        .init(
          blurb: livestreamBlurb,
          coreLessons: [
            .episode(.ep313_pfLive_SharingGRDB),
            .clip(Clip(cloudflareVideoID: "d27a2cd4d124d031f0fa4bde2b84bca0")),
            .episode(.ep267_pfLive_observationInPractice),
            .episode(.ep221_pfLive_dependenciesStacks),
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

private let livestreamBlurb = """
  All of our livestreams, in one place. Watch us cover topics that we didn't have time for in our
  episodes, and perform live coding sessions on real world problems, and along the way we answer
  _lots_ of viewer questions.
  """
