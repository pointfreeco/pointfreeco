public struct EpisodeSearchDocument: Codable, Equatable {
  public var content: String
  public var episodeSequence: Episode.Sequence
  public var kind: Kind
  public var sectionTitle: String?
  public var timestamp: Int?
  public var timestampMarkers: [[Int]]

  public enum Kind: String, Codable, Equatable {
    case blurb
    case code
    case episodeTitle
    case prose
    case title
  }

  public init(
    content: String,
    episodeSequence: Episode.Sequence,
    kind: Kind,
    sectionTitle: String?,
    timestamp: Int?,
    timestampMarkers: [[Int]] = []
  ) {
    self.content = content
    self.episodeSequence = episodeSequence
    self.kind = kind
    self.sectionTitle = sectionTitle
    self.timestamp = timestamp
    self.timestampMarkers = timestampMarkers
  }
}

public struct EpisodeSearchResults: Codable, Equatable {
  public var matchingSequences: [Episode.Sequence]
  public var results: [EpisodeSearchResult]

  public init(
    matchingSequences: [Episode.Sequence] = [],
    results: [EpisodeSearchResult] = []
  ) {
    self.matchingSequences = matchingSequences
    self.results = results
  }
}

public struct EpisodeSearchResult: Codable, Equatable {
  public var episodeSequence: Episode.Sequence
  public var snippet: String
  public var snippetIsTruncatedAtEnd: Bool
  public var snippetIsTruncatedAtStart: Bool
  public var snippetStartsInsideCodeSpan: Bool
  public var kind: EpisodeSearchDocument.Kind
  public var matchedTerms: [String]
  public var sectionTitle: String?
  public var timestamp: Int?

  public init(
    episodeSequence: Episode.Sequence,
    snippet: String,
    snippetIsTruncatedAtEnd: Bool = false,
    snippetIsTruncatedAtStart: Bool = false,
    snippetStartsInsideCodeSpan: Bool = false,
    kind: EpisodeSearchDocument.Kind,
    matchedTerms: [String] = [],
    sectionTitle: String?,
    timestamp: Int?
  ) {
    self.episodeSequence = episodeSequence
    self.snippet = snippet
    self.snippetIsTruncatedAtEnd = snippetIsTruncatedAtEnd
    self.snippetIsTruncatedAtStart = snippetIsTruncatedAtStart
    self.snippetStartsInsideCodeSpan = snippetStartsInsideCodeSpan
    self.kind = kind
    self.matchedTerms = matchedTerms
    self.sectionTitle = sectionTitle
    self.timestamp = timestamp
  }
}
