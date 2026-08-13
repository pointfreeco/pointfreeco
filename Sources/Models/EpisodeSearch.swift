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

public struct EpisodeSearchResult: Codable, Equatable {
  public var episodeSequence: Episode.Sequence
  public var headline: String
  public var headlineIsTruncatedAtEnd: Bool
  public var headlineIsTruncatedAtStart: Bool
  public var headlineStartsInsideCodeSpan: Bool
  public var kind: EpisodeSearchDocument.Kind
  public var matchedTerms: [String]
  public var sectionTitle: String?
  public var timestamp: Int?

  public init(
    episodeSequence: Episode.Sequence,
    headline: String,
    headlineIsTruncatedAtEnd: Bool = false,
    headlineIsTruncatedAtStart: Bool = false,
    headlineStartsInsideCodeSpan: Bool = false,
    kind: EpisodeSearchDocument.Kind,
    matchedTerms: [String] = [],
    sectionTitle: String?,
    timestamp: Int?
  ) {
    self.episodeSequence = episodeSequence
    self.headline = headline
    self.headlineIsTruncatedAtEnd = headlineIsTruncatedAtEnd
    self.headlineIsTruncatedAtStart = headlineIsTruncatedAtStart
    self.headlineStartsInsideCodeSpan = headlineStartsInsideCodeSpan
    self.kind = kind
    self.matchedTerms = matchedTerms
    self.sectionTitle = sectionTitle
    self.timestamp = timestamp
  }
}
