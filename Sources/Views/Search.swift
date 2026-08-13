import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct SearchPage: HTML {
  public struct Result {
    public let episode: Episode
    public let episodeTitleHeadline: String?
    public var matches: [Match]

    public init(episode: Episode, episodeTitleHeadline: String? = nil, matches: [Match]) {
      self.episode = episode
      self.episodeTitleHeadline = episodeTitleHeadline
      self.matches = matches
    }
  }

  public struct Match {
    public let headline: String
    public let headlineIsTruncatedAtEnd: Bool
    public let headlineIsTruncatedAtStart: Bool
    public let headlineStartsInsideCodeSpan: Bool
    public let kind: EpisodeSearchDocument.Kind
    public let sectionTitle: String?
    public let sectionTitleHeadline: String?
    public let timestamp: Int?

    public init(
      headline: String,
      headlineIsTruncatedAtEnd: Bool = false,
      headlineIsTruncatedAtStart: Bool = false,
      headlineStartsInsideCodeSpan: Bool = false,
      kind: EpisodeSearchDocument.Kind,
      sectionTitle: String?,
      sectionTitleHeadline: String? = nil,
      timestamp: Int?
    ) {
      self.headline = headline
      self.headlineIsTruncatedAtEnd = headlineIsTruncatedAtEnd
      self.headlineIsTruncatedAtStart = headlineIsTruncatedAtStart
      self.headlineStartsInsideCodeSpan = headlineStartsInsideCodeSpan
      self.kind = kind
      self.sectionTitle = sectionTitle
      self.sectionTitleHeadline = sectionTitleHeadline
      self.timestamp = timestamp
    }
  }

  let query: String
  let access: SiteRoute.SearchAccess?
  let sort: SiteRoute.SearchSort?
  let results: [Result]
  let relatedSearches: [String]

  public init(
    query: String,
    access: SiteRoute.SearchAccess? = nil,
    sort: SiteRoute.SearchSort? = nil,
    results: [Result],
    relatedSearches: [String] = []
  ) {
    self.query = query
    self.access = access
    self.sort = sort
    self.results = results
    self.relatedSearches = relatedSearches
  }

  public var body: some HTML {
    PageHeader(title: "Search") {
      "Find any topic covered in our catalogue of videos."
    }

    PageModule(theme: .content) {
      LazyVGrid(
        columns: [.mobile: [1], .desktop: [1, 3]],
        alignItems: .start,
        horizontalSpacing: 3,
        verticalSpacing: 2
      ) {
        Sidebar(query: query, access: access, sort: sort)
          .inlineStyle("position", "sticky", media: .desktop)
          .inlineStyle("top", "2rem", media: .desktop)

        VStack(spacing: 2) {
          if query.isEmpty {
            SearchTips()
          } else {
            if results.isEmpty {
              Paragraph {
                "We didn’t find anything matching “\(query)”. Try another search."
              }
              .color(.gray400.dark(.gray650))

              if !relatedSearches.isEmpty {
                VStack(spacing: 1) {
                  CapsHeading(title: "Related topics")
                  SuggestionPills(suggestions: relatedSearches)
                }
              }

              SearchTips()
            } else {
              div {
                results.count == 1
                  ? "1 video matches “\(query)”"
                  : "\(results.count) videos match “\(query)”"
              }
              .color(.gray650.dark(.gray400))
              .fontStyle(.body(.small))

              for result in results {
                ResultView(result: result)
              }
            }
          }
        }
      }
    }
  }
}

private struct Sidebar: HTML {
  let query: String
  let access: SiteRoute.SearchAccess?
  let sort: SiteRoute.SearchSort?
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    VStack(spacing: 1.5) {
      SearchForm(query: query, access: access, sort: sort)

      FilterGroup(
        title: "Sort by",
        options: [SiteRoute.SearchSort?.none, .newest].map { option in
          (
            label: option == nil ? "Relevance" : "Newest",
            href: siteRouter.path(
              for: .search(query: query.isEmpty ? nil : query, access: access, sort: option)
            ),
            isActive: sort == option
          )
        }
      )

      FilterGroup(
        title: "Access",
        options: [SiteRoute.SearchAccess?.none, .free, .subscriberOnly].map { option in
          (
            label: option == nil
              ? "All videos"
              : option == .free ? "Free" : "Members only",
            href: siteRouter.path(
              for: .search(query: query.isEmpty ? nil : query, access: option, sort: sort)
            ),
            isActive: access == option
          )
        }
      )
    }
  }
}

