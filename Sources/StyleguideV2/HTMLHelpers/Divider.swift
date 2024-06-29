public struct Divider: HTML {
  public init () {}
  public var body: some HTML {
    div {}
      .backgroundColor(.gray800.dark(.gray300))
      .inlineStyle("margin", "0 30%")
      .inlineStyle("height", "1px")
  }
}
