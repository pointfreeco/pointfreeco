import Foundation
import Html
import HttpPipeline
import Models
import Optics
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple

private let ghostCookieName = "pf_ghoster"

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

let endGhostingMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Prelude.Unit,
  Data
  > =
  redirect(
    to: .home,
    headersMiddleware: endGhosting
)

private func endGhosting<A>(
  conn: Conn<HeadersOpen, A>
  ) -> IO<Conn<HeadersOpen, A>> {

  guard let resetUserCookieHeader = setCookie(
    key: pointFreeUserSessionCookieName,
    value: conn.request.ghosterSession,
    options: [
      .expires(.distantFuture),
      .path("/")
    ]
    ) else {
      return pure(conn)
  }

  guard let clearGhostCookieHeader = setCookie(
    key: ghostCookieName,
    value: Session(flash: nil, userId: nil),
    options: [
      .expires(.distantPast),
      .path("/")
    ]
    ) else {
      return pure(conn)
  }

  return conn
    |> writeSessionCookieMiddleware(
      ((\Session.userId) .~ conn.request.ghosterSession.userId)
      <> ((\Session.flash) .~ Flash(priority: .notice, message: "You are no longer ghosting."))
    )
    //writeHeader(resetUserCookieHeader)
    >=> writeHeader(clearGhostCookieHeader)
//    >=> flash(.notice, "You are no longer ghosting.")
}

private func ghost(
  conn: Conn<HeadersOpen, Tuple2<User, User>>
  ) -> IO<Conn<HeadersOpen, Tuple2<User, User>>> {

  let (adminUser, ghostee) = lower(conn.data)

  guard let ghostCookieHeader = setCookie(
    key: ghostCookieName,
    value: Session(flash: nil, userId: adminUser.id),
    options: [
      .expires(.distantFuture),
      .path("/")
    ]
    ) else {
      return pure(conn)
  }

  return conn
    |> writeSessionCookieMiddleware(\.userId .~ ghostee.id)
    >=> writeHeader(ghostCookieHeader)
}

private func fetchGhostee(userId: User.Id?) -> IO<User?> {
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

extension URLRequest {
  var ghosterSession: Session {
    return self.cookies[ghostCookieName]
      .flatMap { value in
        switch Current.cookieTransform {
        case .plaintext:
          return try? JSONDecoder().decode(Session.self, from: Data(value.utf8))
        case .encrypted:
          return Response.Header
            .verifiedValue(signedCookieValue: value, secret: Current.envVars.appSecret.rawValue)
        }
      }
      ?? .empty
  }
}
