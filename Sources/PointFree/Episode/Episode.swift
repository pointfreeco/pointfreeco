import Dependencies
import Models
import PointFreeRouter

extension Episode {
  public var subscriberOnly: Bool {
    @Dependency(\.envVars.emergencyMode) var emergencyMode
    @Dependency(\.date.now) var now

    return self.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
  }
}

func reference(forEpisode episode: Episode, additionalBlurb: String) -> Episode.Reference {
  @Dependency(\.siteRouter) var siteRouter

  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(episode.blurb)
      """,
    link: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    publishedAt: episode.publishedAt,
    title: episode.fullTitle
  )
}

func reference(forCollection collection: Episode.Collection, additionalBlurb: String)
  -> Episode.Reference
{
  @Dependency(\.siteRouter) var siteRouter

  return Episode.Reference(
    author: "Brandon Williams & Stephen Celis",
    blurb: """
      \(additionalBlurb)

      > \(collection.blurb)
      """,
    link: siteRouter.url(for: .collections(.collection(collection.slug))),
    publishedAt: collection.sections
      .flatMap { $0.coreLessons.map(\.episode) }
      .first?
      .publishedAt,
    title: collection.title
  )
}
