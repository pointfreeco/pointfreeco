import Models
import PointFreeRouter

extension Episode {
  public var subscriberOnly: Bool {
    return self.isSubscriberOnly(currentDate: Current.date(), emergencyMode: Current.envVars.emergencyMode)
  }
}

func reference(forEpisode episode: Episode, additionalBlurb: String) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
    \(additionalBlurb)

    > \(episode.blurb)
    """,
    link: url(to: .episode(.show(.left(episode.slug)))),
    publishedAt: episode.publishedAt,
    title: episode.fullTitle
  )
}

func reference(forCollection collection: Episode.Collection, additionalBlurb: String) -> Episode.Reference {
  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
    \(additionalBlurb)

    > \(collection.blurb)
    """,
    link: url(to: .collections(.show(collection.slug))),
    publishedAt: collection.sections
      .flatMap { $0.coreLessons.map(\.episode) }
      .first?
      .publishedAt,
    title: collection.title
  )
}
