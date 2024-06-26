extension HTML {
  @HTMLBuilder
  public func fontStyle(_ fontStyle: FontStyle) -> some HTML {
    switch fontStyle {
    case .body(.small):
      color(.black)
        .inlineStyle("font-weight", "normal")
        .inlineStyle("font-size", "0.875rem") // Class.h6
        .inlineStyle("line-height", "4")
    }
  }
}

public enum FontStyle {
  case body(Body)

  public enum Body {
    case small
  }
}
