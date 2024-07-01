public struct Divider: HTML {
  public init () {}
  public var body: some HTML {
    hr()
      .inlineStyle("border", "none")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray800.rawValue)")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray300.rawValue)", media: .dark)
      .inlineStyle("margin", "0 30%")
  }
}
