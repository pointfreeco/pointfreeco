extension HTML {
  public func flexContainer(
    direction: String? = nil,
    wrap: String? = nil,
    justification: String? = nil,
    itemAlignment: String? = nil,
    rowGap: String? = nil,
    columnGap: String? = nil,
    media: MediaQuery? = nil
  ) -> some HTML {
    self
      .inlineStyle("display", "flex", media: media)
      .inlineStyle("flex-direction", direction, media: media)
      .inlineStyle("flex-wrap", wrap, media: media)
      .inlineStyle("justify-content", justification, media: media)
      .inlineStyle("align-items", itemAlignment, media: media)
      .inlineStyle("row-gap", rowGap, media: media)
      .inlineStyle("column-gap", columnGap, media: media)
  }

  public func flexItem(
    grow: String? = nil,
    shrink: String? = nil,
    basis: String? = nil,
    media: MediaQuery? = nil
  ) -> some HTML {
    self
      .inlineStyle("flex-grow", grow, media: media)
      .inlineStyle("flex-shrink", shrink, media: media)
      .inlineStyle("flex-basis", basis, media: media)
  }
}
