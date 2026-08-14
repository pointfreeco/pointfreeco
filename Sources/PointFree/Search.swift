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
  if !query.isEmpty {
    let episodeBySequence = Dictionary(
      episodes().map { ($0.sequence, $0) },
      uniquingKeysWith: { episode, _ in episode }
    )
    let kinds: [EpisodeSearchDocument.Kind]? =
      switch scope {
      case .code: [.code]
      case .dialogue: [.prose, .blurb]
      case .titles: [.title, .episodeTitle]
      case nil: nil
      }
    let sequences: [Episode.Sequence]? =
      switch access {
      case .free:
        episodes()
          .compactMap {
            !$0.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
              ? $0.sequence
              : nil
          }
      case .subscriberOnly:
        episodes()
          .compactMap {
            $0.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
              ? $0.sequence
              : nil
          }
      case nil:
        nil
      }
    let searchResults =
      await withErrorReporting {
        try await database.searchEpisodes(query: query, kinds: kinds, sequences: sequences)
      } ?? EpisodeSearchResults()
    let rows = searchResults.results
    matchCount = searchResults.matchCount

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

    var resultIndexBySequence: [Episode.Sequence: Int] = [:]
    var matchesBySequence: [Episode.Sequence: [SearchPage.Match]] = [:]
    for row in rows {
      guard let episode = episodeBySequence[row.episodeSequence]
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
      matchesBySequence[row.episodeSequence, default: []].append(
        SearchPage.Match(result: row, sectionTitleSnippet: titleSnippets[key(row)])
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
  }

  if conn.request.value(forHTTPHeaderField: "X-Fragment") == "results" {
    return
      conn
      .writeStatus(.ok)
      .respondFragment {
        SearchResults(
          query: query,
          matchCount: matchCount,
          results: results
        )
      }
  }

  return
    conn
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
        results: results
      )
    }
}

private func termCoveringMatches(
  _ matches: [SearchPage.Match],
  limit: Int = 5
) -> [SearchPage.Match] {
  var selectedIndices: Set<Int> = []
  var coveredTerms: Set<String> = []
  for (index, match) in matches.enumerated() {
    guard selectedIndices.count < limit else { break }
    if !match.result.matchedTerms.allSatisfy(coveredTerms.contains) {
      selectedIndices.insert(index)
      coveredTerms.formUnion(match.result.matchedTerms)
    }
  }
  for index in matches.indices {
    guard selectedIndices.count < limit else { break }
    selectedIndices.insert(index)
  }
  return selectedIndices.sorted().map { matches[$0] }
}
