import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct Episodes: HTML {
  let freeEpisodes: [Episode]
  let mainEpisodes: [Episode]
  let listType: SiteRoute.EpisodesRoute.ListType

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  public init(
    listType: SiteRoute.EpisodesRoute.ListType
  ) {
    @Dependency(\.date.now) var now
    @Dependency(\.episodeProgresses) var episodeProgresses
    @Dependency(\.episodes) var episodes

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
    EpisodesHeader(
      episodeCount: mainEpisodes.count,
      listType: listType
    )

    switch listType {
    case .all:
      EpisodesModule(
        episodes: freeEpisodes,
        title: "Free episodes",
        omitSeeAllLink: false
      )
      InterstitialBanner()
      EpisodesModule(
        episodes: mainEpisodes,
        title: "All episodes",
        omitSeeAllLink: true
      )

    case .free:
      EpisodesModule(
        episodes: mainEpisodes,
        title: nil,
        omitSeeAllLink: true
      ) {
        InterstitialBanner()
      }

    case .history:
      EpisodesModule(
        episodes: mainEpisodes,
        title: nil,
        omitSeeAllLink: true
      ) {
        InterstitialBanner()
      }
    }
  }
}

private struct EpisodesModule<Episodes: Collection<Episode>, CTA: HTML>: HTML {
  let episodes: Episodes
  var title: String?
  var cta: CTA?
  var omitSeeAllLink: Bool

  init(
    episodes: Episodes,
    title: String? = nil,
    omitSeeAllLink: Bool,
    @HTMLBuilder cta: () -> CTA
  ) {
    self.episodes = episodes
    self.title = title
    self.cta = cta()
    self.omitSeeAllLink = omitSeeAllLink
  }

  init(
    episodes: Episodes,
    title: String? = nil,
    omitSeeAllLink: Bool
  ) where CTA == HTMLEmpty {
    self.episodes = episodes
    self.title = title
    self.cta = nil
    self.omitSeeAllLink = omitSeeAllLink
  }

  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    if let cta = cta {
      module(episodes: episodes.prefix(3), omitSeeAllLink: true)
      cta
      module(episodes: episodes.dropFirst(3), omitSeeAllLink: true)
    } else {
      module(episodes: episodes, omitSeeAllLink: false)
    }
  }

  func module(
    episodes: some Collection<Episode>,
    omitSeeAllLink overrideOmitSeeAllLink: Bool
  ) -> some HTML {
    PageModule(
      seeAllURL: overrideOmitSeeAllLink || omitSeeAllLink || title == nil
        ? nil
        : siteRouter.path(for: .episodes(.list(.free))),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        for episode in episodes {
          EpisodeCard(episode, emergencyMode: false)  // TODO
        }
      }
    } title: {
      if let title {
        Header(3) { HTMLText(title) }
      }
    }
  }
}

private struct EpisodesHeader: HTML {
  let episodeCount: Int
  let listType: SiteRoute.EpisodesRoute.ListType
  @Dependency(\.subscriberState) var subscriberState
  var body: some HTML {
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
          "Watch our entire catalogue of episodes, all \(episodeCount) of them."
        } else {
          "Watch some for free or explore all \(episodeCount) episodes."
        }
      case .free:
        "All of our free episodes, in one place."
      case .history:
        "Your most recently watched episodes."
      }
    }
  }
}

private struct InterstitialBanner: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    if currentUser == nil {
      GetStartedModule(style: .solid)
    } else if subscriberState.isNonSubscriber {
      UpgradeModule()
    } else if let currentUser {
      ReferAFriendModule(user: currentUser)
    }
  }
}
