import Models
import Parsing

public struct TimestampParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Int> {
    Parse(.timestamp) {
      "[".utf8
      Digits(2)
      ":".utf8
      Digits(2)
      ":".utf8
      Digits(2)
      "]".utf8
    }
  }
}

extension Conversion where Self == TimestampConversion {
  public static var timestamp: Self {
    TimestampConversion()
  }
}

public struct TimestampConversion: Conversion {
  public func apply(_ input: (Int, Int, Int)) -> Int {
    input.0 * 60 * 60 + input.1 * 60 + input.2
  }

  public func unapply(_ output: Int) -> (Int, Int, Int) {
    (output / 60 / 60, (output / 60) % 60, output % 60)
  }
}

public struct ImageParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock> {
    Parse(.image) {
      "![".utf8
      Episode.TranscriptBlock.BlockType.ImageSizing.parser()
      "](".utf8
      PrefixUpTo(")".utf8).map(.string)
      ")".utf8
    }
  }
}

extension Conversion where Self == ImageConversion {
  public static var image: Self {
    ImageConversion()
  }
}

public struct ImageConversion: Conversion {
  public func apply(
    _ input: (Episode.TranscriptBlock.BlockType.ImageSizing, String)
  ) -> Episode.TranscriptBlock {
    Episode.TranscriptBlock(content: "", type: .image(src: input.1, sizing: input.0))
  }

  public func unapply(
    _ output: Episode.TranscriptBlock
  ) throws -> (Episode.TranscriptBlock.BlockType.ImageSizing, String) {
    guard case let .image(src: url, sizing: sizing) = output.type
    else {
      struct InvalidBlockType: Error {}
      throw InvalidBlockType()
    }
    return (sizing, url)
  }
}

public struct BoxTypeByNameParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock.BlockType.Box> {
    Parse(
      AnyConversion(
        apply: Episode.TranscriptBlock.BlockType.Box.init(name:),
        unapply: \.name
      )
    ) {
      PrefixUpTo("]".utf8).map(.string)
    }
  }
}

public struct BoxTypeByFullDetailsParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock.BlockType.Box> {
    Parse(.memberwise(Episode.TranscriptBlock.BlockType.Box.init)) {
      Optionally {
        Not { "#".utf8 }
        PrefixUpTo(", ".utf8).map(.string)
        ", ".utf8
      }
      "#".utf8
      Prefix(6) { $0.isHexDigit }.map(.string)
      ", #".utf8
      Prefix(6) { $0.isHexDigit }.map(.string)
    }
  }
}

public struct BoxTypeParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock.BlockType.Box> {
    "!> [".utf8
    OneOf {
      BoxTypeByFullDetailsParser()
      BoxTypeByNameParser()
    }
    "]: ".utf8
  }
}

public struct BoxMessageParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, String> {
    Many {
      OneOf {
        PrefixUpTo("\n".utf8)
        Rest()
      }
      .map(.string)
    } separator: {
      "\n> ".utf8
    }
    .map(.box)
  }
}

extension Conversion where Self == BoxConversion {
  fileprivate static var box: Self { BoxConversion() }
}

private struct BoxConversion: Conversion {
  func apply(_ input: [String]) -> String {
    input.joined(separator: "\n")
  }
  func unapply(_ output: String) -> [String] {
    output.split(separator: "\n").map(String.init)
  }
}

public struct BoxParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock> {
    Parse(
      AnyConversion(
        apply: { boxType, message in
          Episode.TranscriptBlock(
            content: message,
            type: .box(boxType)
          )
        },
        unapply: {
          guard case let .box(boxType) = $0.type
          else { return nil }
          return (boxType, $0.content)
        }
      )
    ) {
      BoxTypeParser()
      BoxMessageParser()
    }
  }
}

public struct TitlePreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    Peek {
      TimestampParser()
      " # ".utf8
    }
  }
}

public struct BoxPreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    Peek {
      "!> [".utf8
    }
  }
}

public struct ImagePreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    Peek {
      "![".utf8
    }
  }
}

