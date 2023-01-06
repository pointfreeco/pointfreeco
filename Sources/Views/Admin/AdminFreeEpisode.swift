import Dependencies
import Foundation
import Html
import Models
import PointFreeRouter
import Prelude

public func freeEpisodeView(episodes: [Episode], today: Date, emergencyMode: Bool) -> Node {
  return [
    .h2("Send free episode email"),
    .ul(
      .fragment(
        episodes
          .filter { !$0.isSubscriberOnly(currentDate: today, emergencyMode: emergencyMode) }
          .sorted(by: their(\.sequence))
          .map { .li(row(episode: $0)) }
      )
    ),
  ]
}

private func row(episode: Episode) -> Node {
  @Dependency(\.siteRouter) var siteRouter
  return .p(
    .text(episode.fullTitle),
    .form(
      attributes: [
        .action(siteRouter.path(for: .admin(.freeEpisodeEmail(.send(episode.id))))),
        .method(.post),
      ],
      .input(attributes: [.type(.submit), .value("Send email!")])
    )
  )
}
