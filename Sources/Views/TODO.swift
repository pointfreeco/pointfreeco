import Css
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

extension Attribute {
  public static func id<T>(_ idSelector: CssSelector) -> Attribute<T> {
    return .init("id", idSelector.idString ?? "")
  }
}

extension Attribute {
  public static func playsinline<T>(_ value: Bool) -> Attribute<T> {
    return .init("playslinline", value ? "" : nil)
  }
}

extension Attribute where Element: HasFor {
  public static func `for`(_ idSelector: CssSelector) -> Attribute<Element> {
    return .init("for", idSelector.idString ?? "")
  }
}

extension ChildOf where Element == Tag.Head {
  public static func style(
    attributes: [Attribute<Tag.Style>] = [],
    _ css: Stylesheet,
    config: Css.Config = .compact
    )
    -> ChildOf<Tag.Head> {
      return .style(unsafe: render(config: config, css: css))
  }
}