public struct ParagraphPreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    Peek {
      TimestampParser()
      " ".utf8
    }
  }
}

public struct ButtonPreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    Peek {
      "[[".utf8
    }
  }
}

public struct PreambleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Void> {
    "\n\n".utf8
    OneOf {
      ButtonPreambleParser()
      BoxPreambleParser()
      TitlePreambleParser()
      ImagePreambleParser()
      ParagraphPreambleParser()
    }
  }
}

public struct TitleParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock> {
    Parse(
      AnyConversion(
        apply: { Episode.TranscriptBlock(content: $1, timestamp: $0, type: .title) },
        unapply: { $0.type == .title ? ($0.timestamp!, $0.content) : nil }
      )
    ) {
      TimestampParser()
      " # ".utf8
      OneOf {
        PrefixUpTo("\n".utf8)
        Rest()
      }
      .map(.string)
    }
  }
}

public struct ButtonParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock> {
    Parse(
      AnyConversion(
        apply: { title, href in
          Episode.TranscriptBlock(content: title, type: .button(href: href))
        },
        unapply: { block in
          guard case let .button(href: href) = block.type
          else { return nil }
          return (block.content, href)
        }
      )
    ) {
      "[[".utf8
      PrefixUpTo("]".utf8).map(.string)
      "]](".utf8
      PrefixUpTo(")".utf8).map(.string)
      ")".utf8
    }
  }
}

public struct ParagraphParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, Episode.TranscriptBlock> {
    Parse(.string.map(MarkdownBlockConversion())) {
      OneOf {
        _PrefixUpTo { PreambleParser() }
        _Rest()
      }
    }
  }
}

public struct MarkdownBlockParser: ParserPrinter {
  public var body: some ParserPrinter<Substring.UTF8View, (Int?, String?, String)> {
    Optionally {
      TimestampParser()
      " ".utf8
    }
    Not { "# ".utf8 }
    Optionally {
      "**".utf8
      PrefixUpTo(":** ".utf8).map(.string)
      ":** ".utf8
    }
    Rest().map(.string)
  }
}

public struct MarkdownBlockConversion: Conversion {
  public func apply(_ input: String) throws -> Episode.TranscriptBlock {
    let output = try MarkdownBlockParser().parse(input)
    return Episode.TranscriptBlock(
      content: output.2,
      speaker: output.1,
      timestamp: output.0,
      type: .paragraph
    )
  }

  public func unapply(_ output: Episode.TranscriptBlock) throws -> String {
    guard output.type == .paragraph
    else {
      struct NonParagraphBlockError: Error {}
      throw NonParagraphBlockError()
    }
    return try String(
      Substring(
        MarkdownBlockParser().print(
          (output.timestamp, output.speaker, output.content)
        )
      )
    )
  }
}

public struct CodeBlockParser: ParserPrinter {
  private struct CodeBlockError: Error {}

  public func parse(_ input: inout Substring.UTF8View) throws -> Episode.TranscriptBlock {
    throw CodeBlockError()
  }
  public func print(_ output: Episode.TranscriptBlock, into input: inout Substring.UTF8View) throws
  {
    guard case let .code(lang: lang) = output.type
    else { throw CodeBlockError() }

    input.prepend(
      contentsOf: """
        ```\(lang.identifier)
        \(output.content)
        ```
        """.utf8
    )
  }
}

public let blocksParser = Many {
  OneOf {
    CodeBlockParser()
    ButtonParser()
    BoxParser()
    ImageParser()
    TitleParser()
    ParagraphParser()
  }
} separator: {
  "\n\n".utf8
} terminator: {
  Whitespace().printing("\n".utf8)
}

extension UTF8.CodeUnit {
  fileprivate var isHexDigit: Bool {
    (.init(ascii: "0") ... .init(ascii: "9")).contains(self)
      || (.init(ascii: "A") ... .init(ascii: "F")).contains(self)
      || (.init(ascii: "a") ... .init(ascii: "f")).contains(self)
  }
}
