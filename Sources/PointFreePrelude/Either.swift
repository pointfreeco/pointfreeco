import Either
import Foundation
import Prelude

// TODO: bake into Either or remove
extension Either: Monoid where R: Monoid {
  public static var empty: Either {
    return pure(R.empty)
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

public func retry<E, A>(maxRetries: Int) -> (EitherIO<E, A>) -> EitherIO<E, A> {
  return { $0.retry(maxRetries: maxRetries) }
}

public func retry<E, A>(maxRetries: Int, backoff: @escaping (Int) -> DispatchTimeInterval)
  -> (EitherIO<E, A>)
  -> EitherIO<E, A> {
    return { $0.retry(maxRetries: maxRetries, backoff: backoff) }
}

public func delay<E, A>(_ interval: DispatchTimeInterval) -> (EitherIO<E, A>) -> (EitherIO<E, A>) {
  return { $0.delay(interval) }
}

public func delay<E, A>(_ interval: TimeInterval) -> (EitherIO<E, A>) -> (EitherIO<E, A>) {
  return { $0.delay(interval) }
}


