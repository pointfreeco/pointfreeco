extension HTML {
  @HTMLBuilder
  public func listStyle(_ listStyle: ListStyle) -> some HTML {
    switch listStyle {
    case .reset:
      inlineStyle("list-style-type", "none")
        .padding(left: .zero)
    }
  }
}

public enum ListStyle {
  case reset
}
