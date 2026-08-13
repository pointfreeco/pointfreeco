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
    let rows =
      await withErrorReporting {
        try await database.searchEpisodes(query: query)
      } ?? []

    struct SectionKey: Hashable {
      let episodeSequence: Episode.Sequence
      let sectionTitle: String?
      let timestamp: Int?
    }
    func key(_ row: EpisodeSearchResult) -> SectionKey {
      SectionKey(
        episodeSequence: row.episodeSequence,
        sectionTitle: row.sectionTitle,
        timestamp: row.timestamp
      )
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

    var resultIndexBySequence: [Episode.Sequence: Int] = [:]
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
      let index =
        resultIndexBySequence[row.episodeSequence]
        ?? {
          resultIndexBySequence[row.episodeSequence] = results.count
          results.append(
            SearchPage.Result(
              episode: episode,
              episodeTitleHeadline: episodeTitleHeadlines[row.episodeSequence],
              matches: []
            )
          )
          return results.count - 1
        }()
      if row.kind == .episodeTitle { continue }
      if row.kind == .title, sectionsWithBodyMatches.contains(key(row)) { continue }
      guard results[index].matches.count < 5 else { continue }
      results[index].matches.append(
        SearchPage.Match(
          headline: row.headline,
          headlineIsTruncatedAtEnd: row.headlineIsTruncatedAtEnd,
          headlineIsTruncatedAtStart: row.headlineIsTruncatedAtStart,
          headlineStartsInsideCodeSpan: row.headlineStartsInsideCodeSpan,
          kind: row.kind,
          sectionTitle: row.sectionTitle,
          sectionTitleHeadline: titleHeadlines[key(row)],
          timestamp: row.timestamp
        )
      )
    }

    if sort == .newest {
      results.sort { $0.episode.sequence > $1.episode.sequence }
    }

    if results.isEmpty {
      relatedSearches =
        await withErrorReporting {
          try await database.suggestEpisodeSearchTerms(query: query)
        } ?? []
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
        sort: sort,
        results: results,
        relatedSearches: relatedSearches
      )
    }
}
