import Models

extension Episode {
  public var previousEpisodes: [Episode] {
    return Current
      .episodes()
      .reversed()
      .reduce(into: (episodes: [], episodeId: self.previousEpisodeInCollection)) { result, episode in
        if episode.id == result.episodeId {
          result.episodes.append(episode)
          result.episodeId = episode.previousEpisodeInCollection
        }
      }
      .episodes
      .reversed()
  }

  public var subscriberOnly: Bool {
    return self.isSubscriberOnly(currentDate: Current.date())
  }
}

func reference(forEpisode episode: Episode, additionalBlurb: String) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
    \(additionalBlurb)

    > \(episode.blurb)
    """,
    link: url(to: .episode(.left(episode.slug))),
    publishedAt: episode.publishedAt,
    title: episode.title
  )
}
