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

let toBlock = AnyConversion<(Int, String, String), Episode.TranscriptBlock>(
  apply: {
    Episode.TranscriptBlock(
      content: $2,
      speaker: $1,
      timestamp: $0,
      type: .paragraph
    )
  },
  unapply: {
    ($0.timestamp!, $0.speaker!, $0.content)
  }
)

let paragraph = Parse(toBlock) {
  timestamp
  " **".utf8
  PrefixUpTo(":** ".utf8).map(.string)
  ":** ".utf8
  OneOf {
    _PrefixUpTo {
      "\n\n".utf8
      timestamp
    }
    Rest()
  }
  .map(.string)
}

let paragraphs = Many {
  paragraph
} separator: {
  "\n\n".utf8
}
