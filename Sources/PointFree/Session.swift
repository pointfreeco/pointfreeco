import Foundation
import HttpPipeline
import Prelude
import Tuple

public struct Session: Codable {
  public var flash: Flash?
  public var userId: Database.User.Id?

  public static let empty = Session(flash: nil, userId: nil)
}

public func writeSessionCookieMiddleware<A>(_ update: @escaping (Session) -> Session)
  -> (Conn<HeadersOpen, A>)
  -> IO<Conn<HeadersOpen, A>> {

    return { conn in
      Response.Header
        .setSignedCookie(
          key: pointFreeUserSession,
          value: update(conn.request.session),
          options: [],
          secret: AppEnvironment.current.envVars.appSecret,
          encrypt: true
        )
        .map { conn |> writeHeader($0) }
        ?? pure(conn)
    }
}

extension URLRequest {
  var session: Session {
    return self.cookies[pointFreeUserSession]
      .flatMap {
        Response.Header
          .verifiedValue(signedCookieValue: $0, secret: AppEnvironment.current.envVars.appSecret)
      }
      ?? .empty
  }
}

private let pointFreeUserSession = "pf_session"
