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
import StyleguideV2
import Tuple
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
      return await progressResponse(conn.map(const(param .*. percent .*. unit)))
        .performAsync()

    case let .show(collectionSlug):
      return await showEpisode(conn, episode: episode, collectionSlug: collectionSlug)

    case .useCredit:
      @Dependency(\.currentUser) var currentUser
      @Dependency(\.subscriberState) var subscriberState
      return await useCreditResponse(
        conn: conn.map(
          const(.right(episode.id) .*. currentUser .*. subscriberState .*. .episodes(route) .*. unit)
        )
      )
      .performAsync()
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
