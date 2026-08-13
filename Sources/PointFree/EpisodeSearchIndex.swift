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
      Episode.all.flatMap(\.searchDocuments)
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
  private var currentTimestamp: Int?
  private var proseContent = ""
  private var proseMarkers: [[Int]] = []
  private var codeContent = ""
  private var codeMarkers: [[Int]] = []

  mutating func flush() {
    for (content, kind, markers) in [
      (sectionTitle ?? "", EpisodeSearchDocument.Kind.title, [[Int]]()),
      (proseContent, .prose, proseMarkers),
      (codeContent, .code, codeMarkers),
    ]
    where !content.isEmpty {
      documents.append(
        EpisodeSearchDocument(
          content: content,
          episodeSequence: episodeSequence,
          kind: kind,
          sectionTitle: sectionTitle,
          timestamp: sectionTimestamp,
          timestampMarkers: markers
        )
      )
    }
    proseContent = ""
    proseMarkers = []
    codeContent = ""
    codeMarkers = []
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
    currentTimestamp = nil
  }

  mutating func visitBlockDirective(_ blockDirective: BlockDirective) {
    guard blockDirective.name == "T" else { return }
    let arguments = blockDirective.argumentText.segments.map(\.trimmedText).joined()
    guard
      let time = arguments.split(separator: ",").first,
      let timestamp = seconds(fromTimestamp: time)
    else { return }
    if sectionTimestamp == nil {
      sectionTimestamp = timestamp
    }
    currentTimestamp = timestamp
  }

  mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
    if !codeContent.isEmpty {
      codeContent += "\n"
    }
    if let currentTimestamp, codeMarkers.last?.last != currentTimestamp {
      codeMarkers.append([codeContent.unicodeScalars.count, currentTimestamp])
    }
    codeContent += codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  mutating func visitParagraph(_ paragraph: Paragraph) {
    if !proseContent.isEmpty {
      proseContent += "\n"
    }
    if let currentTimestamp, proseMarkers.last?.last != currentTimestamp {
      proseMarkers.append([proseContent.unicodeScalars.count, currentTimestamp])
    }
    proseContent += paragraph.plainText
  }
}

private func seconds(fromTimestamp timestamp: Substring) -> Int? {
  let components = timestamp.split(separator: ":").map { Int($0.trimmingCharacters(in: .whitespaces)) }
  guard !components.isEmpty, components.allSatisfy({ $0 != nil }) else { return nil }
  return components.compactMap { $0 }.reduce(0) { $0 * 60 + $1 }
}
