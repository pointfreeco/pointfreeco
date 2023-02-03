extension Episode.Collection {
  public static var livestreams: Self {
    Self(
      blurb: "1",
      sections: [
        .init(
          blurb: "2",
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
