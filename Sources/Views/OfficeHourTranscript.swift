import Models
import StyleguideV2
import TaggedTime

struct OfficeHourTranscriptSection {
  enum Kind {
    case introduction
    case manual(title: String)
    case question(Models.OfficeHourQuestion)
  }

  let kind: Kind
  let seconds: Int?
  var body: String = ""
}

func officeHourTranscriptSections(
  transcript: String,
  questions: [Models.OfficeHourQuestion]
) -> [OfficeHourTranscriptSection] {
  var pendingQuestions = questions
    .filter { $0.answeredAtSeconds != nil }
    .sorted { ($0.answeredAtSeconds ?? 0) < ($1.answeredAtSeconds ?? 0) }

  var sections: [OfficeHourTranscriptSection] = [
    OfficeHourTranscriptSection(kind: .introduction, seconds: nil)
  ]
  var currentSeconds: Int?

  for line in transcript.split(separator: "\n", omittingEmptySubsequences: false) {
    let trimmed = line.trimmingCharacters(in: .whitespaces)

    if let seconds = timestampDirectiveSeconds(trimmed) {
      currentSeconds = seconds
      while let question = pendingQuestions.first,
        let questionSeconds = question.answeredAtSeconds?.rawValue,
        questionSeconds <= seconds
      {
        pendingQuestions.removeFirst()
        sections.append(
          OfficeHourTranscriptSection(kind: .question(question), seconds: questionSeconds)
        )
      }
      sections[sections.count - 1].body += line + "\n"
    } else if let title = headingTitle(trimmed) {
      sections.append(
        OfficeHourTranscriptSection(kind: .manual(title: title), seconds: currentSeconds)
      )
    } else {
      sections[sections.count - 1].body += line + "\n"
    }
  }

  for question in pendingQuestions {
    sections.append(
      OfficeHourTranscriptSection(
        kind: .question(question),
        seconds: question.answeredAtSeconds?.rawValue
      )
    )
  }

  return sections
    .map {
      var section = $0
      section.body = section.body.trimmingCharacters(in: .whitespacesAndNewlines)
      return section
    }
    .filter {
      if case .introduction = $0.kind { return !$0.body.isEmpty }
      return true
    }
}

private func timestampDirectiveSeconds(_ line: String) -> Int? {
  guard
    line.hasPrefix("@T("),
    let close = line.firstIndex(of: ")")
  else { return nil }
  let arguments = line[line.index(line.startIndex, offsetBy: 3)..<close]
  guard
    let time = arguments.split(separator: ",").first?.trimmingCharacters(in: .whitespaces)
  else { return nil }
  let components = time.split(separator: ":").map { Int($0) }
  guard
    !components.isEmpty,
    components.allSatisfy({ $0 != nil })
  else { return nil }
  return components.reduce(0) { $0 * 60 + $1! }
}

private func headingTitle(_ line: String) -> String? {
  var count = 0
  var index = line.startIndex
  while index < line.endIndex, line[index] == "#" {
    count += 1
    index = line.index(after: index)
  }
  guard
    (1...6).contains(count),
    index < line.endIndex,
    line[index] == " "
  else { return nil }
  let title = line[index...].trimmingCharacters(in: .whitespaces)
  return title.isEmpty ? nil : title
}

struct OfficeHourTranscriptModule: HTML {
  let transcript: String
  let questions: [Models.OfficeHourQuestion]
  let isViewable: Bool

  var sections: [OfficeHourTranscriptSection] {
    officeHourTranscriptSections(transcript: transcript, questions: questions)
  }

  var previewText: String {
    sections
      .map(\.body)
      .joined(separator: "\n\n")
      .split(separator: "\n", omittingEmptySubsequences: false)
      .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("@T(") }
      .joined(separator: "\n")
      .split(separator: "\n\n", omittingEmptySubsequences: true)
      .prefix(3)
      .joined(separator: "\n\n")
  }

  var body: some HTML {
    PageModule(title: "Transcript", theme: .content) {
      VStack(spacing: 1.5) {
        if isViewable {
          for section in sections {
            TranscriptSectionView(section: section)
          }
        } else {
          HTMLMarkdown(untrusted: previewText)
            .color(.gray150.dark(.gray850))
            .inlineStyle(
              "mask-image",
              "linear-gradient(to bottom, black 30%, transparent 100%)"
            )
        }
      }
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "768px")
      .inlineStyle("width", "100%")
    }
  }
}

private struct TranscriptSectionView: HTML {
  let section: OfficeHourTranscriptSection

  var body: some HTML {
    VStack(spacing: 0.75) {
      switch section.kind {
      case .introduction:
        HTMLEmpty()

      case .manual(let title):
        HStack(alignment: .firstTextBaseline, spacing: 0.75) {
          Header(4) {
            HTMLText(title)
          }
          .color(.black.dark(.white))

          if let seconds = section.seconds {
            TranscriptTimestampLink(seconds: seconds)
          }
        }

      case .question(let question):
        div {
          HStack(alignment: .firstTextBaseline, spacing: 0.75) {
            QABadge()
            if let seconds = section.seconds {
              TranscriptTimestampLink(seconds: seconds)
            }
          }

          HTMLMarkdown(untrusted: question.question)
            .color(.black.dark(.white))
            .inlineStyle("margin-top", "0.5rem")
        }
        .inlineStyle("background-color", "color-mix(in oklab, #974dff 6%, transparent)")
        .inlineStyle("border-left", "3px solid #974dff")
        .inlineStyle("border-radius", "0 0.5rem 0.5rem 0")
        .inlineStyle("padding", "0.75rem 1rem")
      }

      if !section.body.isEmpty {
        HTMLMarkdown(untrusted: section.body)
          .color(.gray150.dark(.gray850))
      }
    }
  }
}

private struct QABadge: HTML {
  var body: some HTML {
    span {
      "Q&A"
    }
    .inlineStyle("font-size", "0.65rem")
    .inlineStyle("font-weight", "700")
    .inlineStyle("letter-spacing", "0.08em")
    .inlineStyle("padding", "2px 6px")
    .inlineStyle("border-radius", "999px")
    .inlineStyle("border", "1px solid rgba(151, 77, 255, 0.7)")
    .inlineStyle("background", "rgba(151, 77, 255, 0.4)")
    .inlineStyle("color", "rgba(255, 255, 255, 0.9)")
  }
}

private struct TranscriptTimestampLink: HTML {
  let seconds: Int

  var body: some HTML {
    a {
      HTMLText(timestampLabel(seconds: Seconds(rawValue: seconds)))
    }
    .attribute("href", "#t\(seconds)")
    .attribute("data-timestamp", "\(seconds)")
    .inlineStyle("color", "#974dff")
    .inlineStyle("font-variant-numeric", "tabular-nums")
    .inlineStyle("text-decoration", "none")
    .inlineStyle("text-decoration", "underline", pseudo: .hover)
  }
}
