import Foundation

public struct SVG: HTML {
  let base64: String
  let description: String

  public init(_ description: String, content: () -> String) {
    self.init(base64: Data(content().utf8).base64EncodedString(), description: description)
  }

  public init(base64: String, description: String) {
    self.base64 = base64
    self.description = description
  }

  public var body: some HTML {
    img()
      .attribute("src", "data:image/svg+xml;base64,\(base64)")
      .attribute("alt", description)
  }
}