private struct SearchTips: HTML {
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

  static let suggestions = [
    "animations",
    "benchmarking",
    "CloudKit",
    "Codable",
    "Composable Architecture",
    "concurrency",
    "dependencies",
    "domain modeling",
    "enums",
    "generics",
    "macros",
    "modularization",
    "navigation",
    "observation",
    "parsing",
    "performance",
    "persistence",
    "shared state",
    "snapshot testing",
    "SQLite",
    "state management",
    "SwiftData",
    "SwiftUI",
    "testing",
    "UIKit",
    "value types",
    "WebAssembly",
  ]

  var body: some HTML {
    VStack(spacing: 1) {
      CapsHeading(title: "Try one of these")
      SuggestionPills(
        suggestions: withRandomNumberGenerator {
          Array(Self.suggestions.shuffled(using: &$0).prefix(12))
        }
      )
    }
  }
}

private struct CapsHeading: HTML {
  let title: String

  var body: some HTML {
    div {
      HTMLText(title)
    }
    .color(.black.dark(.white))
    .fontStyle(.body(.small))
    .inlineStyle("font-weight", "600")
    .inlineStyle("letter-spacing", "0.05em")
    .inlineStyle("text-transform", "uppercase")
  }
}

private struct SuggestionPills: HTML {
  let suggestions: [String]
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      HTMLForEach(suggestions) { suggestion in
        Link(href: siteRouter.path(for: .search(query: suggestion))) {
          HTMLText(suggestion)
        }
        .linkColor(.purple)
        .fontStyle(.body(.small))
        .inlineStyle("background", "color-mix(in oklab, #974dff 10%, transparent)")
        .inlineStyle("background", "color-mix(in oklab, #974dff 15%, transparent)", media: .dark)
        .inlineStyle("border-radius", "999px")
        .inlineStyle("display", "inline-block")
        .inlineStyle("padding", "0.35rem 0.75rem")
      }
    }
    .flexContainer(direction: "row", wrap: "wrap", rowGap: "0.5rem", columnGap: "0.5rem")
  }
}

private struct SearchForm: HTML {
  let query: String
  let access: SiteRoute.SearchAccess?
  let sort: SiteRoute.SearchSort?
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    form {
      HStack(alignment: .center, spacing: 0.5) {
        input()
          .attribute("type", "search")
          .attribute("name", "q")
          .attribute("value", query.isEmpty ? nil : query)
          .attribute("placeholder", "Search for topics")
          .attribute("autofocus")
          .fontStyle(.body(.regular))
          .color(.black.dark(.white))
          .backgroundColor(.white.dark(.black))
          .inlineStyle("background-image", "url(\"\(magnifyingGlassDataURI)\")")
          .inlineStyle("background-position", "0.75rem center")
          .inlineStyle("background-repeat", "no-repeat")
          .inlineStyle("background-size", "1rem")
          .inlineStyle("border", "1px solid #d8d8d8")
          .inlineStyle("border", "1px solid #454545", media: .dark)
          .inlineStyle("border-radius", "0.5rem")
          .inlineStyle("min-width", "0")
          .inlineStyle("outline-color", "#974dff")
          .inlineStyle("padding", "0.75rem 1rem 0.75rem 2.5rem")
          .flexItem(grow: "1", shrink: "1", basis: "auto")
        button {
          "→"
        }
        .attribute("type", "submit")
        .attribute("aria-label", "Search")
        .color(.purple)
        .inlineStyle("background", "transparent")
        .inlineStyle("border", "none")
        .inlineStyle("cursor", "pointer")
        .inlineStyle("font-size", "1.5rem")
        .inlineStyle("line-height", "1")
        .inlineStyle("padding", "0.25rem")
        .inlineStyle("transform", "translateX(0.25rem)", pseudo: .hover)
        .inlineStyle("transition", "transform 0.15s")
      }
      if let access {
        input()
          .attribute("type", "hidden")
          .attribute("name", "access")
          .attribute("value", access.rawValue)
      }
      if let sort {
        input()
          .attribute("type", "hidden")
          .attribute("name", "sort")
          .attribute("value", sort.rawValue)
      }
    }
    .attribute("action", siteRouter.path(for: .search()))
  }
}

