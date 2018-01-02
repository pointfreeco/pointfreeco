import Css
import Prelude

extension Class {
  public enum type {
    public static let caps = CssSelector.class("caps")

    /// Sets the line height to an absolute value. The inputs of 1 through 4 correspond to
    /// 1.15, 1.25, 1.45, 1.5
    public static func lineHeight(_ n: Int) -> CssSelector {
      return CssSelector.class("lh-\(n)")
    }

    /// Sets the line height to a rem multiple
    public static func lineHeight(rem: Int) -> CssSelector {
      return CssSelector.class("lh-\(rem)r")
    }

    public static let bold = CssSelector.class("bold")
    public static let bolder = CssSelector.class("bolder")
    public static let italic = CssSelector.class("italic")
    public static let light = CssSelector.class("light")
    public static let lighter = CssSelector.class("lighter")
    public static let medium = CssSelector.class("medium")
    public static let normal = CssSelector.class("normal")
    public static let semiBold = CssSelector.class("semi-bold")
    public static let underline = CssSelector.class("underline")

    public static let fontFamilyInherit = CssSelector.class("font-family-inherit")
    public static let fontSizeInherit = CssSelector.class("font-size-inherit")
    public static let textDecorationNone = CssSelector.class("text-decoration-none")

    public enum list {
      public static let styleNone = CssSelector.class("list-style-none")
      public static let reset = CssSelector.class("list-reset")
    }

    public static let align = (
      start: CssSelector.class("start-align"),
      center: CssSelector.class("center"),
      end: CssSelector.class("end-align"),
      justify: CssSelector.class("justify")
    )
  }
}

public let typography: Stylesheet =
  emphasisStyles
    <> lineHeightStyles
    <> miscStyles
    <> listStyles
    <> _alignStyles

private let lineHeightStyles: Stylesheet =
  [1.15, 1.25, 1.45, 1.5].enumerated().map { Class.type.lineHeight($0) % lineHeight($1) }.concat()
    <> [1, 2, 3, 4].map { Class.type.lineHeight(rem: $0) % lineHeight(.rem(Double($0))) }.concat()

private let italicStyle = Class.type.italic % fontStyle(.italic)
private let lightStyle = Class.type.light % fontWeight(.w300)
private let lighterStyle = Class.type.lighter % fontWeight(.lighter)
private let normalStyle = Class.type.normal % fontWeight(.normal)
private let underlineStyle = Class.type.underline % key("text-decoration", "underline")

private let emphasisStyles: Stylesheet =
  boldStyles
    <> capsStyles
    <> italicStyle
    <> lightStyle
    <> lighterStyle
    <> normalStyle
    <> underlineStyle

private let capsStyles =
  Class.type.caps % (
    textTransform(.uppercase)
      <> letterSpacing(.pt(0.54))
)

private let boldStyles =
  Class.type.bold % fontWeight(.w700)
    <> Class.type.bolder % fontWeight(.bolder)
    <> Class.type.medium % fontWeight(.w500)
    <> Class.type.semiBold % fontWeight(.w600)

private let miscStyles: Stylesheet =
  Class.type.fontFamilyInherit % fontFamily(.inherit)
    <> Class.type.fontSizeInherit % fontSize(.inherit)
    <> Class.type.textDecorationNone % key("text-decoration", "none")

private let listStyles: Stylesheet =
  Class.type.list.styleNone % listStyleType(.none)
  <> Class.type.list.reset % (
    listStyleType(.none)
      <> padding(left: 0)
)

private let _alignStyles =
  Class.type.align.start % textAlign(.start)
    <> Class.type.align.center % textAlign(.center)
    <> Class.type.align.end % textAlign(.end)
    <> Class.type.align.justify % textAlign(.justify)

//
//.nowrap { white-space: nowrap }
//.break-word { word-wrap: break-word }
//
//.truncate {
//  max-width: 100%;
//  overflow: hidden;
//  text-overflow: ellipsis;
//  white-space: nowrap;
//}
//
