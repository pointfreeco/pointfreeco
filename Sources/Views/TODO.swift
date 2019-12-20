import Css
import Html
import HtmlUpgrade
import HttpPipeline
import Models
import PointFreeRouter
import Tagged

extension Tagged where Tag == EncryptedTag, RawValue == String {
  public init?(_ text: String, with secret: AppSecret) {
    guard
      let string = encrypted(text: text, secret: secret.rawValue)
      else { return nil }
    self.init(rawValue: string)
  }

  public func decrypt(with secret: AppSecret) -> String? {
    return decrypted(text: self.rawValue, secret: secret.rawValue)
  }
}

public func playsinline(_ value: Bool) -> Html.Attribute<Html.Tag.Video> {
  return .init("playslinline", value ? "" : nil)
}

extension HtmlUpgrade.Attribute {
  public static func id<T>(_ idSelector: CssSelector) -> HtmlUpgrade.Attribute<T> {
    return .init("id", idSelector.idString ?? "")
  }
}

extension HtmlUpgrade.Attribute {
  public static func playsinline<T>(_ value: Bool) -> HtmlUpgrade.Attribute<T> {
    return .init("playslinline", value ? "" : nil)
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
