import Either

extension Either where L == Never {
  public var guaranteedRight: R {
    switch self {
    case let .right(value):
      return value
    }
  }
}

extension Either where R == Never {
  public var guaranteedLeft: L {
    switch self {
    case let .left(value):
      return value
    }
  }
}
