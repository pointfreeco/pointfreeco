import Css
import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

// todo: swift-prelude?
// todo: rename to `tupleArray`?
public func array<A>(_ tuple: (A, A)) -> [A] {
  return [tuple.0, tuple.1]
}
public func array<A>(_ tuple: (A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2]
}
public func array<A>(_ tuple: (A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3]
}
public func array<A>(_ tuple: (A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4]
}
public func array<A>(_ tuple: (A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
}
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8, tuple.9]
}

// todo: HasPlaysInline
public func playsInline<T>(_ value: Bool) -> Attribute<T> {
  return .init("playsinline", value)
}
public func muted<T>(_ value: Bool) -> Attribute<T> {
  return .init("muted", value)
}
public func poster<T>(_ value: String) -> Attribute<T> {
  return .init("poster", value)
}

extension FunctionM {
  public static func <¢> <N>(f: @escaping (M) -> N, c: FunctionM) -> FunctionM<A, N> {
    return c.map(f)
  }
}

public func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("id", idSelector.idString ?? "")
}

public func `for`<T: HasFor>(_ idSelector: CssSelector) -> Attribute<T> {
  return .init("for", idSelector.idString ?? "")
}

extension CssSelector {
  public var idString: String? {
    switch self {
    case .star, .elem, .class, .pseudo, .pseudoElem, .attr, .child, .sibling, .deep, .adjacent, .combined,
         .union:
      return nil
    case let .id(id):
      return id
    }
  }
}

// TODO: Move to HttpPipeline
public func >¢< <A, B, C, I, J>(
  lhs: @escaping (A) -> C,
  rhs: @escaping Middleware<I, J, C, B>
  )
  -> Middleware<I, J, A, B> {

    return map(lhs) >>> rhs
}

// TODO: Move to HttpPipeline

/// Lifts middleware that operates on non-optional values to one that operates on optionals, but renders
/// a 404 not found view in place of `nil` values.
///
/// - Parameter notFoundView: A view to render in case of encountering a `nil` value.
/// - Returns: New middleware that operates on optional values.
public func requireSome<A>(
  notFoundView: View<Prelude.Unit>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A?, Data> {

    return { middleware in
      return { conn in
        return conn.data
          .map { conn.map(const($0)) }
          .map(middleware)
          ?? (conn.map(const(unit)) |> (writeStatus(.notFound) >-> respond(notFoundView)))
      }
    }
}

extension EitherIO {
  public func `catch`(_ f: @escaping (E) -> EitherIO) -> EitherIO {
    return catchE(self, f)
  }

  public func mapExcept<F, B>(_ f: @escaping (Either<E, A>) -> Either<F, B>) -> EitherIO<F, B> {
    return .init(
      run: self.run.map(f)
    )
  }

  public func withExcept<F>(_ f: @escaping (E) -> F) -> EitherIO<F, A> {
    return self.bimap(f, id)
  }
}

// TODO: Move to PreludeFoundation?

public func dataTask(with request: URLRequest) -> EitherIO<Error, (Data, URLResponse)> {
  return .init(
    run: .init { callback in
      let session = URLSession(configuration: .default)
      session
        .dataTask(with: request) { data, response, error in
          defer { session.finishTasksAndInvalidate() }
          if let error = error {
            callback(.left(error))
          }
          if let data = data, let response = response {
            callback(.right((data, response)))
          }
        }
        .resume()
    }
  )
}

public func jsonDataTask<A>(with request: URLRequest, decoder: JSONDecoder? = nil)
  -> EitherIO<Error, A>
  where A: Decodable {

    return dataTask(with: request)
      .map(
        first >>> {
          AppEnvironment.current.logger.debug(String(decoding: $0, as: UTF8.self))
          return $0
        }
      )
      .flatMap { data in
        .wrap { try (decoder ?? defaultDecoder).decode(A.self, from: data) }
    }
}

private let defaultDecoder = JSONDecoder()

public func zip<A, B>(_ lhs: Parallel<A>, _ rhs: Parallel<B>) -> Parallel<(A, B)> {
  return tuple <¢> lhs <*> rhs
}

// TODO: Move to swift-web
import ApplicativeRouter
extension PartialIso {
  public static func iso(_ iso: PartialIso, default: B) -> PartialIso {
    return .init(
      apply: { iso.apply($0) ?? `default` },
      unapply: iso.unapply
    )
  }
}

// TODO: Move to swift-prelude
extension PartialIso where A == String, B: RawRepresentable, B.RawValue == String {
  public static var rawRepresentable: PartialIso {
    return .init(
      apply: B.init(rawValue:),
      unapply: ^\.rawValue
    )
  }
}

public struct Tagged<Tag, A: Codable> {
  public let unwrap: A

  public init(unwrap: A) {
    self.unwrap = unwrap
  }
}

extension Tagged: Codable /* where A: Codable */ {
  public init(from decoder: Decoder) throws {
    self.init(unwrap: try decoder.singleValueContainer().decode(A.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.unwrap)
  }
}

extension Tagged: RawRepresentable {
  public init?(rawValue: A) {
    self.init(unwrap: rawValue)
  }

  public var rawValue: A {
    return self.unwrap
  }
}
