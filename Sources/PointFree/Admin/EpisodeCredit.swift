import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import PointFreePrelude
import Prelude
import Styleguide
import Tuple
import View
import Views

let showEpisodeCreditsMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple1<User?>, Data> =
  requireAdmin
    <| writeStatus(.ok)
    >=> respond(showEpisodeCreditsView.contramap(const(unit)))

let redeemEpisodeCreditMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple3<User?, User.Id?, Int?>, Data> =
  requireAdmin
    <<< filterMap(
      over2(fetchUser(id:)) >>> sequence2 >>> map(require2),
      or: redirect(to: .admin(.episodeCredits(.show)), headersMiddleware: flash(.error, "Could not find that user."))
    )
    <<< filterMap(
      over3(fetchEpisode(bySequence:)) >>> require3 >>> pure,
      or: redirect(to: .admin(.episodeCredits(.show)), headersMiddleware: flash(.error, "Could not find that episode."))
    )
    <| creditUserMiddleware

private func creditUserMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple3<User, User, Episode>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (user, episode) = (get2(conn.data), get3(conn.data))

  return Current.database.redeemEpisodeCredit(episode.sequence, user.id)
    .run
    .flatMap(
      const(
        conn
          |> redirect(to: .admin(.episodeCredits(.show)))
      )
  )
}

private func fetchUser(id: User.Id?) -> IO<User?> {
  guard let id = id else { return pure(nil) }

  return Current.database.fetchUserById(id)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

private func fetchEpisode(bySequence sequence: Int?) -> Episode? {
  guard let sequence = sequence else { return nil }
  return Current.episodes()
    .first(where: { $0.sequence == sequence })
}
