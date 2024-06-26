extension HTML {
  @HTMLBuilder
  public func fontScale(_ fontScale: FontScale) -> some HTML {
    inlineStyle("font-size", "\(fontScale.rawValue)rem")
  }

  @HTMLBuilder
  public func fontStyle(_ fontStyle: FontStyle) -> some HTML {
    switch fontStyle {
    case .body(.small):
      color(.black)
        .fontScale(.h6)
        .inlineStyle("font-weight", "normal")
        .inlineStyle("line-height", "4")
    }
  }
}

public enum FontScale: Double {
  case h1 = 4
  case h2 = 3
  case h3 = 2
  case h4 = 1.5
  case h5 = 1
  case h6 = 0.875
}

public enum FontStyle {
  case body(Body)

  public enum Body {
    case small
  }
}
