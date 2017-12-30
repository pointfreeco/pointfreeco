import Foundation
import HttpPipeline
import Optics
import Prelude
import Tuple

public func writeSessionCookieMiddleware<A>(_ update: @escaping (Session) -> Session)
  -> (Conn<HeadersOpen, A>)
  -> IO<Conn<HeadersOpen, A>> {

    return { conn in
      let value = update(conn.request.session)
      guard value != conn.request.session else { return pure(conn) }
      return Response.Header
        .setSignedCookie(
          key: pointFreeUserSession,
          value: value,
          options: [.path("/")],
          secret: AppEnvironment.current.envVars.appSecret,
          encrypt: true
        )
        .map { conn |> writeHeader($0) }
        ?? pure(conn)
    }
}

public func flash<A>(_ priority: Flash.Priority, _ message: String) -> Middleware<HeadersOpen, HeadersOpen, A, A> {
  return writeSessionCookieMiddleware(\.flash .~ Flash(priority: priority, message: message))
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

public struct Session: Codable {
  public var flash: Flash?
  public var userId: Database.User.Id?

  public static let empty = Session(flash: nil, userId: nil)
}

public struct Flash: Codable {
  public enum Priority: String, Codable {
    case error
    case notice
    case warning
  }

  public let priority: Priority
  public let message: String
}

extension Session: Equatable {
  public static func ==(lhs: Session, rhs: Session) -> Bool {
    return lhs.flash == rhs.flash && lhs.userId?.rawValue == rhs.userId?.rawValue
  }
}

extension Flash: Equatable {
  public static func ==(lhs: Flash, rhs: Flash) -> Bool {
    return lhs.priority == rhs.priority && lhs.message == rhs.message
  }
}

private let pointFreeUserSession = "pf_session"
