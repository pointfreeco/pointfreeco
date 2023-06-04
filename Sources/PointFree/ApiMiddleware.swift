import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import TaggedTime
import Tuple

// TODO: make an Api module
enum Api {}

extension Api {
  struct EpisodeListItem: Codable {
    var blurb: String
    var id: Episode.ID
    var image: String
    var length: Seconds<Int>
    var publishedAt: Date
    var sequence: Episode.Sequence
    var subscriberOnly: Bool
    var title: String

    init(episode: Episode, currentDate: Date) {
      @Dependency(\.envVars.emergencyMode) var emergencyMode

      self.blurb = episode.blurb
      self.id = episode.id
      self.image = episode.image
      self.length = episode.length
      self.publishedAt = episode.publishedAt
      self.sequence = episode.sequence
      self.subscriberOnly = episode.isSubscriberOnly(
        currentDate: currentDate, emergencyMode: emergencyMode)
      self.title = episode.fullTitle
    }
  }

  struct EpisodeDetail: Codable {
    var blurb: String
    var codeSampleDirectory: String?
    var id: Episode.ID
    var image: String
    var length: Seconds<Int>
    var previousEpisodesInCollection: [EpisodeListItem]
    var publishedAt: Date
    var references: [Episode.Reference]
    var sequence: Episode.Sequence
    var subscriberOnly: Bool
    var title: String
    var transcriptBlocks: [Episode.TranscriptBlock]
    var video: Episode.Video

    init(episode: Episode, currentDate: Date) {
      @Dependency(\.envVars.emergencyMode) var emergencyMode

      let subscriberOnly = episode.isSubscriberOnly(
        currentDate: currentDate,
        emergencyMode: emergencyMode
      )

      self.blurb = episode.blurb
      self.codeSampleDirectory = episode.codeSampleDirectory
      self.id = episode.id
      self.image = episode.image
      self.length = episode.length
      self.previousEpisodesInCollection = []  // TODO
      self.publishedAt = episode.publishedAt
      self.references = episode.references
      self.sequence = episode.sequence
      self.subscriberOnly = subscriberOnly
      self.title = episode.fullTitle
      self.transcriptBlocks = episode.transcriptBlocks
      self.video =
        subscriberOnly
        ? episode.trailerVideo
        : episode.fullVideo  // TODO: use subscriber data to determine this
    }
  }
}

func apiMiddleware(_ conn: Conn<StatusLineOpen, SiteRoute.Api>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now

  let apiRoute = conn.data

  switch apiRoute {
  case .episodes:
    let episodes = episodes()
      .map { Api.EpisodeListItem(episode: $0, currentDate: now) }
      .sorted(by: { $0.sequence > $1.sequence })
    return conn.map { _ in episodes }
      .respondJSON()

  case let .episode(id):
    let episode = episodes()
      .first { $0.id == id }
      .map {
        Api.EpisodeDetail(
          episode: $0,
          currentDate: now
        )
      }

    guard let episode = episode else {
      return try! conn
        .writeStatus(.notFound)
        .respond(json: ["status": 404])
    }

    return conn.map { _ in episode }
      .respondJSON()
  }
}

extension Conn where Step == StatusLineOpen, A: Encodable {
  public func respondJSON() -> Conn<ResponseEnded, Data> {
    @Dependency(\.envVars.appEnv) var appEnv

    let encoder = JSONEncoder()
    if appEnv == .testing {
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    do {
      let data = try encoder.encode(self.data)

      return self.map { _ in data }
        .writeStatus(.ok)
        .writeHeader(.contentLength(data.count))
        .writeHeader(.contentType(.json))
        .closeHeaders()
        .end()
    } catch {
      return self.head(.badRequest)
    }
  }
}
