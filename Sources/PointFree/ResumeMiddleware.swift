import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views
import VimeoClient

func resumeMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.episodeProgresses) var episodeProgresses
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter

  guard currentUser != nil
  else {
    return await redirect(to: .login(redirect: siteRouter.url(for: currentRoute)))(conn)
      .performAsync()
  }

  guard
    let latestProgress = episodeProgresses.values
      .sorted(by: { ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $0.createdAt) })
      .first
  else {
    return await redirect(
      to: .home,
      headersMiddleware: flash(.warning, "You are not currently watching any episodes.")
    )(conn)
    .performAsync()
  }

  guard latestProgress.isFinished
  else {
    return await redirect(
      to: .episode(
        .show(
          .left(
            episodes().first(where: { $0.sequence == latestProgress.episodeSequence })!.slug
          )
        )
      ),
      headersMiddleware: flash(.notice, "Resuming your last watched episode.")
    )(conn)
    .performAsync()
  }

  guard
    let nextEpisode = episodes().first(where: { $0.sequence == latestProgress.episodeSequence + 1 })
  else {
    return await redirect(
      to: .home,
      headersMiddleware: flash(.notice, "You‘re all caught up!")
    )(conn)
    .performAsync()
  }

  return await redirect(
    to: .episode(.show(.left(nextEpisode.slug))),
    headersMiddleware: flash(.notice, "Starting the next episode.")
  )(conn)
  .performAsync()
}
