public struct TranscriptBlock {
  public var content: String
  public var type: BlockType

  public init(content: String, type: BlockType) {
    self.content = content
    self.type = type
  }

  public enum BlockType {
    case code(lang: CodeLang)
    case image(src: String)
    case text(timestamp: Double)
    case title(timestamp: Double)

    public enum CodeLang {
      case html
      case other(String)
      case swift

      public var identifier: String {
        switch self {
        case .html:             return "html"
        case let .other(other): return other
        case .swift:            return "swift"
        }
      }
    }
  }
}

extension TranscriptBlock.BlockType.CodeLang: Equatable {
  public static func ==(lhs: TranscriptBlock.BlockType.CodeLang, rhs: TranscriptBlock.BlockType.CodeLang) -> Bool {
    switch (lhs, rhs) {
    case (.html, .html), (.swift, .swift):
      return true
    case let (.other(lhs), .other(rhs)):
      return lhs == rhs
    case (.html, _), (.other, _), (.swift, _):
      return false
    }
  }
}

extension TranscriptBlock.BlockType: Equatable {
  public static func ==(lhs: TranscriptBlock.BlockType, rhs: TranscriptBlock.BlockType) -> Bool {
    switch (lhs, rhs) {
    case let (.code(lhs), .code(rhs)):
      return lhs == rhs
    case let (.image(lhs), .image(rhs)):
      return lhs == rhs
    case let (.text(lhs), .text(rhs)):
      return lhs == rhs
      case let (.title(lhs), .title(rhs)):
      return lhs == rhs
    case (.code, _), (.image, _), (.text, _), (.title, _):
      return false
    }
  }
}
