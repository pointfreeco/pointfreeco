import Foundation
import HttpPipeline
import Prelude
import Tuple

public struct Session: Codable {
  public var flash: Flash?
  public var userId: Database.User.Id?

  public static let empty = Session(flash: nil, userId: nil)

  private enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case flash
  }
}

//public func _readSessionCookieMiddleware<I, A>(_ conn: Conn<I, A>) -> IO<Conn<I, T2<Session, A>>> {
//
//  return pure(conn.request.session)
//    .map { conn.map(const($0 .*. conn.data)) }
//}

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

//private let pointFreeUserSession = "pf_session"
