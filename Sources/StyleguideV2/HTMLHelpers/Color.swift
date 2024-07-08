extension HTML {
  public func backgroundColor(_ color: PointFreeColor?) -> some HTML {
    inlineStyle("background-color", color?.rawValue)
      .inlineStyle("background-color", color?.darkValue, media: .dark)
  }

  public func background(_ color: PointFreeColor?) -> some HTML {
    inlineStyle("background", color?.rawValue)
      .inlineStyle("background", color?.darkValue, media: .dark)
  }

  public func color(
    _ color: PointFreeColor?,
    _ pseudo: Pseudo? = nil
  ) -> some HTML {
    inlineStyle("color", color?.rawValue, pseudo: pseudo)
      .inlineStyle("color", color?.darkValue, media: .dark, pseudo: pseudo)
  }
}

public struct PointFreeColor {
  public var rawValue: String
  public var darkValue: String?

  public init(rawValue: String, darkValue: String? = nil) {
    self.rawValue = rawValue
    self.darkValue = darkValue
  }

  public func dark(_ other: Self) -> Self { Self(rawValue: rawValue, darkValue: other.rawValue) }
  public func light(_ other: Self) -> Self { Self(rawValue: other.rawValue, darkValue: darkValue) }

  public static let black = Self(rawValue: "#121212")
  public static let offBlack = Self(rawValue: "#171717")
  public static let blue = Self(rawValue: "#4cccff")
  public static let blue900 = Self(rawValue: "#e6f8ff")
  public static let gray150 = Self(rawValue: "#242424")
  public static let gray300 = Self(rawValue: "#555555")
  public static let gray400 = Self(rawValue: "#666666")
  public static let gray500 = Self(rawValue: "#808080")
  public static let gray650 = Self(rawValue: "#a8a8a8")
  public static let gray800 = Self(rawValue: "#ccc")
  public static let gray850 = Self(rawValue: "#d8d8d8")
  public static let gray900 = Self(rawValue: "#f6f6f6")
  public static let green = Self(rawValue: "#79f2b0")
  public static let purple = Self(rawValue: "#974dff")
  public static let purple150 = Self(rawValue: "#291a40")
  public static let red = Self(rawValue: "#eb1c26")
  public static let yellow = Self(rawValue: "#fff080")
  public static let white = Self(rawValue: "#fff")
  public static let offWhite = Self(rawValue: "#fafafa")

  public static func gray(_ value: UInt8) -> Self {
    var hex = String(value, radix: 16)
    if hex.count == 1 { hex.insert("0", at: hex.startIndex) }
    var darkHex = String(255 - value, radix: 16)
    if darkHex.count == 1 { darkHex.insert("0", at: darkHex.startIndex) }
    return Self(rawValue: "#\(hex)\(hex)\(hex)")
      .dark(Self(rawValue: "#\(darkHex)\(darkHex)\(darkHex)"))
  }

  @_disfavoredOverload
  public static func gray(_ value: Double) -> Self {
    gray(UInt8(255 * value))
  }

  public static let currentColor = Self(rawValue: "currentColor")
}
