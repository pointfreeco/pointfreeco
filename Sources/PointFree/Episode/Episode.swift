import Dependencies
import Models
import PointFreeRouter
import Views

extension EpisodePermission {
  public init(episode: Episode) async {
    @Dependency(\.currentUser) var currentUser
    guard let currentUser else {
      self = .loggedOut(isEpisodeSubscriberOnly: episode.subscriberOnly)
      return
    }
    @Dependency(\.database) var database
    @Dependency(\.subscriberState) var subscriberState
    let subscriberPermission: SubscriberPermission =
      if subscriberState.isActiveSubscriber {
        .isSubscriber
      } else {
        .isNotSubscriber(
          creditPermission: (try? await database.fetchEpisodeCredits(userID: currentUser.id))?
            .contains(where: { $0.episodeSequence == episode.sequence }) == true
            ? .hasUsedCredit
            : .hasNotUsedCredit(isEpisodeSubscriberOnly: episode.subscriberOnly)
        )
      }
    self = .loggedIn(user: currentUser, subscriptionPermission: subscriberPermission)
  }
}

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
    link: siteRouter.url(for: .episodes(.show(episode))),
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
      .flatMap { $0.coreLessons.map(\.publishedAt) }
      .first,
    title: collection.title
  )
}
