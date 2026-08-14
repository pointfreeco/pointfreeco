import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct SearchPage: HTML {
  public struct Result {
    public let episode: Episode
    public let episodeTitleSnippet: String?
    public var matches: [Match]

    public init(episode: Episode, episodeTitleSnippet: String? = nil, matches: [Match]) {
      self.episode = episode
      self.episodeTitleSnippet = episodeTitleSnippet
      self.matches = matches
    }
  }

  public struct Match {
    public let result: EpisodeSearchResult
    public let sectionTitleSnippet: String?

    public init(result: EpisodeSearchResult, sectionTitleSnippet: String? = nil) {
      self.result = result
      self.sectionTitleSnippet = sectionTitleSnippet
    }
  }

  let query: String
  let access: SiteRoute.SearchAccess?
  let scope: SiteRoute.SearchScope?
  let sort: SiteRoute.SearchSort?
  let matchCount: Int
  let results: [Result]
  let relatedSearches: [String]

  public init(
    query: String,
    access: SiteRoute.SearchAccess? = nil,
    scope: SiteRoute.SearchScope? = nil,
    sort: SiteRoute.SearchSort? = nil,
    matchCount: Int? = nil,
    results: [Result],
    relatedSearches: [String] = []
  ) {
    self.query = query
    self.access = access
    self.scope = scope
    self.sort = sort
    self.matchCount = matchCount ?? results.count
    self.results = results
    self.relatedSearches = relatedSearches
  }

  public var body: some HTML {
    div {
      PageModule(theme: .search) {
        VStack(spacing: 2.5) {
          VStack(spacing: 0.5) {
            Header(2) {
              "Search"
            }
            .inlineStyle("background", "linear-gradient(135deg, #4cccff, #974dff)")
            .inlineStyle("-webkit-background-clip", "text")
            .inlineStyle("background-clip", "text")
            .inlineStyle("color", "transparent")
            .inlineStyle("width", "fit-content")

            Paragraph(.big) {
              "Find any topic covered in our catalog of videos."
            }
            .color(.gray300.dark(.gray800))
          }

          LazyVGrid(
            columns: [.mobile: [1], .desktop: [1, 3]],
            alignItems: .start,
            horizontalSpacing: 3,
            verticalSpacing: 2
          ) {
            Sidebar(query: query, access: access, scope: scope, sort: sort)
              .inlineStyle("position", "sticky", media: .desktop)
              .inlineStyle("top", "2rem", media: .desktop)

            div {
              SearchResults(
                query: query,
                matchCount: matchCount,
                results: results,
                relatedSearches: relatedSearches
              )
            }
            .attribute("id", "search-results")
          }
        }
        .inlineStyle("width", "100%")
      }
    }
    .searchHeroBackground()

    tag("template") {
      SearchError()
    }
    .attribute("id", "search-error")

    SearchScript()
  }
}

private struct SearchError: HTML {
  var body: some HTML {
    Paragraph {
      "We couldn’t load results — check your connection and "
      Link(href: "") {
        "try again"
      }
      .attribute("data-retry", "")
      .linkColor(.purple)
      "."
    }
    .color(.gray400.dark(.gray650))
  }
}

extension PageModuleTheme {
  fileprivate static let search = Self(
    backgroundColor: nil,
    color: .black.dark(.offWhite),
    topMargin: 3,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 2
  )
}

extension HTML {
  fileprivate func searchPill(padding: String = "0.35rem 0.75rem") -> some HTML {
    self
      .inlineStyle("background", "color-mix(in oklab, #974dff 10%, transparent)")
      .inlineStyle("background", "color-mix(in oklab, #974dff 15%, transparent)", media: .dark)
      .inlineStyle("border-radius", "999px")
      .inlineStyle("display", "inline-block")
      .inlineStyle("padding", padding)
  }

  fileprivate func searchHeroBackground() -> some HTML {
    inlineStyle(
      "background",
      """
      radial-gradient(600px 220px at 15% 0%, rgba(76, 204, 255, 0.18), transparent 70%), \
      radial-gradient(600px 220px at 85% 0%, rgba(151, 77, 255, 0.16), transparent 70%), \
      #ffffff
      """
    )
    .inlineStyle(
      "background",
      """
      radial-gradient(600px 220px at 15% 0%, rgba(76, 204, 255, 0.10), transparent 70%), \
      radial-gradient(600px 220px at 85% 0%, rgba(151, 77, 255, 0.12), transparent 70%), \
      #121212
      """,
      media: .dark
    )
  }
}

