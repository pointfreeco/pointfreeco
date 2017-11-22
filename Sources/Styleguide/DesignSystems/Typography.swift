import Css
import Prelude

extension Class {
  public enum type {
    public static let caps = CssSelector.class("caps")
    public static let lineHeight1 = CssSelector.class("line-height-1")
    public static let lineHeight2 = CssSelector.class("line-height-2")
    public static let lineHeight3 = CssSelector.class("line-height-3")
    public static let lineHeight4 = CssSelector.class("line-height-4")
  }
}

public let designSystemsTypography: Stylesheet =
  Class.type.caps % (
    textTransform(.uppercase)
      <> letterSpacing(.pt(0.54))
      )
    <> Class.type.lineHeight1 % lineHeight(1.15)
    <> Class.type.lineHeight2 % lineHeight(1.25)
    <> Class.type.lineHeight3 % lineHeight(1.45)
    <> Class.type.lineHeight4 % lineHeight(1.5)


//
///* Basscss Typography */
//
//.font-family-inherit { font-family: inherit }
//.font-size-inherit { font-size: inherit }
//.text-decoration-none { text-decoration: none }
//
//.bold    { font-weight: var(--bold-font-weight, bold) }
//.regular { font-weight: normal }
//.italic  { font-style: italic }
//.caps    { text-transform: uppercase; letter-spacing: var(--caps-letter-spacing); }
//
//.left-align   { text-align: left }
//.center       { text-align: center }
//.right-align  { text-align: right }
//.justify      { text-align: justify }
//
//.nowrap { white-space: nowrap }
//.break-word { word-wrap: break-word }
//
//.line-height-1 { line-height: var(--line-height-1) }
//.line-height-2 { line-height: var(--line-height-2) }
//.line-height-3 { line-height: var(--line-height-3) }
//.line-height-4 { line-height: var(--line-height-4) }
//
//.list-style-none { list-style: none }
//.underline { text-decoration: underline }
//
//.truncate {
//  max-width: 100%;
//  overflow: hidden;
//  text-overflow: ellipsis;
//  white-space: nowrap;
//}
//
//.list-reset {
//  list-style: none;
//  padding-left: 0;
//}
//
//:root {
//  --line-height-1: 1.15;
//  --line-height-2: 1.25;
//  --line-height-3: 1.45;
//  --line-height-4: 1.5;
//  --letter-spacing: 1;
//  --caps-letter-spacing: 0.54pt;
//  --bold-font-weight: 700;
//}

