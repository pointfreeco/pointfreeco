import Css
import Prelude

public enum GridClass {
  public static let col: CssSelector = .class("col")
  public static let col1: CssSelector = .class("col-1")
  public static let col2: CssSelector = .class("col-2")
  public static let col3: CssSelector = .class("col-3")
  public static let col4: CssSelector = .class("col-4")
  public static let col5: CssSelector = .class("col-5")
  public static let col6: CssSelector = .class("col-6")
  public static let col7: CssSelector = .class("col-7")
  public static let col8: CssSelector = .class("col-8")
  public static let col9: CssSelector = .class("col-9")
  public static let col10: CssSelector = .class("col-10")
  public static let col11: CssSelector = .class("col-11")
  public static let col12: CssSelector = .class("col-12")
  public static let colRight: CssSelector = .class("col-right")
}

public let _gridStyles: Stylesheet =
  GridClass.col % (
    float(.left)
      <> boxSizing(.borderBox)
    )
    <> GridClass.colRight % (
      float(.right)
        <> boxSizing(.borderBox)
    )
    <> gridColumnStyles

private let gridColumnStyles: Stylesheet =
  GridClass.col1 % width(.pct(1 / 12))
    <> GridClass.col2 % width(.pct(2 / 12))
    <> GridClass.col3 % width(.pct(3 / 12))
    <> GridClass.col4 % width(.pct(4 / 12))
    <> GridClass.col5 % width(.pct(5 / 12))
    <> GridClass.col6 % width(.pct(6 / 12))
    <> GridClass.col7 % width(.pct(7 / 12))
    <> GridClass.col8 % width(.pct(8 / 12))
    <> GridClass.col9 % width(.pct(9 / 12))
    <> GridClass.col10 % width(.pct(10 / 12))
    <> GridClass.col11 % width(.pct(11 / 12))
    <> GridClass.col12 % width(.pct(12 / 12))

