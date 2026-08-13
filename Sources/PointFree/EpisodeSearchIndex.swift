import Dependencies
import IssueReporting
import Markdown
import Models
import Transcripts

func refreshEpisodeSearchIndex() async {
  print("  ⏳ Refreshing episode search index")
  defer { print("  ✅ Episode search index refreshed") }

  @Dependency(\.database) var database

  await withErrorReporting {
    try await database.refreshEpisodeSearchIndex(
      Episode.all.flatMap { $0.searchDocuments }
    )
  }
}

extension Episode {
  var searchDocuments: [EpisodeSearchDocument] {
    let blurb = proseText(markdown: blurb)
    var documents = [
      EpisodeSearchDocument(
        content: fullTitle,
        episodeSequence: sequence,
        kind: .episodeTitle,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: blurb.isEmpty ? self.blurb : blurb,
        episodeSequence: sequence,
        kind: .blurb,
        sectionTitle: nil,
        timestamp: nil
      ),
    ]
    if hasTranscript, let transcript {
      documents.append(
        contentsOf: transcriptSearchDocuments(episodeSequence: sequence, transcript: transcript)
      )
    }
    return documents
  }
}

func transcriptSearchDocuments(
  episodeSequence: Episode.Sequence,
  transcript: String
) -> [EpisodeSearchDocument] {
  var visitor = SearchDocumentVisitor(episodeSequence: episodeSequence)
  visitor.visit(Document(parsing: transcript, options: .parseBlockDirectives))
  visitor.flush()
  return visitor.documents
}

private func proseText(markdown: String) -> String {
  Document(parsing: markdown)
    .children
    .compactMap { ($0 as? Paragraph)?.plainText }
    .joined(separator: "\n")
}

private struct SearchDocumentVisitor: MarkupVisitor {
  typealias Result = Void

  let episodeSequence: Episode.Sequence
  var documents: [EpisodeSearchDocument] = []
  private var sectionTitle: String?
  private var sectionTimestamp: Int?
  private var proseLines: [String] = []
  private var codeLines: [String] = []

  mutating func flush() {
    let title = sectionTitle ?? ""
    let prose = proseLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    let code = codeLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    proseLines = []
    codeLines = []
    for (content, kind) in [
      (title, EpisodeSearchDocument.Kind.title), (prose, .prose), (code, .code),
    ]
    where !content.isEmpty {
      documents.append(
        EpisodeSearchDocument(
          content: content,
          episodeSequence: episodeSequence,
          kind: kind,
          sectionTitle: sectionTitle,
          timestamp: sectionTimestamp
        )
      )
    }
  }

  mutating func defaultVisit(_ markup: any Markup) {
    for child in markup.children {
      visit(child)
    }
  }

  mutating func visitHeading(_ heading: Heading) {
    flush()
    sectionTitle = heading.plainText
    sectionTimestamp = nil
  }

  mutating func visitBlockDirective(_ blockDirective: BlockDirective) {
    guard blockDirective.name == "T", sectionTimestamp == nil else { return }
    let arguments = blockDirective.argumentText.segments.map(\.trimmedText).joined()
    guard let time = arguments.split(separator: ",").first else { return }
    sectionTimestamp = seconds(fromTimestamp: time)
  }

  mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
    codeLines.append(codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  mutating func visitParagraph(_ paragraph: Paragraph) {
    proseLines.append(paragraph.plainText)
  }
}

private func seconds(fromTimestamp timestamp: Substring) -> Int? {
  let components = timestamp.split(separator: ":").map { Int($0.trimmingCharacters(in: .whitespaces)) }
  guard !components.isEmpty, components.allSatisfy({ $0 != nil }) else { return nil }
  return components.compactMap { $0 }.reduce(0) { $0 * 60 + $1 }
}
