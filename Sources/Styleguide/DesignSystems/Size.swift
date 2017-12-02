import Css
import Prelude

extension Class {
  public enum size {
    /// Sets the height to a rem multiple.
    public static func height(rem: Int) -> CssSelector {
      return .class("h-\(rem)r")
    }
  }
}

public let heightStyles: Stylesheet =
  [1, 2, 3, 4].map { Class.size.height(rem: $0) % height(.rem(Double($0))) }.concat()
