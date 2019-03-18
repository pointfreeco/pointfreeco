import Html
import PointFreeRouter
import Prelude
import View

public let showEpisodeCreditsView = View<Prelude.Unit> { _ in
  [
    h3(["Create an episode credit!"]),
    form(
      [method(.post), action(pointFreeRouter.path(to: .admin(.episodeCredits(.add(userId: nil, episodeSequence: nil)))))],
      [
        label(["User id:"]),
        input([type(.text), name("user_id")]),
        label(["Episode sequence #:"]),
        input([type(.text), name("episode_sequence")]),
        input([type(.submit), value("Create")])
      ]
    )
  ]
}
