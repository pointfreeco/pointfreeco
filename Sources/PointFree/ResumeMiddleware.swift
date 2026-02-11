import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views

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
    return conn.redirect(to: .auth(.gitHubAuth(redirect: siteRouter.url(for: currentRoute))))
  }

  guard
    let latestProgress = episodeProgresses.values
      .sorted(by: { ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $0.createdAt) })
      .first
  else {
    return conn.redirect(to: .home) {
      $0.flash(.warning, "You are not currently watching any videos.")
    }
  }

  guard latestProgress.isFinished
  else {
    return conn.redirect(
      to: .episodes(
        .show(
          episodes().first(where: { $0.sequence == latestProgress.episodeSequence })!
        )
      )
    ) {
      $0.flash(.notice, "Resuming your last watched video.")
    }
  }

  guard
    let nextEpisode = episodes().first(where: { $0.sequence == latestProgress.episodeSequence + 1 })
  else {
    return conn.redirect(to: .home) {
      $0.flash(.notice, "You‘re all caught up!")
    }
  }

  return conn.redirect(to: .episodes(.show(nextEpisode))) {
    $0.flash(.notice, "Starting the next video.")
  }
}
