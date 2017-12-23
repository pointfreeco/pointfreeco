import ApplicativeRouter
import Css
import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
@testable import Tuple

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

public func require<A, B>(
  _ f: @escaping (A) -> B?,
  notFoundView: View<A> = View { _ in ["Not found"] }
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, B, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        return f(conn.data)
          .map { conn.map(const($0)) }
          .map(middleware)
          ?? (conn |> (writeStatus(.notFound) >-> respond(notFoundView)))
      }
    }
}

public func first<A, B, C, D>(_ a2b: @escaping (A) -> B) -> ((A, C, D)) -> (B, C, D) {
  return { ac in (a2b(ac.0), ac.1, ac.2) }
}

func requireFirst<A, B, C>(_ x: (A?, B, C)) -> (A, B, C)? {
  return x.0.map { ($0, x.1, x.2) }
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

extension EitherIO {
  public func bimap<F, B>(_ f: @escaping (E) -> F, _ g: @escaping (A) -> B) -> EitherIO<F, B> {
    return .init(run: self.run.map { $0.bimap(f, g) })
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

public func zip<A, B, C>(_ a: Parallel<A>, _ b: Parallel<B>, _ c: Parallel<C>) -> Parallel<(A, B, C)> {
  return tuple3 <¢> a <*> b <*> c
}

public func tuple3<A, B, C>(_ a: A) -> (B) -> (C) -> (A, B, C) {
  return { b in { c in (a, b, c) } }
}

// todo: move to prelude
extension Prelude.Unit: Error {}

public func clamp<T>(_ to: CountableRange<T>) -> (T) -> T {
  return { element in
    min(to.upperBound, max(to.lowerBound, element))
  }
}

// todo: move to httppipeline
public func ignoreErrors<I, A>(_ conn: Conn<I, Either<Error, A>>) -> Conn<I, A?> {
  return conn.map { $0.right }
}

// better way of doing this? or should we add to Either.swift?
public func requireSome<A>(_ e: Either<Error, A?>) -> Either<Error, A> {
  switch e {
  case let .left(e):
    return .left(e)
  case let .right(a):
    return a.map(Either.right) ?? .left(unit)
  }
}

public func convertToUnitError<E, A>(_ e: Either<E, A>) -> Either<Prelude.Unit, A> {
  return e.bimap(const(unit), id)
}

extension Array {
  func sorted<A: Comparable>(by f: (Element) -> A) -> Array {
    return self.sorted { lhs, rhs in f(lhs) < f(rhs) }
  }
}

extension Optional {
  func filterOptional(isIncluded: (Wrapped) -> Bool) -> Optional {
    return self.flatMap { isIncluded($0) ? $0 : nil }
  }
}

// TODO: Move to swift-web
extension PartialIso {
  public static func iso(_ iso: PartialIso, default: B) -> PartialIso {
    return .init(
      apply: { iso.apply($0) ?? `default` },
      unapply: iso.unapply
    )
  }
}

extension Element {
  public enum Hr {}
}

public func hr(_ attribs: [Attribute<Element.Hr>]) -> Node {
  return node("hr", attribs, nil)
}

public func min<T: HasMin>(_ value: Int) -> Attribute<T> {
  return .init("min", value)
}

public func max<T: HasMax>(_ value: Int) -> Attribute<T> {
  return .init("max", value)
}

public protocol HasIntValue {}
extension Element.Input: HasIntValue {}
public func value<T: HasIntValue>(_ value: Int) -> Attribute<T> {
  return .init("value", value)
}

public func onclick<T>(javascript: StaticString) -> Attribute<T> {
  return .init("onclick", "javascript:\(javascript)")
}

// FIXME: Move to swift-web
public func data<T>(_ name: StaticString, _ value: String) -> Attribute<T> {
  return .init("data-\(name)", value)
}

extension PartialIso {
  /// Backwards composes two partial isomorphisms.
  public static func <<< <C> (lhs: PartialIso<B, C>, rhs: PartialIso<A, B>) -> PartialIso<A, C> {
    return .init(
      apply: rhs.apply >-> lhs.apply,
      unapply: lhs.unapply >-> rhs.unapply
    )
  }
}

extension UUID: RawRepresentable {
  public var rawValue: String {
    return self.uuidString
  }

  public init?(rawValue: String) {
    guard let uuid = UUID(uuidString: rawValue) else { return nil }
    self = uuid
  }
}

extension PartialIso where A == B.RawValue, B: RawRepresentable {
  public static var _rawRepresentable: PartialIso {
    return .init(
      apply: B.init(rawValue:),
      unapply: ^\.rawValue
    )
  }
}

public func mapExcept<E, F, A, B>(_ f: @escaping (Either<E, A>) -> Either<F, B>) -> (EitherIO<E, A>) -> EitherIO<F, B> {
  return { $0.mapExcept(f) }
}

public protocol TaggedType {
  associatedtype _Tag
  associatedtype _A

  var unwrap: _A { get }
  init(unwrap: _A)
}

extension Tagged: TaggedType {
  public typealias _Tag = Tag
  public typealias _A = A
}

extension PartialIso where A: Codable, B: TaggedType, A == B._A {
  public static var tagged: PartialIso<B._A, B> {
    return PartialIso(
      apply: B.init(unwrap:),
      unapply: ^\.unwrap
    )
  }
}

extension PartialIso where A == String, B == UUID {
  public static var uuid: PartialIso<String, UUID> {
    return PartialIso(
      apply: UUID.init(uuidString:),
      unapply: ^\.uuidString
    )
  }
}

public func lift<A>(_ a: A) -> Tuple1<A> {
  return Tuple1(first: a, second: unit)
}

extension IO {
  public var parallel: Parallel<A> {
    return Parallel { callback in
      callback(self.perform())
    }
  }
}

extension EitherIO {
  func retry(count: Int) -> EitherIO {
    return (1...(count - 1))
      .map(const(self))
      .reduce(self, { $0 <|> $1 })
  }
}

func zip<A>(_ parallels: [Parallel<A>]) -> Parallel<[A]> {

  return Parallel { callback in

    var completed = 0
    var results = [A?](repeating: nil, count: parallels.count)

    parallels.enumerated().forEach { idx, parallel in
      parallel.run { a in
        results[idx] = a
        completed += 1

        if completed == parallels.count {
          callback(results.flatMap(id))
        }
      }
    }
  }
}
