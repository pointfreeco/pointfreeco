import ApplicativeRouter
import Cryptor
import Css
import Dispatch
import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

// todo: swift-prelude?
// todo: rename to `tupleArray`?
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
}

extension FunctionM {
  public static func <¢> <N>(f: @escaping (M) -> N, c: FunctionM) -> FunctionM<A, N> {
    return c.map(f)
  }
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
          ?? (
            conn.map(const(unit))
              |> writeStatus(.notFound)
              >-> respond(notFoundView)
        )
      }
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

public func zip5<A, B, C, D, E>(
  _ a: Parallel<A>,
  _ b: Parallel<B>,
  _ c: Parallel<C>,
  _ d: Parallel<D>,
  _ e: Parallel<E>
  ) -> Parallel<(A, B, C, D, E)> {

  return tuple5 <¢> a <*> b <*> c <*> d <*> e
}

public func tuple5<A, B, C, D, E>(_ a: A) -> (B) -> (C) -> (D) -> (E) -> (A, B, C, D, E) {
  return { b in { c in { d in { e in (a, b, c, d, e) } } } }
}

public typealias T8<A, B, C, D, E, F, G, Z> = Tuple<A, T7<B, C, D, E, F, G, Z>>
public typealias Tuple7<A, B, C, D, E, F, G> = T8<A, B, C, D, E, F, G, Prelude.Unit>
public func get7<A, B, C, D, E, F, G, Z>(_ t: T8<A, B, C, D, E, F, G, Z>) -> G {
  return t.second.second.second.second.second.second.first
}
public func lower<A, B, C, D, E, F, G>(_ tuple: Tuple7<A, B, C, D, E, F, G>) -> (A, B, C, D, E, F, G) {
  return (get1(tuple), get2(tuple), get3(tuple), get4(tuple), get5(tuple), get6(tuple), get7(tuple))
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
    // TODO: WHAT?!
    return [String: String].init(pairs, uniquingKeysWith: { $1 })
//    return .init(uniqueKeysWithValues: pairs)
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

public func sequence2<A, B, Z>(_ t: T3<A, IO<B>, Z>) -> IO<T3<A, B, Z>> {
  return IO {
    return t |> over2(perform)
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
