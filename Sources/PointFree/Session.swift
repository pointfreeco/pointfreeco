import Dependencies
import Foundation
import HttpPipeline
import Models
import Prelude
import Tuple

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum CookieTransform: String, Codable {
  case plaintext
  case encrypted
}

extension CookieTransform: DependencyKey {
  public static let liveValue = Self.encrypted
  public static let testValue = Self.plaintext
}

extension DependencyValues {
  public var cookieTransform: CookieTransform {
    get { self[CookieTransform.self] }
    set { self[CookieTransform.self] = newValue }
  }
}

private let cookieExpirationDuration: TimeInterval = 315_360_000  // 60 * 60 * 24 * 365 * 10

public func writeSessionCookieMiddleware<A>(_ update: @escaping (inout Session) -> Void)
  -> (Conn<HeadersOpen, A>)
  -> IO<Conn<HeadersOpen, A>>
{

  return { conn in
    var session = conn.request.session
    update(&session)
    guard session != conn.request.session else { return pure(conn) }
    guard
      let header = setCookie(
        key: pointFreeUserSessionCookieName,
        value: session,
        options: [
          .expires(Current.date().addingTimeInterval(cookieExpirationDuration)),
          .path("/"),
        ])
    else { return pure(conn) }

    return writeHeader(header)(conn)
  }
}

public func flash<A>(_ priority: Flash.Priority, _ message: String) -> Middleware<
  HeadersOpen, HeadersOpen, A, A
> {
  return writeSessionCookieMiddleware { $0.flash = Flash(priority, message) }
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

public struct Session: Equatable {
  public var flash: Flash?
  public var user: User?

  public static let empty = Session(flash: nil, user: nil)

  public var userId: Models.User.ID? {
    switch self.user {
    case let .some(.ghosting(ghosteeId, _)):
      return ghosteeId
    case let .some(.standard(userId)):
      return userId
    case .none:
      return nil
    }
  }

  public var ghosterId: Models.User.ID? {
    switch self.user {
    case let .some(.ghosting(ghosteeId: _, ghosterId: ghosterId)):
      return ghosterId
    case .some(.standard), .none:
      return nil
    }
  }

  public var ghosteeId: Models.User.ID? {
    switch self.user {
    case let .some(.ghosting(ghosteeId: ghosteeId, ghosterId: _)):
      return ghosteeId
    case .some(.standard), .none:
      return nil
    }
  }

  public enum User: Codable, Equatable {
    case ghosting(ghosteeId: Models.User.ID, ghosterId: Models.User.ID)
    case standard(Models.User.ID)

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
        self = .standard(try container.decode(Models.User.ID.self, forKey: .userId))
      } catch {
        self = .ghosting(
          ghosteeId: try container.decode(Models.User.ID.self, forKey: .ghosteeId),
          ghosterId: try container.decode(Models.User.ID.self, forKey: .ghosterId)
        )
      }
    }
  }
}

extension Session: Codable {
  private enum CodingKeys: CodingKey {
    case flash
    case user
    case userId
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.flash, forKey: .flash)
    switch self.user {
    case let .some(.standard(userId)):
      try container.encode(userId, forKey: .userId)
    case .some(.ghosting):
      try container.encodeIfPresent(self.user, forKey: .user)
    case .none:
      break
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.flash = try container.decodeIfPresent(Flash.self, forKey: .flash)
    self.user =
      (try? container.decode(Models.User.ID.self, forKey: .userId)).map(User.standard)
      ?? (try? container.decode(Session.User.self, forKey: .user))
      ?? .empty
  }
}

extension Session {
  public init(flash: Flash?, userId: Models.User.ID?) {
    self.flash = flash
    self.user = userId.map(Session.User.standard)
  }
}

private let pointFreeUserSessionCookieName = "pf_session"

private func setCookie<A: Encodable>(
  key: String, value: A, options: Set<Response.Header.CookieOption> = []
) -> Response.Header? {
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
  encoder.outputFormatting = [.sortedKeys]
  return encoder
}()
