import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

let showEpisodeCreditsMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple1<Database.User?>, Data> =
  requireAdmin
    <| writeStatus(.ok)
    >-> respond(showEpisodeCreditsView.contramap(const(unit)))

let addEpisodeCreditMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, String?, Int?>, Data> =
  requireAdmin
    <<< filterMap(
      over2(fetchUser(uuidString:)) >>> sequence2 >>> map(require2),
      or: redirect(to: .admin(.episodeCredits(.show)), headersMiddleware: flash(.error, "Could not find that user."))
    )
    <<< filterMap(
      over3(fetchEpisode(bySequence:)) >>> require3 >>> pure,
      or: redirect(to: .admin(.episodeCredits(.show)), headersMiddleware: flash(.error, "Could not find that episode."))
    )
    <| creditUserMiddleware

private func creditUserMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple3<Database.User, Database.User, Episode>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (user, episode) = (get2(conn.data), get3(conn.data))

  return AppEnvironment.current.database.addEpisodeCredit(episode.sequence, user.id)
    .run
    .flatMap(
      const(
        conn
          |> redirect(to: .admin(.episodeCredits(.show)))
      )
  )
}

private func fetchUser(uuidString: String?) -> IO<Database.User?> {
  guard let uuid = uuidString.flatMap(UUID.init(uuidString:)) else {
    return pure(nil)
  }

  return AppEnvironment.current.database.fetchUserById(.init(unwrap: uuid))
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

private func fetchEpisode(bySequence sequence: Int?) -> Episode? {
  guard let sequence = sequence else { return nil }
  return AppEnvironment.current.episodes()
    .first(where: { $0.sequence == sequence })
}

private let showEpisodeCreditsView = View<Prelude.Unit> { _ in
  [
    h3(["Create an episode credit!"]),
    form(
      [method(.post), action(path(to: .admin(.episodeCredits(.add(userId: nil, episodeSequence: nil)))))],
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
