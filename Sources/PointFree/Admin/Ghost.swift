import Foundation
import Html
import HttpPipeline
import Models
import Optics
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple

let ghostIndexMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Prelude.Unit,
  Data
  > =
  writeStatus(.ok)
    >=> respond(indexView)

let ghostStartMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple2<User, User.Id?>,
  Data
  > =
  filterMap(
    over2(fetchGhostee) >>> sequence2 >>> map(require2),
    or: redirect(
      to: .admin(.ghost(.index)),
      headersMiddleware: flash(.error, "Couldn't find user with that id")
    )
    )
    <| redirect(
      to: .home,
      headersMiddleware: ghost
)
//    redirect(to: .home)

func ghost(
  conn: Conn<HeadersOpen, Tuple2<User, User>>
  ) -> IO<Conn<HeadersOpen, Tuple2<User, User>>> {

  let (adminUser, ghostee) = lower(conn.data)

  return conn
    |> writeSessionCookieMiddleware(\.userId .~ ghostee.id)
}

func fetchGhostee(userId: User.Id?) -> IO<User?> {
  guard let userId = userId else { return pure(nil) }

  return Current.database.fetchUserById(userId)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

private let indexView: [Node] =   [
  h3(["Ghost a user"]),
  form(
    [method(.post), action(pointFreeRouter.path(to: .admin(.ghost(.start(nil)))))],
    [
      label(["User id:"]),
      input([type(.text), name("user_id")]),
      input([type(.submit), value("Ghost 👻")])
    ]
  )
]
