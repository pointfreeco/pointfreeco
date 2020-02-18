import Foundation
import Html
import Models
import PointFreeRouter
import Prelude

public func freeEpisodeView(episodes: [Episode], today: Date) -> Node {
  return [
    .h2("Send free episode email"),
    .ul(
      .fragment(
        episodes
          .filter { !$0.isSubscriberOnly(currentDate: today) }
          .sorted(by: their(^\.sequence))
          .map { .li(row(episode: $0)) }
      )
    )
  ]
}

private func row(episode: Episode) -> Node {
  return .p(
    .text(episode.title),
    .form(
      attributes: [
        .action(pointFreeRouter.path(to: .admin(.freeEpisodeEmail(.send(episode.id))))),
        .method(.post)
      ],
      .input(attributes: [.type(.submit), .value("Send email!")])
    )
  )
}
