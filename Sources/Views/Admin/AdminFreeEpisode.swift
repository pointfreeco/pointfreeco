import Foundation
import Html
import Models
import Optics
import PointFreeRouter
import Prelude
import View

public func freeEpisodeView(episodes: [Episode], today: Date) -> [Node] {
  return [
    h2(["Send free episode email"]),

    ul(
      episodes
        .filter { !$0.isSubscriberOnly(currentDate: today) }
        .sorted(by: their(^\.sequence))
        .map(li <<< row(episode:))
    )
  ]
}

private func row(episode: Episode) -> [Node] {
  return [
    p([
      .text(episode.title),
      form(
        [
          action(pointFreeRouter.path(to: .admin(.freeEpisodeEmail(.send(episode.id))))),
          method(.post)
        ], [
          input([type(.submit), value("Send email!")])
        ]
      )
      ]
    )
  ]
}
