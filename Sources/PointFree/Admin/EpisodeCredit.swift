import Css
import Either
import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

let showEpisodeCreditsMiddleware:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    Tuple1<User>,
    Data
  > =
    writeStatus(.ok)
    >=> respond({ _ in showEpisodeCreditsView })

let redeemEpisodeCreditMiddleware =
  filterMap(
    over2(fetchUser(id:)) >>> sequence2 >>> map(require2),
    or: redirect(
      to: .admin(.episodeCredits(.show)),
      headersMiddleware: flash(.error, "Could not find that user."))
  )
  <<< filterMap(
    over3(fetchEpisode(bySequence:)) >>> require3 >>> pure,
    or: redirect(
      to: .admin(.episodeCredits(.show)),
      headersMiddleware: flash(.error, "Could not find that episode."))
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

private func fetchEpisode(bySequence sequence: Episode.Sequence?) -> Episode? {
  guard let sequence = sequence else { return nil }
  return Current.episodes()
    .first(where: { $0.sequence == sequence })
}
