import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple

// TODO: make an Api module
enum Api {}

extension Api {
  struct EpisodeListItem: Codable {
    var blurb: String
    var id: Episode.Id
    var image: String
    var length: Int
    var publishedAt: Date
    var sequence: Int
    var subscriberOnly: Bool
    var title: String

    init(episode: Episode, currentDate: Date) {
      self.blurb = episode.blurb
      self.id = episode.id
      self.image = episode.image
      self.length = episode.length
      self.publishedAt = episode.publishedAt
      self.sequence = episode.sequence
      self.subscriberOnly = episode.isSubscriberOnly(currentDate: currentDate)
      self.title = episode.title
    }
  }

  struct EpisodeDetail: Codable {
    var blurb: String
    var codeSampleDirectory: String
    var id: Episode.Id
    var image: String
    var length: Int
    var previousEpisodesInCollection: [EpisodeListItem]
    var publishedAt: Date
    var references: [Episode.Reference]
    var sequence: Int
    var subscriberOnly: Bool
    var title: String
    var transcriptBlocks: [Episode.TranscriptBlock]
    var video: Episode.Video

    init(episode: Episode, currentDate: Date) {
      let subscriberOnly = episode.isSubscriberOnly(currentDate: currentDate)

      self.blurb = episode.blurb
      self.codeSampleDirectory = episode.codeSampleDirectory
      self.id = episode.id
      self.image = episode.image
      self.length = episode.length
      self.previousEpisodesInCollection = [] // TODO
      self.publishedAt = episode.publishedAt
      self.references = episode.references
      self.sequence = episode.sequence
      self.subscriberOnly = subscriberOnly
      self.title = episode.title
      self.transcriptBlocks = episode.transcriptBlocks
      self.video = subscriberOnly
        ? episode.trailerVideo!
        : episode.fullVideo // TODO: use subscriber data to determine this
    }
  }
}

func apiMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple2<User?, Route.Api>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (_ /* user */, route) = lower(conn.data)

  switch route {
  case .episodes:
    let episodes = Current.episodes()
      .map { Api.EpisodeListItem(episode: $0, currentDate: Current.date()) }
      .sorted(by: { $0.sequence > $1.sequence })
    return conn.map(const(episodes))
      |> writeStatus(.ok)
      >=> respondJson

  case let .episode(id):
    let episode = Current.episodes()
      .first { $0.id == id }
      .map {
        Api.EpisodeDetail(
          episode: $0,
          currentDate: Current.date()
        )
    }

    return conn.map(const(episode))
      |> (
        filterMap(pure, or: routeNotFoundMiddleware) // TODO: make a JSON 404 payload?
          <| writeStatus(.ok)
          >=> respondJson
    )
  }
}

public func respondJson<A: Encodable>(
  _ conn: Conn<HeadersOpen, A>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let encoder = JSONEncoder()
  if #available(OSX 10.13, *), Current.envVars.appEnv == .testing {
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
  }
  let data = try! encoder.encode(conn.data) // TODO: 400 on badly formed data

  return conn.map(const(data))
    |> writeHeader(.contentType(.json))
    >=> writeHeader(.contentLength(data.count))
    >=> closeHeaders
    >=> end
}
