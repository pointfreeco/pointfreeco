import Css
import Html
import HtmlUpgrade

public func playsinline(_ value: Bool) -> Html.Attribute<Html.Tag.Video> {
  return .init("playslinline", value ? "" : nil)
}

extension HtmlUpgrade.Attribute {
  public static func id<T>(_ idSelector: CssSelector) -> HtmlUpgrade.Attribute<T> {
    return .init("id", idSelector.idString ?? "")
  }
}

extension HtmlUpgrade.Attribute where Element: HtmlUpgrade.HasFor {
  public static func `for`(_ idSelector: CssSelector) -> HtmlUpgrade.Attribute<Element> {
    return .init("for", idSelector.idString ?? "")
  }
}

extension HtmlUpgrade.ChildOf where Element == HtmlUpgrade.Tag.Head {
  public static func style(
    attributes: [HtmlUpgrade.Attribute<HtmlUpgrade.Tag.Style>] = [],
    _ css: Stylesheet,
    config: Css.Config = .compact
    )
    -> HtmlUpgrade.ChildOf<HtmlUpgrade.Tag.Head> {
      return .style(unsafe: render(config: config, css: css))
  }
}
