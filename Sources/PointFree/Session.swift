import Foundation
import HttpPipeline
import Models
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
          key: pointFreeUserSessionCookieName,
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
    return self.cookies[pointFreeUserSessionCookieName]
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

public struct Session: Codable, Equatable {
  public var flash: Flash?
  public var user: User?

  public var userId: Models.User.Id? {
    get {
      switch self.user {
      case let .some(.ghosting(ghosteeId, _)):
        return ghosteeId
      case let .some(.standard(userId)):
        return userId
      case .none:
        return nil
      }
    }
    @available(*, deprecated, message: "")
    set {
      // TODO: remove infavor of explicit
      self.user = newValue.map(User.standard)
    }
  }

  public var ghosterId: Models.User.Id? {
    switch self.user {
    case let .some(.ghosting(_, ghosterId)):
      return ghosterId
    case .some(.standard), .none:
      return nil
    }
  }

  public var ghosteeId: Models.User.Id? {
    switch self.user {
    case let .some(.ghosting(ghosteeId, _)):
      return ghosteeId
    case .some(.standard), .none:
      return nil
    }
  }

  public enum User: Codable, Equatable {
    case ghosting(ghosteeId: Models.User.Id, ghosterId: Models.User.Id)
    case standard(Models.User.Id)

    private enum CodingKeys: CodingKey {
      case ghosteeId
      case ghosterId
      case userId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self {
      case let .ghosting(ghosteeId, ghosterId):
        try container.encode(ghosteeId, forKey: .ghosteeId)
        try container.encode(ghosterId, forKey: .ghosterId)

      case let .standard(userId):
        try container.encode(userId, forKey: .userId)
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      do {
        self = .standard(try container.decode(Models.User.Id.self, forKey: .userId))
      } catch {
        self = .ghosting(
          ghosteeId: try container.decode(Models.User.Id.self, forKey: .ghosteeId),
          ghosterId: try container.decode(Models.User.Id.self, forKey: .ghosterId)
        )
      }
    }
  }

  public static let empty = Session(flash: nil, user: nil)
}

extension Session {
  public init(flash: Flash?, userId: Models.User.Id?) {
    self.flash = flash
    self.user = userId.map(Session.User.standard)
  }
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

let pointFreeUserSessionCookieName = "pf_session"

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
        secret: Current.envVars.appSecret.rawValue,
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
