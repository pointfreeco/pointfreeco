import Foundation
import HttpPipeline
import Optics
import Prelude
import Tuple

public enum CookieTransform: String, Codable {
  case plaintext
  case encrypted
}

public func writeSessionCookieMiddleware<A>(_ update: @escaping (Session) -> Session)
  -> (Conn<HeadersOpen, A>)
  -> IO<Conn<HeadersOpen, A>> {

    return { conn in
      let value = update(conn.request.session)
      guard value != conn.request.session else { return pure(conn) }
      return setCookie(
          key: pointFreeUserSession,
          value: value,
          options: [
            .expires(Current.date().addingTimeInterval(60 * 60 * 24 * 365 * 10)),
            .path("/")
        ]
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
      .flatMap { value in
        switch Current.cookieTransform {
        case .plaintext:
          return try? JSONDecoder().decode(Session.self, from: Data(value.utf8))
        case .encrypted:
          return Response.Header
            .verifiedValue(signedCookieValue: value, secret: Current.envVars.appSecret)
        }
      }
      ?? .empty
  }
}

public struct Session: Codable, Equatable {
  public var flash: Flash?
  public var userId: Database.User.Id?

  public static let empty = Session(flash: nil, userId: nil)
}

public struct Flash: Codable, Equatable {
  public enum Priority: String, Codable {
    case error
    case notice
    case warning
  }

  public let priority: Priority
  public let message: String
}

private let pointFreeUserSession = "pf_session"

private func setCookie<A: Encodable>(key: String, value: A, options: Set<Response.Header.CookieOption> = []) -> Response.Header? {
  switch Current.cookieTransform {
  case .plaintext:
    return (try? cookieJsonEncoder.encode(value))
      .map { String(decoding: $0, as: UTF8.self) }
      .map { Response.Header.setCookie(key, $0, options) }

  case .encrypted:
    return Response.Header
      .setSignedCookie(
        key: key,
        value: value,
        options: options,
        secret: Current.envVars.appSecret,
        encrypt: true
    )
  }
}

public let cookieJsonEncoder: JSONEncoder = { () in
  let encoder = JSONEncoder()

  if #available(OSX 10.13, *) {
    encoder.outputFormatting = [.sortedKeys]
  }

  return encoder
}()
