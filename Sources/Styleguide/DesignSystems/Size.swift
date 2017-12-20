import Css
import Prelude

extension Class {
  public enum size {
    /// Sets the height to a rem multiple.
    public static func height(rem: Int) -> CssSelector {
      return .class("h-\(rem)r")
    }

    public static let width50pct = CssSelector.class("w-50p")
    public static let width100pct = CssSelector.class("w-100p")
  }
}

public let sizeStyles =
  heightStyles
    <> widthStyles

private let heightStyles: Stylesheet =
  [1, 2, 3, 4].map { Class.size.height(rem: $0) % height(.rem(Double($0))) }.concat()

private let widthStyles =
  Class.size.width50pct % width(.pct(50))
    <> Class.size.width100pct % width(.pct(100))
