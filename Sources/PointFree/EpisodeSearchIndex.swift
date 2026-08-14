import Dependencies
import Foundation
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
    let blurb = Document(parsing: blurb)
      .children
      .compactMap { ($0 as? Paragraph)?.plainText }
      .joined(separator: "\n")
    var documents = [
      EpisodeSearchDocument(
        content: fullTitle,
        episodeSequence: sequence,
        kind: .episodeTitle,
        publishedAt: publishedAt,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: blurb.isEmpty ? self.blurb : blurb,
        episodeSequence: sequence,
        kind: .blurb,
        publishedAt: publishedAt,
        sectionTitle: nil,
        timestamp: nil
      ),
    ]
    if hasTranscript, let transcript {
      documents.append(
        contentsOf: transcriptSearchDocuments(
          episodeSequence: sequence,
          publishedAt: publishedAt,
          transcript: transcript
        )
      )
    }
    return documents
  }
}

func transcriptSearchDocuments(
  episodeSequence: Episode.Sequence,
  publishedAt: Date,
  transcript: String
) -> [EpisodeSearchDocument] {
  var visitor = SearchDocumentVisitor(episodeSequence: episodeSequence, publishedAt: publishedAt)
  visitor.visit(Document(parsing: transcript, options: .parseBlockDirectives))
  visitor.flush()
  return visitor.documents
}

private struct SearchDocumentVisitor: MarkupVisitor {
  typealias Result = Void

  let episodeSequence: Episode.Sequence
  let publishedAt: Date
  var documents: [EpisodeSearchDocument] = []

  init(episodeSequence: Episode.Sequence, publishedAt: Date) {
    self.episodeSequence = episodeSequence
    self.publishedAt = publishedAt
  }
  private var sectionTitle: String?
  private var sectionTimestamp: Int?
  private var currentTimestamp: Int?
  private var proseContent = ""
  private var proseMarkers: [EpisodeSearchDocument.TimestampMarker] = []
  private var codeContent = ""
  private var codeMarkers: [EpisodeSearchDocument.TimestampMarker] = []

  mutating func flush() {
    for (content, kind, markers) in [
      (sectionTitle ?? "", EpisodeSearchDocument.Kind.title, []),
      (proseContent, .prose, proseMarkers),
      (codeContent, .code, codeMarkers),
    ]
    where !content.isEmpty {
      documents.append(
        EpisodeSearchDocument(
          content: content,
          episodeSequence: episodeSequence,
          kind: kind,
          publishedAt: publishedAt,
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
    if let currentTimestamp, codeMarkers.last?.seconds != currentTimestamp {
      codeMarkers.append(
        EpisodeSearchDocument.TimestampMarker(
          offset: codeContent.unicodeScalars.count,
          seconds: currentTimestamp
        )
      )
    }
    codeContent += codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  mutating func visitParagraph(_ paragraph: Paragraph) {
    if !proseContent.isEmpty {
      proseContent += "\n"
    }
    if let currentTimestamp, proseMarkers.last?.seconds != currentTimestamp {
      proseMarkers.append(
        EpisodeSearchDocument.TimestampMarker(
          offset: proseContent.unicodeScalars.count,
          seconds: currentTimestamp
        )
      )
    }
    proseContent += paragraph.plainText
  }
}

private func seconds(fromTimestamp timestamp: Substring) -> Int? {
  let components = timestamp.split(separator: ":").compactMap { Int($0) }
  return components.isEmpty ? nil : components.reduce(0) { $0 * 60 + $1 }
}
