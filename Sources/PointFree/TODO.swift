import Css
import Either
import Foundation
import Html
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

// TODO: Move to PreludeFoundation?

public func dataTask(with request: URLRequest) -> EitherIO<Error, (Data, URLResponse)> {
  return .init(
    run: .init { callback in
      let session = URLSession(configuration: .default)
      session
        .dataTask(with: request) { data, response, error in
          defer { session.invalidateAndCancel() }
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

public func jsonDataTask<A>(with request: URLRequest) -> EitherIO<Error, A> where A: Decodable {

  return dataTask(with: request)
    .flatMap { data, _ in
      EitherIO.wrap { try decoder.decode(A.self, from: data) }
  }
}

private let decoder = JSONDecoder()
