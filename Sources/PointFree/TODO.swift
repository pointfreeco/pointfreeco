import ApplicativeRouter
import Cryptor
import Css
import Dispatch
import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

// todo: swift-prelude?
// todo: rename to `tupleArray`?
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
}

func filterMapValues<Key, Value, NewValue>(
  _ f: @escaping (Value) -> NewValue?
  )
  -> ([Key: Value])
  -> [Key: NewValue] {

    return { dict in
      var newDict = [Key: NewValue](minimumCapacity: dict.capacity)
      for (key, value) in dict {
        if let newValue = f(value) {
          newDict[key] = newValue
        }
      }
      return newDict
    }
}

func filteredValues<Key, Value>(_ dict: [Key: Value?]) -> [Key: Value] {
  return filterMapValues({ $0 })(dict)
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

public func filterMap<A, B>(
  _ f: @escaping (A) -> IO<B?>,
  or notFoundMiddleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, B, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      { conn in

        f(conn.data).flatMap { result in
          result.map(middleware <<< conn.map <<< const)
            ?? notFoundMiddleware(conn)
        }
      }
    }
}

public func filter<A>(
  _ p: @escaping (A) -> Bool,
  or notFoundMiddleware: @escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return filterMap({ p($0) ? $0 : nil } >>> pure, or: notFoundMiddleware)
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

public func zip<A, B, C, D>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>
  ) -> Parallel<(A, B, C, D)> {

  return tuple4 <¢> a <*> b <*> c <*> d
}

public func tuple3<A, B, C>(_ a: A) -> (B) -> (C) -> (A, B, C) {
  return { b in { c in (a, b, c) } }
}

public func tuple4<A, B, C, D>(_ a: A) -> (B) -> (C) -> (D) -> (A, B, C, D) {
  return { b in { c in { d in (a, b, c, d) } } }
}

// todo: move to prelude
extension Prelude.Unit: Error {}

