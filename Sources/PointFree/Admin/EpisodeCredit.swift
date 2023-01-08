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
    Void,
    Data
  > =
    writeStatus(.ok)
    >=> respond({ showEpisodeCreditsView() })

let redeemEpisodeCreditMiddleware =
  filterMap(
    over1(fetchUser(id:)) >>> sequence1 >>> map(require1),
    or: redirect(
      to: .admin(.episodeCredits(.show)),
      headersMiddleware: flash(.error, "Could not find that user."))
  )
  <<< filterMap(
    over2(fetchEpisode(bySequence:)) >>> require2 >>> pure,
    or: redirect(
      to: .admin(.episodeCredits(.show)),
      headersMiddleware: flash(.error, "Could not find that episode."))
  )
  <| creditUserMiddleware

private func creditUserMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple2<User, Episode>>
) -> IO<Conn<ResponseEnded, Data>> {

  let (user, episode) = lower(conn.data)

  return EitherIO { try await Current.database.redeemEpisodeCredit(episode.sequence, user.id) }
    .run
    .flatMap(
      const(
        conn
          |> redirect(to: .admin(.episodeCredits(.show)))
      )
    )
}

private func fetchUser(id: User.ID?) -> IO<User?> {
  IO { try? await Current.database.fetchUserById(id.unwrap()) }
}

private func fetchEpisode(bySequence sequence: Episode.Sequence?) -> Episode? {
  guard let sequence = sequence else { return nil }
  return Current.episodes()
    .first(where: { $0.sequence == sequence })
}
