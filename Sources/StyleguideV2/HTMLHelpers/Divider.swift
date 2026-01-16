public struct Divider: HTML {
  let alignment: Alignment
  let size: Int
  public init(
    alignment: Alignment = .center,
    size: Int = 40
  ) {
    self.alignment = alignment
    self.size = size
  }
  public var body: some HTML {
    hr()
      .inlineStyle("border", "none")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray800.rawValue)")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray300.rawValue)", media: .dark)
      .inlineStyle("margin-left", marginLeft)
      .inlineStyle("margin-right", marginRight)
  }

  var marginLeft: String {
    switch alignment {
    case .left:
      "0"
    case .center:
      "\((100-size)/2)%"
    case .right:
      "\(100 - size)%"
    }
  }
  var marginRight: String {
    switch alignment {
    case .left:
      "\(100 - size)%"
    case .center:
      "\((100-size)/2)%"
    case .right:
      "0"
    }
  }

  public enum Alignment {
    case left, center, right
  }
}
