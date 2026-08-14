import Database
import Dependencies
import Foundation
import HttpPipeline
import IssueReporting
import Models
import PointFreeRouter
import Views

func searchMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  query: String?,
  access: SiteRoute.SearchAccess?,
  scope: SiteRoute.SearchScope?,
  sort: SiteRoute.SearchSort?
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes

  let query = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
  var results: [SearchPage.Result] = []
  var matchCount = 0
  var relatedSearches: [String] = []
  if !query.isEmpty {
    let episodeBySequence = Dictionary(
      episodes().map { ($0.sequence, $0) },
      uniquingKeysWith: { episode, _ in episode }
    )
    func isIncluded(_ episode: Episode) -> Bool {
      switch access {
      case .free:
        !episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
      case .subscriberOnly:
        episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
      case nil:
        true
      }
    }
    let kinds: [EpisodeSearchDocument.Kind]? =
      switch scope {
      case .code: [.code]
      case .dialogue: [.prose, .blurb]
      case .titles: [.title, .episodeTitle]
      case nil: nil
      }
    let searchResults =
      await withErrorReporting {
        try await database.searchEpisodes(query: query, kinds: kinds)
      } ?? EpisodeSearchResults()
    let rows = searchResults.results
    matchCount = searchResults.matchingSequences
      .compactMap { episodeBySequence[$0] }
      .count(where: isIncluded)

    struct SectionKey: Hashable {
      let episodeSequence: Episode.Sequence
      let sectionTitle: String?
    }
    func key(_ row: EpisodeSearchResult) -> SectionKey {
      SectionKey(episodeSequence: row.episodeSequence, sectionTitle: row.sectionTitle)
    }
    var titleSnippets: [SectionKey: String] = [:]
    var sectionsWithBodyMatches: Set<SectionKey> = []
    var episodeTitleSnippets: [Episode.Sequence: String] = [:]
    for row in rows {
      switch row.kind {
      case .episodeTitle:
        episodeTitleSnippets[row.episodeSequence] = row.snippet
      case .title:
        titleSnippets[key(row)] = row.snippet
      case .blurb, .code, .prose:
        if row.sectionTitle != nil {
          sectionsWithBodyMatches.insert(key(row))
        }
      }
    }

    struct WindowKey: Hashable {
      let episodeSequence: Episode.Sequence
      let sectionTitle: String?
      let timestamp: Int?
      let plainSnippet: String
    }
    var resultIndexBySequence: [Episode.Sequence: Int] = [:]
    var matchesBySequence: [Episode.Sequence: [(match: SearchPage.Match, terms: [String])]] = [:]
    var matchIndexByWindow: [WindowKey: Int] = [:]
    for row in rows {
      guard let episode = episodeBySequence[row.episodeSequence], isIncluded(episode)
      else { continue }
      if resultIndexBySequence[row.episodeSequence] == nil {
        resultIndexBySequence[row.episodeSequence] = results.count
        results.append(
          SearchPage.Result(
            episode: episode,
            episodeTitleSnippet: episodeTitleSnippets[row.episodeSequence],
            matches: []
          )
        )
      }
      if row.kind == .episodeTitle { continue }
      if row.kind == .title, sectionsWithBodyMatches.contains(key(row)) { continue }
      let windowKey = WindowKey(
        episodeSequence: row.episodeSequence,
        sectionTitle: row.sectionTitle,
        timestamp: row.timestamp,
        plainSnippet: row.snippet
          .replacingOccurrences(of: "⟪", with: "")
          .replacingOccurrences(of: "⟫", with: "")
      )
      if let matchIndex = matchIndexByWindow[windowKey] {
        matchesBySequence[row.episodeSequence]?[matchIndex].terms
          .append(contentsOf: row.matchedTerms)
        continue
      }
      matchIndexByWindow[windowKey] = matchesBySequence[row.episodeSequence, default: []].count
      matchesBySequence[row.episodeSequence, default: []].append(
        (
          match: SearchPage.Match(
            snippet: row.snippet,
            snippetIsTruncatedAtEnd: row.snippetIsTruncatedAtEnd,
            snippetIsTruncatedAtStart: row.snippetIsTruncatedAtStart,
            snippetStartsInsideCodeSpan: row.snippetStartsInsideCodeSpan,
            kind: row.kind,
            sectionTitle: row.sectionTitle,
            sectionTitleSnippet: titleSnippets[key(row)],
            timestamp: row.timestamp
          ),
          terms: row.matchedTerms
        )
      )
    }
    for (sequence, index) in resultIndexBySequence {
      results[index].matches = termCoveringMatches(matchesBySequence[sequence] ?? [])
    }

    switch sort {
    case .newest:
      results.sort { $0.episode.sequence > $1.episode.sequence }
    case .oldest:
      results.sort { $0.episode.sequence < $1.episode.sequence }
    case nil:
      break
    }

    if results.isEmpty {
      relatedSearches =
        await withErrorReporting {
          try await database.suggestEpisodeSearchTerms(query: query)
        } ?? []
    }
  }

  if conn.request.value(forHTTPHeaderField: "X-Fragment") == "results" {
    return conn
      .writeStatus(.ok)
      .respondFragment {
        SearchResults(
          query: query,
          matchCount: matchCount,
          results: results,
          relatedSearches: relatedSearches
        )
      }
  }

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(title: query.isEmpty ? "Search" : "Search: \(query)")
    ) {
      SearchPage(
        query: query,
        access: access,
        scope: scope,
        sort: sort,
        matchCount: matchCount,
        results: results,
        relatedSearches: relatedSearches
      )
    }
}

private func termCoveringMatches(
  _ rows: [(match: SearchPage.Match, terms: [String])],
  limit: Int = 5
) -> [SearchPage.Match] {
  var selectedIndices: [Int] = []
  var coveredTerms: Set<String> = []
  for (index, row) in rows.enumerated() {
    guard selectedIndices.count < limit else { break }
    if !row.terms.allSatisfy(coveredTerms.contains) {
      selectedIndices.append(index)
      coveredTerms.formUnion(row.terms)
    }
  }
  for index in rows.indices {
    guard selectedIndices.count < limit else { break }
    if !selectedIndices.contains(index) {
      selectedIndices.append(index)
    }
  }
  return selectedIndices.sorted().map { rows[$0].match }
}
