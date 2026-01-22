public struct Divider: HTML {
  let alignment: Alignment
  let size: Int
  let color: PointFreeColor
  public init(
    alignment: Alignment = .center,
    size: Int = 40,
    color: PointFreeColor = PointFreeColor(
      rawValue: PointFreeColor.gray800.rawValue,
      darkValue: PointFreeColor.gray300.rawValue
    )
  ) {
    self.alignment = alignment
    self.size = size
    self.color = color
  }
  public var body: some HTML {
    hr()
      .inlineStyle("border", "none")
      .inlineStyle("border-top", "1px solid \(color.rawValue)")
      .inlineStyle("border-top", "1px solid \(color.darkValue ?? color.rawValue)", media: .dark)
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