private let magnifyingGlassDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round'%3E"
  + "%3Ccircle cx='11' cy='11' r='7'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E"

private struct FilterGroup: HTML {
  let title: String
  let options: [(label: String, href: String, isActive: Bool)]

  var body: some HTML {
    VStack(spacing: 0.5) {
      div {
        HTMLText(title)
      }
      .color(.black.dark(.white))
      .fontStyle(.body(.small))
      .inlineStyle("font-weight", "600")
      .inlineStyle("letter-spacing", "0.05em")
      .inlineStyle("text-transform", "uppercase")

      VStack(spacing: 0.25) {
        HTMLForEach(options) { option in
          Link(href: option.href) {
            HTMLText(option.label)
          }
          .linkColor(option.isActive ? .purple : .black.dark(.white))
          .fontStyle(.body(.small))
          .inlineStyle("font-weight", option.isActive ? "600" : nil)
        }
      }
    }
  }
}

private struct ResultView: HTML {
  let result: SearchPage.Result

  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var isLocked: Bool {
    result.episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
      && !subscriberState.isActive
  }

  var body: some HTML {
    VStack(spacing: 0.5) {
      div {
        "Video \(result.episode.sequence.rawValue) • \(result.episode.publishedAt.monthDayYear())"
        if isLocked {
          span {
            Link(destination: .pricingLanding) {
              span { SVG.locked }
                .inlineStyle("display", "inline-block")
                .inlineStyle("margin-right", "0.25rem")
                .inlineStyle("vertical-align", "-0.15em")
              "Members only"
            }
            .linkColor(.currentColor)
          }
          .inlineStyle("margin-left", "0.5rem")
          .inlineStyle("white-space", "nowrap")
        }
      }
      .color(.gray650.dark(.gray400))
      .fontStyle(.body(.small))

      tag("h4") {
        Link(destination: .episodes(.show(result.episode))) {
          if let episodeTitleHeadline = result.episodeTitleHeadline {
            SnippetSegments(
              segments: snippetSegments(episodeTitleHeadline, parseCodeSpans: true)
            )
          } else {
            HTMLText(result.episode.fullTitle)
          }
        }
        .linkColor(.black.dark(.white))
      }
      .inlineStyle("font-size", "1.5rem")
      .inlineStyle("font-weight", "700")
      .inlineStyle("line-height", "1.2")
      .inlineStyle("margin", "0")

      HTMLForEach(sectionGroups) { group in
        SectionGroupView(
          episodePath: siteRouter.path(for: .episodes(.show(result.episode))),
          isLocked: isLocked,
          group: group
        )
      }
    }
  }

  private var sectionGroups: [SectionGroup] {
    struct Key: Hashable {
      let sectionTitle: String?
      let timestamp: Int?
    }
    var groups: [SectionGroup] = []
    var indexByKey: [Key: Int] = [:]
    for match in result.matches {
      let key = Key(sectionTitle: match.sectionTitle, timestamp: match.timestamp)
      if let index = indexByKey[key] {
        groups[index].matches.append(match)
      } else {
        indexByKey[key] = groups.count
        groups.append(
          SectionGroup(
            matches: [match],
            sectionTitle: match.sectionTitle,
            sectionTitleHeadline: match.sectionTitleHeadline,
            timestamp: match.timestamp
          )
        )
      }
    }
    return groups
  }
}

private struct SectionGroup {
  var matches: [SearchPage.Match]
  let sectionTitle: String?
  let sectionTitleHeadline: String?
  let timestamp: Int?
}

private struct SectionGroupView: HTML {
  let episodePath: String
  let isLocked: Bool
  let group: SectionGroup

  var body: some HTML {
    VStack(spacing: 0.25) {
      if let sectionTitle = group.sectionTitleHeadline ?? group.sectionTitle {
        Link(href: group.timestamp.map { "\(episodePath)#t\($0)" } ?? episodePath) {
          SnippetSegments(segments: snippetSegments(sectionTitle, parseCodeSpans: true))
          if let timestamp = group.timestamp {
            " (\(formatted(timestamp: timestamp)))"
          }
        }
        .linkColor(.purple)
        .fontStyle(.body(.small))
      }

      HTMLForEach(group.matches) { match in
        MatchSnippet(isLocked: isLocked, match: match)
      }
    }
    .inlineStyle("margin-left", "0.5rem")
  }
}

