import Models
import Parsing

public let timestamp = Parse(Timestamp()) {
  "[".utf8
  Digits(2)
  ":".utf8
  Digits(2)
  ":".utf8
  Digits(2)
  "]".utf8
}

public let image = Parse {
  "![".utf8
  Episode.TranscriptBlock.BlockType.ImageSizing.parser()
  "](".utf8
  PrefixUpTo(")".utf8).map(.string)
  ")".utf8
}
.map(
  AnyConversion(
    apply: { sizing, url in
      Episode.TranscriptBlock(content: "", type: .image(src: url, sizing: sizing))
    },
    unapply: {
      guard case let .image(src: url, sizing: sizing) = $0.type
      else { return nil }
      return (sizing, url)
    }))

public let boxTypeByName = Parse {
  PrefixUpTo("]".utf8).map(.string)
}
.map(
  AnyConversion(
    apply: Episode.TranscriptBlock.BlockType.Box.init(name:),
    unapply: \.name
  ))

public let boxTypeByFullDetails = Parse(.memberwise(Episode.TranscriptBlock.BlockType.Box.init)) {
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

public let boxType = Parse {
  "!> [".utf8
  OneOf {
    boxTypeByFullDetails
    boxTypeByName
  }
  "]: ".utf8
}

public let boxMessage = Many {
  OneOf {
    PrefixUpTo("\n".utf8)
    Rest()
  }
  .map(.string)
} separator: {
  "\n> ".utf8
}
.map(
  AnyConversion(
    apply: { $0.joined(separator: "\n") },
    unapply: { $0.split(separator: "\n").map(String.init) }
  )
)

public let box = Parse {
  boxType
  boxMessage
}
.map(
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
)

public let titlePreamble = Peek {
  timestamp
  " # ".utf8
}
public let boxPreamble = Peek {
  "!> [".utf8
}
public let imagePreamble = Peek {
  "![".utf8
}
public let paragraphPreamble = Peek {
  timestamp
  " ".utf8
}

public let preamble = Parse {
  "\n\n".utf8
  OneOf {
    boxPreamble
    titlePreamble
    imagePreamble
    paragraphPreamble
  }
}

public let title = Parse {
  timestamp
  " # ".utf8
  OneOf {
    PrefixUpTo("\n".utf8)
    Rest()
  }
  .map(.string)
}
.map(
  AnyConversion(
    apply: { Episode.TranscriptBlock(content: $1, timestamp: $0, type: .title) },
    unapply: { $0.type == .title ? ($0.timestamp!, $0.content) : nil }
  ))

public let paragraph = Parse {
  OneOf {
    _PrefixUpTo { preamble }
    _Rest()
  }
}
.map(.string)
.map(MarkdownBlockConversion())

public let markdownBlockParser = Parse {
  Optionally {
    timestamp
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

public struct MarkdownBlockConversion: Conversion {
  public func apply(_ input: String) throws -> Episode.TranscriptBlock {
    let output = try markdownBlockParser.parse(input)
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
        markdownBlockParser.print(
          (output.timestamp, output.speaker, output.content)
        )
      )
    )
  }
}

public struct CodeBlock: ParserPrinter {
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
    CodeBlock()
    box
    image
    title
    paragraph
  }
} separator: {
  "\n\n".utf8
}

public struct Timestamp: Conversion {
  public func apply(_ input: (Int, Int, Int)) throws -> Int {
    input.0 * 60 * 60 + input.1 * 60 + input.2
  }

  public func unapply(_ output: Int) throws -> (Int, Int, Int) {
    (output / 60 / 60, (output / 60) % 60, output % 60)
  }
}

extension UTF8.CodeUnit {
  fileprivate var isHexDigit: Bool {
    (.init(ascii: "0") ... .init(ascii: "9")).contains(self)
      || (.init(ascii: "A") ... .init(ascii: "F")).contains(self)
      || (.init(ascii: "a") ... .init(ascii: "f")).contains(self)
  }
}
