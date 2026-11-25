import CasePaths
import Either

extension Either: @retroactive CasePathable {
  public struct AllCasePaths: CasePath, Hashable, Sendable {
    public func embed(_ value: Either) -> Either { value }

    public func extract(from root: Either) -> Either? { root }

    public struct _$left: CasePath, Hashable, Sendable {
      public func embed(_ value: L) -> Either { .left(value) }

      public func extract(from root: Either) -> L? {
        guard case .left(let value) = root else { return nil }
        return value
      }
    }

    public var left: _$left { _$left() }

    public struct _$right: CasePath, Hashable, Sendable {
      public func embed(_ value: R) -> Either { .right(value) }

      public func extract(from root: Either) -> R? {
        guard case .right(let value) = root else { return nil }
        return value
      }
    }

    public var right: _$right { _$right() }
  }

  public static var allCasePaths: AllCasePaths { AllCasePaths() }

  public var `case`: PartialCaseKeyPath<Either> {
    switch self {
    case .left: return \.left
    case .right: return \.right
    }
  }

  public static var _allCaseKeyPaths: [PartialCaseKeyPath<Either>] {
    [\.left, \.right]
  }
}
