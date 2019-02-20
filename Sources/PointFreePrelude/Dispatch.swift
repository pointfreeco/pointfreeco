import Dispatch
import Prelude

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
