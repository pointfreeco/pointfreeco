import Foundation

public struct SVG: HTML {
  private enum Storage {
    case raw(String)
    case base64(String)
  }

  let description: String
  private let storage: Storage

  public init(_ description: String, content: () -> String) {
    self.storage = .raw(content())
    self.description = description
  }

  public init(base64: String, description: String) {
    self.storage = .base64(base64)
    self.description = description
  }

  public var body: some HTML {
    HTMLGroup {
      switch storage {
      case let .raw(raw):
        HTMLRaw(raw)
      case let .base64(base64):
        img()
          .attribute("src", "data:image/svg+xml;base64,\(base64)")
      }
    }
    .attribute("alt", description)
  }
}
