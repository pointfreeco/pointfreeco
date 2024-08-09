import Css
import Dependencies
import Either
import Foundation
import FunctionalCss
import Html
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Views

public func episodesMiddleware(
  route: SiteRoute.EpisodesRoute,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  switch route {
  case .list(let listType):
    return await episodesListMiddleware(listType: listType, conn)

  case let .episode(param, episodeRoute):
    guard let episode = episode(forParam: param)
    else {
      return
        conn
        .writeStatus(.notFound)
        .respond { episodeNotFoundView() }
    }

    switch episodeRoute {
    case let .progress(percent):
      return await progressMiddleware(episode: episode, percent: percent, conn)

    case let .show(collectionSlug):
      return await showEpisode(conn, episode: episode, collectionSlug: collectionSlug)

    case .useCredit:
      return await useCreditMiddleware(episode: episode, conn)
    }
  }
}

private func episodesListMiddleware(
  listType: SiteRoute.EpisodesRoute.ListType,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  let subtitle =
    switch listType {
    case .all:
      "All episodes"
    case .free:
      "Free episodes"
    case .history:
      "Continue watching"
    }
  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: "Point-Free: A video series exploring advanced programming topics in Swift.",
        title: "Point-Free: \(subtitle)"
      )
    ) {
      Episodes(listType: listType)
    }
}

private func progressMiddleware(
  episode: Episode,
  percent: Int,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  guard
    let currentUser,
    await EpisodePermission(episode: episode).isViewable
  else { return conn.writeStatus(.ok).empty() }

  do {
    @Dependency(\.database) var database
    try await database.updateEpisodeProgress(
      sequence: episode.sequence,
      progress: percent,
      isFinished: percent >= 90,
      userID: currentUser.id
    )
  } catch {
    reportIssue()
  }

  return conn.writeStatus(.ok).empty()
}

private func showEpisode(
  _ conn: Conn<StatusLineOpen, Void>,
  episode: Episode,
  collectionSlug: Episode.Collection.Slug?
) async -> Conn<ResponseEnded, Data> {
  guard episode.transcript != nil else {
    reportIssue("Episode #\(episode.sequence) transcript not found")
    return
      conn
      .writeStatus(.notFound)
      .respond { episodeNotFoundView() }
  }

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState

  let permission = await EpisodePermission(episode: episode)
  let progress: Int? =
    switch permission {
    case .loggedIn(let currentUser, .isSubscriber),
      .loggedIn(let currentUser, .isNotSubscriber(creditPermission: .hasUsedCredit)),
      .loggedIn(let currentUser, .isNotSubscriber(creditPermission: .hasNotUsedCredit(false))):
      try? await database
        .fetchEpisodeProgress(userID: currentUser.id, sequence: episode.sequence)
        .percent
    default: nil
    }

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: String(stripping: episode.blurb),
        image: episode.image,
        title: "Episode #\(episode.sequence): \(episode.fullTitle)",
        usePrismJs: true
      )
    ) {
      EpisodeDetail(
        episodePageData: episodePageData(
          collectionSlug: collectionSlug,
          episode: episode,
          episodeProgress: progress,
          permission: permission
        )
      )
    }
}

private func episodePageData(
  collectionSlug: Episode.Collection.Slug?,
  episode: Episode,
  episodeProgress: Int?,
  permission: EpisodePermission
) -> EpisodePageData {
  @Dependency(\.collections) var collections
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now

  let context: EpisodePageData.Context
  if let collection = collections.first(where: { $0.slug == collectionSlug }),
    let section = collection.sections.first(where: {
      $0.coreLessons.contains(where: { $0.episode?.id == episode.id })
    })
  {
    context = .collection(collection, section: section)
  } else {
    context = .direct(
      previousEpisode: episodes().first(where: { $0.sequence == episode.sequence - 1 }),
      nextEpisode: episodes().first(where: { $0.sequence == episode.sequence + 1 })
    )
  }

  return EpisodePageData(
    context: context,
    emergencyMode: emergencyMode,
    episode: episode,
    episodeProgress: episodeProgress,
    permission: permission
  )
}

private func useCreditMiddleware(
  episode: Episode,
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var user
  guard let user else { return conn.loginAndRedirect() }
  let permission = await EpisodePermission(episode: episode)

  guard user.episodeCreditCount > 0 else {
    return conn.redirect(to: .episodes(.show(episode))) {
      $0.flash(.error, "You do not have any credits to use.")
    }
  }

  guard !permission.isViewable else {
    return conn.redirect(to: .episodes(.show(episode))) {
      $0.flash(.warning, "This episode is already available to you.")
    }
  }

  do {
    @Dependency(\.database) var database
    try await database.redeemEpisodeCredit(sequence: episode.sequence, userID: user.id)
    try await database.updateUser(id: user.id, episodeCreditCount: user.episodeCreditCount - 1)
    return conn.redirect(to: .episodes(.show(episode))) {
      $0.flash(.notice, "You now have access to this episode!")
    }
  } catch {
    return conn.redirect(to: .episodes(.show(episode))) {
      $0.flash(.error, "Something went wrong.")
    }
  }
}

private func episode(forParam param: Either<String, Episode.ID>) -> Episode? {
  @Dependency(\.episodes) var episodes: () -> [Episode]

  return episodes().first {
    param.left == .some($0.slug) || param.right == .some($0.id)
  }
}

private func episodeNotFoundView() -> Node {
  SimplePageLayoutData(
    data: (),
    title: "Episode not found :("
  )
    |> simplePageLayout({
      .gridRow(
        attributes: [.class([Class.grid.center(.mobile)])],
        .gridColumn(
          sizes: [.mobile: 6],
          .div(
            attributes: [.style(padding(topBottom: .rem(12)))],
            .h5(
              attributes: [.class([Class.h5])],
              "Episode not found :("
            ),
            .pre(
              .code(
                attributes: [.class([Class.pf.components.code(lang: "swift")])],
                "f: (Episode) -> Never"
              )
            )
          )
        )
      )
    })
}
