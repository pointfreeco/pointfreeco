extension HTML {
  @HTMLBuilder
  public func hidden(_ hidden: Bool = true) -> some HTML {
    if hidden {
      size(width: .px(1), height: .px(1))
        .inlineStyle("clip", "rect(1px,1px,1px,1px)")
        .inlineStyle("overflow", "hidden")
        .inlineStyle("position", "absolute")
    } else {
      self
    }
  }
}
