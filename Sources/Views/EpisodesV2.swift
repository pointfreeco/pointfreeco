import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct Episodes: HTML {
  let freeEpisodes: [Episode]
  let allFreeEpisodeCount: Int
  let mainEpisodes: [Episode]
  let listType: SiteRoute.EpisodesRoute.ListType

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  public init(
    allFreeEpisodeCount: Int,
    listType: SiteRoute.EpisodesRoute.ListType
  ) {
    @Dependency(\.date.now) var now
    @Dependency(\.episodeProgresses) var episodeProgresses
    @Dependency(\.episodes) var episodes

    self.allFreeEpisodeCount = allFreeEpisodeCount
    self.listType = listType
    switch listType {
    case .all:
      mainEpisodes = episodes()
        .sorted { $0.sequence > $1.sequence }
      freeEpisodes = Array(mainEpisodes
          .filter { !$0.isSubscriberOnly(currentDate: now, emergencyMode: false/*TODO*/) }
          .prefix(3))
    case .free:
      mainEpisodes = episodes()
        .filter { !$0.isSubscriberOnly(currentDate: now, emergencyMode: false/*TODO*/) }
        .sorted { $0.sequence > $1.sequence }
      freeEpisodes = []
    case .history:
      freeEpisodes = []
      mainEpisodes = episodeProgresses.values
        .sorted(by: { ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $0.createdAt) })
        .compactMap({ progress in
          episodes().first(where: { $0.sequence == progress.episodeSequence })
        })
    }
  }

  public var body: some HTML {
    PageHeader {
      switch listType {
      case .all:
        "Episodes"
      case .free:
        "Free Episodes"
      case .history:
        "Continue watching"
      }
    } blurb: {
      switch listType {
      case .all:
        if subscriberState.isActiveSubscriber {
          "Watch our entire catalogue of episodes, all \(mainEpisodes.count) of them."
        } else {
          "Watch some for free or explore all \(mainEpisodes.count) episodes."
        }
      case .free:
        "All of our free episodes, in one place."
      case .history:
        "Your most recently watched episodes."
      }
    }

    switch listType {
    case .all:
      if subscriberState.isNonSubscriber {
        EpisodesModule(episodes: freeEpisodes, title: "Free episodes")
        if currentUser == nil {
          GetStartedModule(style: .solid)
        } else {
          UpgradeModule()
        }
      }

      if subscriberState.isNonSubscriber {
        EpisodesModule(episodes: freeEpisodes, title: "Free episodes")
        UpgradeModule()
      }
      
      if let user = currentUser {
        EpisodesModule(
          episodes: mainEpisodes.prefix(3),
          title: subscriberState.isNonSubscriber ? "All episodes" : nil
        )
        ReferAFriendModule(user: user)
        EpisodesModule(episodes: mainEpisodes.dropFirst(3))
      } else {
        EpisodesModule(
          episodes: mainEpisodes,
          title: subscriberState.isNonSubscriber ? "All episodes" : nil
        )
      }

    case .free:
      if subscriberState.isNonSubscriber {
        EpisodesModule(
          episodes: mainEpisodes.prefix(3)
        )
        if currentUser == nil {
          GetStartedModule(style: .solid)
        } else {
          UpgradeModule()
        }
        EpisodesModule(episodes: mainEpisodes.dropFirst(3))
      } else {
        EpisodesModule(episodes: mainEpisodes)
      }

    case .history:
      EpisodesModule(episodes: mainEpisodes)
    }
  }
}

private struct EpisodesModule<Episodes: Collection<Episode>>: HTML {
  let episodes: Episodes
  var title: String?

  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(
      seeAllURL: title == nil ? nil : siteRouter.path(for: .episodes(.list(.free))),
      theme: .content
    ) {
      Grid {
        for episode in episodes {
          EpisodeCard(episode, emergencyMode: false)  // TODO
        }
      }
      .grid(alignment: .stretch)
    } title: {
      if let title {
        Header(2) { HTMLText(title) }
      }
    }
  }
}
