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
  var relatedSearches: [String] = []
  if !query.isEmpty {
    let episodeBySequence = Dictionary(
      episodes().map { ($0.sequence, $0) },
      uniquingKeysWith: { episode, _ in episode }
    )
    let kinds: [EpisodeSearchDocument.Kind]? =
      switch scope {
      case .code: [.code]
      case .prose: [.prose, .blurb]
      case .titles: [.title, .episodeTitle]
      case nil: nil
      }
    let rows =
      await withErrorReporting {
        try await database.searchEpisodes(query: query, kinds: kinds)
      } ?? []

    struct SectionKey: Hashable {
      let episodeSequence: Episode.Sequence
      let sectionTitle: String?
    }
    func key(_ row: EpisodeSearchResult) -> SectionKey {
      SectionKey(episodeSequence: row.episodeSequence, sectionTitle: row.sectionTitle)
    }
    var titleHeadlines: [SectionKey: String] = [:]
    var sectionsWithBodyMatches: Set<SectionKey> = []
    var episodeTitleHeadlines: [Episode.Sequence: String] = [:]
    for row in rows {
      switch row.kind {
      case .episodeTitle:
        episodeTitleHeadlines[row.episodeSequence] = row.headline
      case .title:
        titleHeadlines[key(row)] = row.headline
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
      let plainHeadline: String
    }
    var resultIndexBySequence: [Episode.Sequence: Int] = [:]
    var matchesBySequence: [Episode.Sequence: [(match: SearchPage.Match, terms: [String])]] = [:]
    var matchIndexByWindow: [WindowKey: Int] = [:]
    for row in rows {
      guard let episode = episodeBySequence[row.episodeSequence] else { continue }
      switch access {
      case .free:
        guard !episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
        else { continue }
      case .subscriberOnly:
        guard episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
        else { continue }
      case nil:
        break
      }
      if resultIndexBySequence[row.episodeSequence] == nil {
        resultIndexBySequence[row.episodeSequence] = results.count
        results.append(
          SearchPage.Result(
            episode: episode,
            episodeTitleHeadline: episodeTitleHeadlines[row.episodeSequence],
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
        plainHeadline: row.headline
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
            headline: row.headline,
            headlineIsTruncatedAtEnd: row.headlineIsTruncatedAtEnd,
            headlineIsTruncatedAtStart: row.headlineIsTruncatedAtStart,
            headlineStartsInsideCodeSpan: row.headlineStartsInsideCodeSpan,
            kind: row.kind,
            sectionTitle: row.sectionTitle,
            sectionTitleHeadline: titleHeadlines[key(row)],
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
        SearchResults(query: query, results: results, relatedSearches: relatedSearches)
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
