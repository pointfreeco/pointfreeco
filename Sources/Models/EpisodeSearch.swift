import Foundation

public struct EpisodeSearchDocument: Codable, Equatable {
  public var content: String
  public var episodeSequence: Episode.Sequence
  public var kind: Kind
  public var publishedAt: Date
  public var sectionTitle: String?
  public var timestamp: Int?
  public var timestampMarkers: [TimestampMarker]

  public enum Kind: String, Codable, Equatable {
    case blurb
    case code
    case episodeTitle
    case prose
    case title
  }

  public struct TimestampMarker: Codable, Equatable {
    public var offset: Int
    public var seconds: Int

    public init(offset: Int, seconds: Int) {
      self.offset = offset
      self.seconds = seconds
    }

    public init(from decoder: any Decoder) throws {
      var container = try decoder.unkeyedContainer()
      self.offset = try container.decode(Int.self)
      self.seconds = try container.decode(Int.self)
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.unkeyedContainer()
      try container.encode(self.offset)
      try container.encode(self.seconds)
    }
  }

  public init(
    content: String,
    episodeSequence: Episode.Sequence,
    kind: Kind,
    publishedAt: Date,
    sectionTitle: String?,
    timestamp: Int?,
    timestampMarkers: [TimestampMarker] = []
  ) {
    self.content = content
    self.episodeSequence = episodeSequence
    self.kind = kind
    self.publishedAt = publishedAt
    self.sectionTitle = sectionTitle
    self.timestamp = timestamp
    self.timestampMarkers = timestampMarkers
  }
}

public struct EpisodeSearchResults: Codable, Equatable {
  public var matchCount: Int
  public var results: [EpisodeSearchResult]

  public init(
    matchCount: Int = 0,
    results: [EpisodeSearchResult] = []
  ) {
    self.matchCount = matchCount
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