public func clamp<T>(_ to: CountableRange<T>) -> (T) -> T {
  return { element in
    min(to.upperBound, max(to.lowerBound, element))
  }
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

extension Array {
  func sorted<A: Comparable>(by f: (Element) -> A) -> Array {
    return self.sorted { lhs, rhs in f(lhs) < f(rhs) }
  }
}

extension Optional {
  func filterOptional(_ isIncluded: (Wrapped) -> Bool) -> Optional {
    return self.flatMap { isIncluded($0) ? $0 : nil }
  }
}

// TODO: Move to swift-web
extension URLRequest {
  public var cookies: [String: String] {
    let pairs = (self.allHTTPHeaderFields?["Cookie"] ?? "")
      .components(separatedBy: "; ")
      .map {
        $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          .map(String.init)
      }
      .flatMap { (pair: [String]) -> (String, String) in
        (pair[0], pair.count == 2 ? pair[1] : "")
    }
    return .init(uniqueKeysWithValues: pairs)
  }
}

public protocol HasOnchange {}

extension Element.Input: HasOnchange {}

public func onchange<T: HasOnchange>(_ script: String) -> Attribute<T> {
  return attribute("onchange", script)
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

extension IO {
  public var parallel: Parallel<A> {
    return Parallel { callback in
      callback(self.perform())
    }
  }
}

extension EitherIO {
  func retry(maxRetries: Int) -> EitherIO {
    return retry(maxRetries: maxRetries, backoff: const(.seconds(0)))
  }

  func retry(maxRetries: Int, backoff: @escaping (Int) -> DispatchTimeInterval) -> EitherIO {
    return self.retry(maxRetries: maxRetries, attempts: 1, backoff: backoff)
  }

  private func retry(maxRetries: Int, attempts: Int, backoff: @escaping (Int) -> DispatchTimeInterval) -> EitherIO {

    guard attempts < maxRetries else { return self }

    return self <|> .init(run:
      self
        .retry(maxRetries: maxRetries, attempts: attempts + 1, backoff: backoff)
        .run
        .delay(backoff(attempts))
    )
  }

  public func delay(_ interval: DispatchTimeInterval) -> EitherIO {
    return .init(run: self.run.delay(interval))
  }
}

extension DispatchTimeInterval {
  private var nanoseconds: Int? {
    switch self {
    case let .seconds(n):
      return .some(n * 1_000_000_000)
    case let .milliseconds(n):
      return .some(n * 1_000_000)
    case let .microseconds(n):
      return .some(n * 1_000)
    case let .nanoseconds(n):
      return .some(n)
    case .never:
      return nil
    }
  }

  public static func + (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> DispatchTimeInterval {
    return (curry(+) <¢> lhs.nanoseconds <*> rhs.nanoseconds)
      .map(DispatchTimeInterval.nanoseconds)
      ?? .never
  }
}

extension IO {
  public func delay(_ interval: DispatchTimeInterval) -> IO {
    return .init { callback in
      DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
        callback(self.perform())
      }
    }
  }
}

import Dispatch

func sequence<A>(_ parallels: [Parallel<A>]) -> Parallel<[A]> {
  guard !parallels.isEmpty else { return Parallel { $0([])} }

  return Parallel { callback in
    let queue = DispatchQueue(label: "pointfree.parallel.sequence")

    var completed = 0
    var results = [A?](repeating: nil, count: parallels.count)

    parallels.enumerated().forEach { idx, parallel in
      parallel.run { a in
        results[idx] = a

        queue.sync {
          completed += 1
          if completed == parallels.count {
            callback(results.flatMap(id))
          }
        }
      }
    }
  }
}

func sequence<A>(_ xs: [IO<A>]) -> IO<[A]> {
  return IO {
    xs.map { $0.perform() }
  }
}

/// Returns first `left` value in array of `Either`'s, or an array of `right` values if there are no `left`s.
func sequence<A, E>(_ xs: [Either<E, A>]) -> Either<E, [A]> {
  var ys: [A] = []
  for x in xs {
    switch x {
    case let .left(e):
      return .left(e)
    case let .right(y):
      ys.append(y)
    }
  }
  return .right(ys)
}

// Sequence's an array of `EitherIO`'s by first sequencing the `IO` values, and then sequencing the `Either`
// vaues.
func sequence<A, E>(_ xs: [EitherIO<E, A>]) -> EitherIO<E, [A]> {
  return EitherIO(run: sequence(xs.map(^\.run)).map(sequence))
}

public func require1<A, Z>(_ x: T2<A?, Z>) -> T2<A, Z>? {
  return get1(x).map { over1(const($0)) <| x }
}

public func require2<A, B, Z>(_ x: T3<A, B?, Z>) -> T3<A, B, Z>? {
  return get2(x).map { over2(const($0)) <| x }
}

public func require3<A, B, C, Z>(_ x: T4<A, B, C?, Z>) -> T4<A, B, C, Z>? {
  return get3(x).map { over3(const($0)) <| x }
}

public func lower<A>(_ tuple: Tuple1<A>) -> A {
  return get1(tuple)
}

import Cryptor

extension PartialIso where A == String, B == String {
  public static func decrypted(withSecret secret: String) -> PartialIso<String, String> {
    return PartialIso(
      apply: { HttpPipeline.decrypted(text: $0, secret: secret) },
      unapply: { encrypted(text: $0, secret: secret) }
    )
  }

  public static var appDecrypted: PartialIso<String, String> {
    return .decrypted(withSecret: AppEnvironment.current.envVars.appSecret)
  }
}

/// Combines two partial iso's into one by concatenating their results into a single string.
public func payload<A, B>(
  _ iso1: PartialIso<String, A>,
  _ iso2: PartialIso<String, B>,
  separator: String = "--POINT-FREE-BOUNDARY--"
  )
  -> PartialIso<String, (A, B)> {

    return PartialIso<String, (A, B)>(
      apply: { payload in
        let parts = payload.components(separatedBy: separator)
        let first = parts.first.flatMap(iso1.apply)
        let second = parts.last.flatMap(iso2.apply)
        return tuple <¢> first <*> second
    },
      unapply: { first, second in
        guard
          let first = iso1.unapply(first),
          let second = iso2.unapply(second)
          else { return nil }
        return "\(first)\(separator)\(second)"
    })
}

public func mailto<T: HasHref>(_ address: String) -> Attribute<T> {
  return href("mailto:" + address)
}

public func hole<A, B>(_ a: A) -> B {
  fatalError()
}

public func hole<A, B, C>(_ a: A, _ b: B) -> C {
  fatalError()
}

public func hole<A, B, C, D>(_ a: A, _ b: B, _ c: C) -> D {
  fatalError()
}

public func hole<B>() -> B {
  fatalError()
}

// TODO: improve swift-web's digest to use `CryptoUtils.byteArray(from:)`
public func hexDigest(value: String, asciiSecret: String) -> String? {
  let keyBytes = CryptoUtils.byteArray(from: asciiSecret)
  let valueBytes = CryptoUtils.byteArray(from: value)
  let digestBytes = HMAC(using: .sha256, key: keyBytes).update(byteArray: valueBytes)?.final()
  return digestBytes.map { $0.map { String(format: "%02x", $0) }.joined() }
}

public func head<A>(_ status: HttpPipeline.Status)
  -> (Conn<StatusLineOpen, A>)
  -> IO<Conn<ResponseEnded, Data>> {

    return writeStatus(status) >-> end
}
