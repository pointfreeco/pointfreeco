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
      return setCookie(
          key: pointFreeUserSession,
          value: value,
          options: [.path("/")]
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
        switch AppEnvironment.current.cookieTransform {
        case .plaintext:
          return try? JSONDecoder().decode(Session.self, from: Data(value.utf8))
        case .encrypted:
          return Response.Header
            .verifiedValue(signedCookieValue: value, secret: AppEnvironment.current.envVars.appSecret)
        }
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
    return lhs.flash == rhs.flash
      && lhs.userId?.rawValue == rhs.userId?.rawValue
  }
}

extension Flash: Equatable {
  public static func ==(lhs: Flash, rhs: Flash) -> Bool {
    return lhs.priority == rhs.priority && lhs.message == rhs.message
  }
}

private let pointFreeUserSession = "pf_session"

private func setCookie<A: Encodable>(key: String, value: A, options: Set<Response.Header.CookieOption> = []) -> Response.Header? {
  switch AppEnvironment.current.cookieTransform {
  case .plaintext:
    return (try? cookieJsonEncoder.encode(value))
      .flatMap { String(data: $0, encoding: .utf8) }
      .map { Response.Header.setCookie(key, $0, options) }

  case .encrypted:
    return Response.Header
      .setSignedCookie(
        key: key,
        value: value,
        options: options,
        secret: AppEnvironment.current.envVars.appSecret,
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