public struct SearchResults: HTML {
  let query: String
  let matchCount: Int
  let results: [SearchPage.Result]
  let relatedSearches: [String]

  public init(
    query: String,
    matchCount: Int? = nil,
    results: [SearchPage.Result],
    relatedSearches: [String] = []
  ) {
    self.query = query
    self.matchCount = matchCount ?? results.count
    self.results = results
    self.relatedSearches = relatedSearches
  }

  var omittedCount: Int {
    matchCount - results.count
  }

  public var body: some HTML {
    VStack(spacing: 2) {
      if query.isEmpty {
        SearchTips()
        LatestAdditions()
        BrowseLinks()
      } else {
        if results.isEmpty {
          Paragraph {
            "We didn’t find anything matching "
            QueryPill(query: query)
            ". Try another search."
          }
          .color(.gray400.dark(.gray650))

          if !relatedSearches.isEmpty {
            VStack(spacing: 1) {
              CapsHeading(title: "Related topics")
              SuggestionPills(suggestions: relatedSearches)
            }
          }

          SearchTips()
          BrowseLinks()
        } else {
          div {
            matchCount == 1
              ? "1 video matches "
              : "\(matchCount) videos match "
            QueryPill(query: query)
          }
          .color(.gray650.dark(.gray400))
          .fontStyle(.body(.small))

          for result in results {
            ResultView(result: result)
          }

          if omittedCount > 0 {
            div {
              omittedCount == 1
                ? "1 less relevant video was omitted. Narrow your search to surface it."
                : "\(omittedCount) less relevant videos were omitted. Narrow your search to surface them."
            }
            .color(.gray650.dark(.gray400))
            .fontStyle(.body(.small))
          }
        }
      }
    }
  }
}

private struct QueryPill: HTML {
  let query: String

  var body: some HTML {
    span {
      HTMLText(query)
    }
    .color(.purple)
    .fontStyle(.body(.small))
    .searchPill(padding: "0.1rem 0.6rem")
  }
}

private struct LatestAdditions: HTML {
  @Dependency(\.episodes) var episodes

  var latest: [Episode] {
    Array(episodes().sorted { $0.sequence > $1.sequence }.prefix(3))
  }

  var body: some HTML {
    VStack(spacing: 1) {
      CapsHeading(title: "Latest additions")
      VStack(spacing: 1) {
        HTMLForEach(latest) { episode in
          VStack(spacing: 0.25) {
            div {
              "Video \(episode.sequence.rawValue) • \(episode.publishedAt.monthDayYear())"
            }
            .color(.gray650.dark(.gray400))
            .fontStyle(.body(.small))

            Link(destination: .episodes(.show(episode))) {
              HTMLText(episode.fullTitle)
            }
            .linkColor(.black.dark(.white))
            .inlineStyle("font-weight", "600")
          }
        }
      }
    }
  }
}

