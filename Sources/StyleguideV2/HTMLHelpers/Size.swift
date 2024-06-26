extension HTML {
  public func size(width: CSSSize, height: CSSSize) -> some HTML {
    inlineStyle("height", "\(height)px")
      .inlineStyle("width", "\(width)px")
  }
}

public enum CSSSize: CustomStringConvertible {
  case rem(Double)
  case percent(Int)
  case px(Int)

  public var description: String {
    switch self {
    case let .rem(n):
      "\(n)rem"
    case let .percent(n):
      "\(n)%"
    case let .px(n):
      "\(n)px"
    }
  }
}