private struct MatchSnippet: HTML {
  let isLocked: Bool
  let match: SearchPage.Match

  var body: some HTML {
    HTMLGroup {
      if !isLocked || match.kind == .blurb {
        switch match.kind {
        case .code:
          tag("code") {
            if match.headlineIsTruncatedAtStart {
              TruncationEllipsis(trailing: " ")
            }
            SnippetSegments(segments: snippetSegments(match.headline, parseCodeSpans: false))
            if match.headlineIsTruncatedAtEnd {
              TruncationEllipsis(leading: " ")
            }
          }
          .color(.gray400.dark(.gray650))
          .fontStyle(.body(.small))
          .inlineStyle("background", "color-mix(in oklab, currentColor 6%, transparent)")
          .inlineStyle("border-radius", "0.5rem")
          .inlineStyle("display", "block")
          .inlineStyle("overflow-x", "auto")
          .inlineStyle("padding", "0.5rem 0.75rem")
          .inlineStyle("white-space", "pre-wrap")

        case .blurb, .prose:
          Paragraph {
            if match.headlineIsTruncatedAtStart {
              TruncationEllipsis(trailing: " ")
            }
            SnippetSegments(
              segments: snippetSegments(
                match.headline,
                parseCodeSpans: true,
                startsInsideCodeSpan: match.headlineStartsInsideCodeSpan
              )
            )
            if match.headlineIsTruncatedAtEnd {
              TruncationEllipsis(leading: " ")
            }
          }
          .color(.gray400.dark(.gray650))
          .fontStyle(.body(.small))

        case .episodeTitle, .title:
          HTMLEmpty()
        }
      }
    }
  }
}

private func snippetSegments(
  _ headline: String,
  parseCodeSpans: Bool,
  startsInsideCodeSpan: Bool = false
) -> [SnippetSegment] {
  var segments: [SnippetSegment] = []
  var current = ""
  var isMatch = false
  var isCode = parseCodeSpans && startsInsideCodeSpan
  func flush() {
    guard !current.isEmpty else { return }
    segments.append(SnippetSegment(text: current, isMatch: isMatch, isCode: isCode))
    current = ""
  }
  for character in headline {
    switch character {
    case "⟪", "⟫":
      flush()
      isMatch = character == "⟪"
    case "`" where parseCodeSpans:
      flush()
      isCode.toggle()
    default:
      current.append(character)
    }
  }
  flush()
  return segments
}

private struct TruncationEllipsis: HTML {
  var leading = ""
  var trailing = ""

  var body: some HTML {
    span {
      "\(leading)…\(trailing)"
    }
    .color(.gray650.dark(.gray400))
    .inlineStyle("user-select", "none")
  }
}

private struct SnippetSegment {
  let text: String
  let isMatch: Bool
  let isCode: Bool
}

private struct SnippetSegments: HTML {
  let segments: [SnippetSegment]

  var body: some HTML {
    for segment in segments {
      if segment.isCode {
        tag("code") {
          SnippetText(text: segment.text, isMatch: segment.isMatch)
        }
      } else {
        SnippetText(text: segment.text, isMatch: segment.isMatch)
      }
    }
  }
}

private struct SnippetText: HTML {
  let text: String
  let isMatch: Bool

  var body: some HTML {
    if isMatch {
      tag("mark") {
        HTMLText(text)
      }
      .inlineStyle("background", "color-mix(in oklab, #974dff 20%, transparent)")
      .inlineStyle("border-radius", "0.25rem")
      .inlineStyle("color", "inherit")
    } else {
      HTMLText(text)
    }
  }
}

private func formatted(timestamp: Int) -> String {
  let hour = timestamp / 3600
  let minute = (timestamp % 3600) / 60
  let second = timestamp % 60
  var formatted = hour > 0 ? "\(hour):" : ""
  formatted.append("\(hour > 0 && minute < 10 ? "0" : "")\(minute):")
  formatted.append("\(second < 10 ? "0" : "")\(second)")
  return formatted
}
