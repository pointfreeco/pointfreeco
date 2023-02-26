import Parsing

struct Timestamp: Conversion {
  func apply(_ input: (Int, Int, Int)) throws -> Int {
    input.0 * 60 * 60 + input.1 * 60 + input.2
  }

  func unapply(_ output: Int) throws -> (Int, Int, Int) {
    (output / 60 / 60, (output / 60) % 60, output % 60)
  }
}

let timestamp = Parse(Timestamp()) {
  "[".utf8
  Digits(2)
  ":".utf8
  Digits(2)
  ":".utf8
  Digits(2)
  "]".utf8
}

struct _PrefixUpTo<Upstream: Parser>: Parser
where
  Upstream.Input: Collection,
  Upstream.Input == Upstream.Input.SubSequence
{
  struct SuffixNotFound: Error {}

  let upstream: Upstream

  init(@ParserBuilder _ upstream: () -> Upstream) {
    self.upstream = upstream()
  }

  func parse(_ input: inout Upstream.Input) throws -> Upstream.Input {
    let original = input
    var copy = input
    while (try? self.upstream.parse(&copy)) == nil {
      guard !input.isEmpty else {
        throw SuffixNotFound()
      }
      input.removeFirst()
      copy = input
    }
    return original[..<input.startIndex]
  }
}

extension _PrefixUpTo: ParserPrinter
where
  Upstream: ParserPrinter,
  Upstream.Input: PrependableCollection
{
  func print(_ output: Upstream.Input, into input: inout Upstream.Input) throws {
    input.prepend(contentsOf: output)
    var copy = input
    _ = try self.parse(&copy)
  }
}

let boxTypeByFullDetails = Parse(.memberwise(Episode.TranscriptBlock.BlockType.Box.init)) {
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

let boxType = Parse {
  "!> [".utf8
  OneOf {
    boxTypeByFullDetails
    boxTypeByName
  }
  "]: ".utf8
}

let boxTypeByName = Parse {
  PrefixUpTo("]".utf8).map(.string)
}
.map(AnyConversion(
  apply: Episode.TranscriptBlock.BlockType.Box.init(name:),
  unapply: \.name
))

let boxMessage = Many {
  OneOf {
    PrefixUpTo("\n".utf8)
    Rest()
  }
  .map(.string)
} separator: {
  "\n> ".utf8
}
  .map(AnyConversion(
    apply: { $0.joined(separator: "\n") },
    unapply: { $0.split(separator: "\n").map(String.init) }
  ))

let box = Parse {
  boxType
  boxMessage
}
  .map(AnyConversion(
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
  ))

let titlePreamble = Peek {
  timestamp
  " # ".utf8
}
let paragraphPreamble = Peek {
  timestamp
  " ".utf8
}
let boxPreamble = Peek {
  "!> [".utf8
}

let preamble = Parse {
  "\n\n".utf8
  OneOf {
    boxPreamble
    titlePreamble
    paragraphPreamble
  }
}

let title = Parse {
  timestamp
  " # ".utf8
  OneOf {
    PrefixUpTo("\n".utf8)
    Rest()
  }
  .map(.string)
}
  .map(AnyConversion(
    apply: { Episode.TranscriptBlock(content: $1, timestamp: $0, type: .title) },
    unapply: { $0.type == .title ? ($0.timestamp!, $0.content) : nil }
  ))

let paragraphWithMetadata = Parse {
  timestamp
  Not { " # ".utf8 }
  Optionally {
    " **".utf8
    PrefixUpTo(":** ".utf8).map(.string)
    ":**".utf8
  }
  " ".utf8
  OneOf {
    _PrefixUpTo { preamble }
    Rest()
  }
  .map(.string)
}
  .map(AnyConversion(
    apply: {
      Episode.TranscriptBlock(content: $2, speaker: $1, timestamp: $0, type: .paragraph)
    },
    unapply: {
      $0.type == .paragraph ? ($0.timestamp!, $0.speaker, $0.content) : nil
    }
  ))
let rawParagraph = Parse {
  Not { timestamp }
  OneOf {
    _PrefixUpTo { preamble }
    Rest()
  }
}
  .map(.string)
  .map(AnyConversion(
    apply: { Episode.TranscriptBlock(content: $0, type: .paragraph) },
    unapply: { $0.type == .paragraph && $0.timestamp == nil ? $0.content : nil }
  ))
let paragraph = OneOf {
  paragraphWithMetadata
  rawParagraph
}

let blocksParser = Many {
  OneOf {
    box
    title
    paragraph
  }
} separator: {
  "\n\n".utf8
}

extension UTF8.CodeUnit {
  fileprivate var isHexDigit: Bool {
    (.init(ascii: "0") ... .init(ascii: "9")).contains(self)
    || (.init(ascii: "A") ... .init(ascii: "F")).contains(self)
    || (.init(ascii: "a") ... .init(ascii: "f")).contains(self)
  }
}
