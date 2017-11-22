@testable import Css
@testable import Html
import Foundation
import Prelude

// TODO: move to swift-web/Display
public struct Clip: Val, Other, Auto, Inherit {
  let clip: Css.Value

  public func value() -> Css.Value {
    return self.clip
  }

  public static func other(_ other: Css.Value) -> Clip {
    return .init(clip: other)
  }

  public static let auto = Clip(clip: "auto")
  public static let inherit = Clip(clip: "inherit")
}

public func clip(_ clip: Clip) -> Stylesheet {
  return key("clip")(clip)
}

public func rect(top: Css.Size, right: Css.Size, bottom: Css.Size, left: Css.Size) -> Clip {
  return Clip(
    clip: Value(
      [
        "rect(",
        top.value().unValue,
        right.value().unValue,
        bottom.value().unValue,
        left.value().unValue,
        ")"
        ]
        .concat()
    )
  )
}

// TODO: move to swift-web
extension Display {
  public static let inline: Display = "inline"
  public static let tableCell: Display = "table-cell"
}

// TODO: move to a support package in swift-web
public func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    selectors
      .map { renderSelector($0).replacingOccurrences(of: ".", with: "") }
      .joined(separator: " ")
  )
}