private struct SearchScript: HTML {
  var body: some HTML {
    script {
      #"""
      (() => {
        const form = document.getElementById("search-form");
        const results = document.getElementById("search-results");
        if (!form || !results) return;
        document.documentElement.style.scrollbarGutter = "stable";
        const input = form.querySelector("input[name=q]");
        const icons = {
          sort: \#(glyphMapJS(SiteRoute.SearchSort.self)),
          scope: \#(glyphMapJS(SiteRoute.SearchScope.self)),
          access: \#(glyphMapJS(SiteRoute.SearchAccess.self))
        };
        function updateIcons() {
          for (const select of form.querySelectorAll("select")) {
            const icon = (icons[select.name] || {})[select.value];
            if (icon) {
              select.style.backgroundImage =
                `url("${icon}"), url("\#(chevronGlyphDataURI)")`;
            }
          }
        }
        let controller;
        async function load(push) {
          if (controller) controller.abort();
          controller = new AbortController();
          const url = new URL(form.action, location.origin);
          for (const [name, value] of new FormData(form)) {
            if (value) url.searchParams.set(name, value);
          }
          try {
            const response = await fetch(url, {
              headers: { "X-Fragment": "results" },
              signal: controller.signal
            });
            if (!response.ok) {
              location.href = url;
              return;
            }
            results.innerHTML = await response.text();
            const query = (new FormData(form).get("q") || "").trim();
            document.title = query ? "Search: " + query : "Search";
            if (push) history.pushState(null, "", url);
          } catch (error) {
            if (error.name === "AbortError") return;
            const template = document.getElementById("search-error");
            if (!template) return;
            results.innerHTML = template.innerHTML;
            const retry = results.querySelector("[data-retry]");
            if (retry) retry.setAttribute("href", url.pathname + url.search);
          }
        }
        let debounce;
        input.addEventListener("input", () => {
          clearTimeout(debounce);
          if (input.value.trim() === "") {
            load(true);
          } else {
            debounce = setTimeout(() => load(true), 300);
          }
        });
        form.addEventListener("submit", (event) => {
          event.preventDefault();
          clearTimeout(debounce);
          load(true);
        });
        for (const select of form.querySelectorAll("select")) {
          select.addEventListener("change", updateIcons);
        }
        function syncForm(params) {
          input.value = params.get("q") || "";
          for (const select of form.querySelectorAll("select")) {
            select.value = params.get(select.name) || "";
          }
          updateIcons();
        }
        results.addEventListener("click", (event) => {
          if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
          const link = event.target.closest('a[href^="/search"]');
          if (!link || !results.contains(link)) return;
          event.preventDefault();
          syncForm(new URL(link.href, location.origin).searchParams);
          load(true);
        });
        window.addEventListener("popstate", () => {
          syncForm(new URLSearchParams(location.search));
          load(false);
        });
      })();
      """#
    }
  }
}

private struct Sidebar: HTML {
  let query: String
  let access: SiteRoute.SearchAccess?
  let scope: SiteRoute.SearchScope?
  let sort: SiteRoute.SearchSort?

  var body: some HTML {
    VStack(spacing: 1) {
      div {
        HTMLText("Refine your results")
      }
      .color(.black.dark(.white))
      .inlineStyle("font-weight", "700")

      SearchForm(query: query, access: access, scope: scope, sort: sort)
    }
  }
}

private struct SearchTips: HTML {
  @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

  static let suggestions: [[String]] = [
    ["algebraic data types"],
    ["animations"],
    ["CloudKit"],
    ["Codable"],
    ["Combine"],
    ["Composable Architecture", "TCA"],
    ["concurrency", "isolation", "sendable", "nonsendable types"],
    ["cross platform", "Android", "Windows"],
    ["dependencies"],
    ["domain modeling", "value types", "enums"],
    ["embedded"],
    ["evolution", "Swift Evolution"],
    ["generics"],
    ["key paths", "case paths"],
    ["macros", "macro testing"],
    ["modularization", "packages", "SPM"],
    ["navigation"],
    ["noncopyable", "nonescapable"],
    ["observation"],
    ["parsing", "pretty printing"],
    ["performance", "benchmarking"],
    ["persistence"],
    ["protocol witnesses"],
    ["shared state", "state management"],
    ["side effects"],
    ["SQL", "SQLite"],
    ["SwiftData"],
    ["SwiftUI"],
    ["task locals"],
    ["testing", "snapshot testing"],
    ["UIKit"],
    ["WebAssembly", "Wasm", "SwiftWasm"],
  ]

  var body: some HTML {
    VStack(spacing: 2.5) {
      VStack(spacing: 1) {
        CapsHeading(title: "Try one of these")
        SuggestionPills(
          suggestions: withRandomNumberGenerator { rng in
            Array(
              Self.suggestions
                .compactMap { $0.randomElement(using: &rng) }
                .shuffled(using: &rng)
                .prefix(12)
            )
          }
        )
      }

      SearchTipRows(
        tips: withRandomNumberGenerator { rng in
          Self.tips.map { tip in
            (example: tip.examples.randomElement(using: &rng) ?? "", text: tip.text)
          }
        }
      )
    }
  }

  static let tips: [(examples: [String], text: String)] = [
    (
      examples: [
        #""macro testing""#,
        #""~Copyable""#,
        #""$0 + 1""#,
        #""$0.id == id""#,
        #""@autoclosure""#,
        #""[weak self]""#,
        #""some View""#,
        #""async throws""#,
      ],
      text: "Quote to match a phrase or code exactly."
    ),
    (
      examples: [
        "parsing performance",
        #""[weak self]" closures"#,
        "SQLite CloudKit",
        "generics protocols",
      ],
      text: "Multiple terms find videos covering all of them, even minutes apart."
    ),
    (
      examples: [
        "wasm OR webassembly",
        "swiftui OR uikit",
        "sqlite OR swiftdata",
        "bindable OR binding",
      ],
      text: "OR matches either term."
    ),
    (
      examples: [
        "uikit -swiftui",
        "testing -xctest",
        "persistence -swiftdata",
        "concurrency -combine",
      ],
      text: "Prefix with a minus to leave a term out of results."
    ),
    (
      examples: [
        "Never",
        "Result",
        "Sendable",
        "Task",
        "Error",
      ],
      text: "Uppercase to prioritize case-sensitive matches."
    ),
  ]
}

private struct SearchTipRows: HTML {
  let tips: [(example: String, text: String)]

  var body: some HTML {
    VStack(spacing: 1) {
      CapsHeading(title: "Search tips")
      VStack(spacing: 0.75) {
        for tip in tips {
          TipRow(example: tip.example, text: tip.text)
        }
      }
    }
  }
}

private struct BrowseLinks: HTML {
  var body: some HTML {
    VStack(spacing: 1) {
      CapsHeading(title: "Or browse")
      div {
        Link("All videos →", destination: .episodes(.list(.all)))
        Link("Collections →", destination: .collections())
        Link("Free clips →", destination: .clips(.clips))
      }
      .linkColor(.purple)
      .fontStyle(.body(.small))
      .flexContainer(direction: "row", wrap: "wrap", rowGap: "0.5rem", columnGap: "1.5rem")
    }
  }
}

private struct TipRow: HTML {
  let example: String
  let text: String
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HStack(alignment: .center, spacing: 0.75) {
      Link(href: siteRouter.path(for: .search(query: example))) {
        HTMLText(example)
      }
      .linkColor(.purple)
      .fontStyle(.body(.small))
      .searchPill()
      .inlineStyle("flex-shrink", "0")
      .inlineStyle("white-space", "nowrap")

      span {
        HTMLText(text)
      }
      .color(.gray400.dark(.gray650))
      .fontStyle(.body(.small))
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
        .searchPill()
      }
    }
    .flexContainer(direction: "row", wrap: "wrap", rowGap: "0.5rem", columnGap: "0.5rem")
  }
}

private struct SearchForm: HTML {
  let query: String
  let access: SiteRoute.SearchAccess?
  let scope: SiteRoute.SearchScope?
  let sort: SiteRoute.SearchSort?
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    form {
      input()
        .attribute("type", "search")
        .attribute("name", "q")
        .attribute("value", query.isEmpty ? nil : query)
        .attribute("placeholder", "Search for topics")
        .attribute("autofocus", query.isEmpty ? "" : nil)
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
        .inlineStyle("outline-color", "#974dff")
        .inlineStyle("padding", "0.75rem 1rem 0.75rem 2.5rem")
        .inlineStyle("width", "100%")
      VStack(spacing: 0.5) {
        FilterRow(
          iconDataURI: sort.glyphDataURI,
          label: "Sort by",
          name: "sort",
          options: [
            (value: nil, label: "Relevance"),
            (value: SiteRoute.SearchSort.newest.rawValue, label: "Newest"),
            (value: SiteRoute.SearchSort.oldest.rawValue, label: "Oldest"),
          ],
          selectedValue: sort?.rawValue
        )
        FilterRow(
          iconDataURI: scope.glyphDataURI,
          label: "Match in",
          name: "scope",
          options: [
            (value: nil, label: "All text"),
            (value: SiteRoute.SearchScope.code.rawValue, label: "Code"),
            (value: SiteRoute.SearchScope.dialogue.rawValue, label: "Dialogue"),
            (value: SiteRoute.SearchScope.titles.rawValue, label: "Titles"),
          ],
          selectedValue: scope?.rawValue
        )
        FilterRow(
          iconDataURI: access.glyphDataURI,
          label: "Access",
          name: "access",
          options: [
            (value: nil, label: "All videos"),
            (value: SiteRoute.SearchAccess.free.rawValue, label: "Free"),
            (value: SiteRoute.SearchAccess.subscriberOnly.rawValue, label: "Members only"),
          ],
          selectedValue: access?.rawValue
        )

        input()
          .attribute("type", "submit")
          .attribute("value", "Search")
          .fontStyle(.body(.regular))
          .color(.white)
          .backgroundColor(.purple)
          .inlineStyle("border", "none")
          .inlineStyle("border-radius", "0.5rem")
          .inlineStyle("box-shadow", "inset 0 0 0 20rem rgba(0,0,0,0.1)", pseudo: .hover)
          .inlineStyle("cursor", "pointer")
          .inlineStyle("font-weight", "500")
          .inlineStyle("padding", "0.75rem 1rem")
          .inlineStyle("width", "100%")
      }
      .inlineStyle("margin-top", "0.5rem")
    }
    .attribute("action", siteRouter.path(for: .search()))
    .attribute("id", "search-form")
  }
}

private struct FilterRow: HTML {
  let iconDataURI: String
  let label: String
  let name: String
  let options: [(value: String?, label: String)]
  let selectedValue: String?

  private var optionsList: some HTML {
    HTMLForEach(options) { option in
      tag("option") {
        HTMLText(option.label)
      }
      .attribute("value", option.value ?? "")
      .attribute("selected", option.value == selectedValue ? "" : nil)
    }
  }

  var body: some HTML {
    select {
      optionsList
    }
    .attribute("name", name)
    .attribute("aria-label", label)
    .attribute("onchange", "this.form.requestSubmit()")
    .fontStyle(.body(.regular))
    .color(.black.dark(.white))
    .backgroundColor(.white.dark(.black))
    .inlineStyle("appearance", "none")
    .inlineStyle("-webkit-appearance", "none")
    .inlineStyle("background-image", "url(\"\(iconDataURI)\"), url(\"\(chevronGlyphDataURI)\")")
    .inlineStyle("background-position", "0.75rem center, right 0.75rem center")
    .inlineStyle("background-repeat", "no-repeat")
    .inlineStyle("background-size", "1rem")
    .inlineStyle("border", "1px solid #d8d8d8")
    .inlineStyle("border", "1px solid #454545", media: .dark)
    .inlineStyle("border-radius", "0.5rem")
    .inlineStyle("cursor", "pointer")
    .inlineStyle("padding", "0.75rem 2.5rem")
    .inlineStyle("width", "100%")
  }
}

private let magnifyingGlassDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round'%3E"
  + "%3Ccircle cx='11' cy='11' r='7'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E"

private let relevanceGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Ccircle cx='12' cy='12' r='9'/%3E%3Ccircle cx='12' cy='12' r='4.5'/%3E"
  + "%3Ccircle cx='12' cy='12' r='0.5'/%3E%3C/svg%3E"

private let clockGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Ccircle cx='12' cy='12' r='9'/%3E%3Cpath d='M12 7v5l3 2'/%3E%3C/svg%3E"

private let videoGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='m22 8-6 4 6 4V8Z'/%3E"
  + "%3Crect x='2' y='6' width='14' height='12' rx='2'/%3E%3C/svg%3E"

private let unlockedGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Crect x='3' y='11' width='18' height='11' rx='2'/%3E"
  + "%3Cpath d='M7 11V7a5 5 0 0 1 9.9-1'/%3E%3C/svg%3E"

private let lockGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Crect x='3' y='11' width='18' height='11' rx='2'/%3E"
  + "%3Cpath d='M7 11V7a5 5 0 0 1 10 0v4'/%3E%3C/svg%3E"

private let hourglassGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='M5 22h14'/%3E%3Cpath d='M5 2h14'/%3E"
  + "%3Cpath d='M17 22v-4.172a2 2 0 0 0-.586-1.414L12 12l-4.414 4.414A2 2 0 0 0 7 17.828V22'/%3E"
  + "%3Cpath d='M7 2v4.172a2 2 0 0 0 .586 1.414L12 12l4.414-4.414A2 2 0 0 0 17 6.172V2'/%3E"
  + "%3C/svg%3E"

private let asteriskGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='M12 6v12'/%3E%3Cpath d='M17.196 9 6.804 15'/%3E"
  + "%3Cpath d='M6.804 9l10.392 6'/%3E%3C/svg%3E"

private let speechGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z'/%3E%3C/svg%3E"

private let codeGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='m16 18 6-6-6-6'/%3E%3Cpath d='m8 6-6 6 6 6'/%3E%3C/svg%3E"

private let headingGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='M6 12h12'/%3E%3Cpath d='M6 20V4'/%3E%3Cpath d='M18 20V4'/%3E%3C/svg%3E"

private let chevronGlyphDataURI =
  "data:image/svg+xml,"
  + "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none'"
  + " stroke='%23888888' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E"
  + "%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E"

private protocol SearchFilterOption: CaseIterable, RawRepresentable where RawValue == String {
  var glyphDataURI: String { get }
  static var defaultGlyphDataURI: String { get }
}

extension SiteRoute.SearchSort: SearchFilterOption {
  fileprivate var glyphDataURI: String {
    switch self {
    case .newest: clockGlyphDataURI
    case .oldest: hourglassGlyphDataURI
    }
  }
  fileprivate static var defaultGlyphDataURI: String { relevanceGlyphDataURI }
}

extension SiteRoute.SearchScope: SearchFilterOption {
  fileprivate var glyphDataURI: String {
    switch self {
    case .code: codeGlyphDataURI
    case .dialogue: speechGlyphDataURI
    case .titles: headingGlyphDataURI
    }
  }
  fileprivate static var defaultGlyphDataURI: String { asteriskGlyphDataURI }
}

extension SiteRoute.SearchAccess: SearchFilterOption {
  fileprivate var glyphDataURI: String {
    switch self {
    case .free: unlockedGlyphDataURI
    case .subscriberOnly: lockGlyphDataURI
    }
  }
  fileprivate static var defaultGlyphDataURI: String { videoGlyphDataURI }
}

extension Optional where Wrapped: SearchFilterOption {
  fileprivate var glyphDataURI: String {
    self?.glyphDataURI ?? Wrapped.defaultGlyphDataURI
  }
}

private func glyphMapJS<T: SearchFilterOption>(_: T.Type) -> String {
  let entries =
    [("", T.defaultGlyphDataURI)]
    + T.allCases.map { ($0.rawValue, $0.glyphDataURI) }
  return "{" + entries.map { "\"\($0.0)\": \"\($0.1)\"" }.joined(separator: ", ") + "}"
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
          if let episodeTitleSnippet = result.episodeTitleSnippet {
            SnippetSegments(
              segments: snippetSegments(episodeTitleSnippet, parseCodeSpans: true)
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
      let key = Key(sectionTitle: match.result.sectionTitle, timestamp: match.result.timestamp)
      if let index = indexByKey[key] {
        groups[index].matches.append(match)
      } else {
        indexByKey[key] = groups.count
        groups.append(
          SectionGroup(
            matches: [match],
            sectionTitle: match.result.sectionTitle,
            sectionTitleSnippet: match.sectionTitleSnippet,
            timestamp: match.result.timestamp
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
  let sectionTitleSnippet: String?
  let timestamp: Int?
}

private struct SectionGroupView: HTML {
  let episodePath: String
  let isLocked: Bool
  let group: SectionGroup

  var body: some HTML {
    VStack(spacing: 0.25) {
      if let sectionTitle = group.sectionTitleSnippet ?? group.sectionTitle {
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
      if !isLocked || match.result.kind == .blurb {
        switch match.result.kind {
        case .code:
          tag("code") {
            if match.result.snippetIsTruncatedAtStart {
              TruncationEllipsis(trailing: " ")
            }
            SnippetSegments(segments: snippetSegments(match.result.snippet, parseCodeSpans: false))
            if match.result.snippetIsTruncatedAtEnd {
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
            if match.result.snippetIsTruncatedAtStart {
              TruncationEllipsis(trailing: " ")
            }
            SnippetSegments(
              segments: snippetSegments(
                match.result.snippet,
                parseCodeSpans: true,
                startsInsideCodeSpan: match.result.snippetStartsInsideCodeSpan
              )
            )
            if match.result.snippetIsTruncatedAtEnd {
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
  _ snippet: String,
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
  for character in snippet {
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

  var merged: [SnippetSegment] = []
  var index = 0
  while index < segments.count {
    let segment = segments[index]
    if let previous = merged.last,
      previous.isMatch,
      !segment.isMatch,
      segment.text.allSatisfy(\.isWhitespace),
      index + 1 < segments.count,
      segments[index + 1].isMatch,
      segments[index + 1].isCode == previous.isCode
    {
      merged[merged.count - 1] = SnippetSegment(
        text: previous.text + segment.text + segments[index + 1].text,
        isMatch: true,
        isCode: previous.isCode
      )
      index += 2
    } else {
      merged.append(segment)
      index += 1
    }
  }
  return merged
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
      .inlineStyle("margin", "-1px -2px")
      .inlineStyle("padding", "1px 2px")
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
