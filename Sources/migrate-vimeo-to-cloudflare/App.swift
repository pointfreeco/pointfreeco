import Cloudflare
import Dependencies
import Foundation
import Models
import PointFree
import Vimeo

@main
struct VimeoCloudflareMigration {
  static func main() async throws {
    prepareDependencies {
      $0.envVars.baseUrl = URL(string: "https://www.pointfree.co")!
      $0[CloudflareClient.self] = .live(
        accountID: $0.envVars.cloudflare.accountID,
        apiToken: $0.envVars.cloudflare.streamAPIKey
      )
      $0.vimeoClient = .live(
        bearer: $0.envVars.vimeo.bearer,
        userId: $0.envVars.vimeo.userId
      )
    }

    @Dependency(\.episodes) var episodes
    @Dependency(CloudflareClient.self) var cloudflare
    @Dependency(\.vimeoClient) var vimeo
    Episode.bootstrapPrivateEpisodes()

    let cloudflareVideos = try await cloudflare.videos()
    let cloudflareVideoByID = Dictionary(grouping: cloudflareVideos.result, by: \.uid)
      .compactMapValues(\.first)
    let vimeoVideos = try await vimeo.videos(page: 1, perPage: 5)
    let vimeoVideosByID = Dictionary(grouping: vimeoVideos.data, by: \.id)
      .compactMapValues(\.first)
    let episodesBySequence = Dictionary(grouping: episodes(), by: \.sequence)
      .compactMapValues(\.first)
    let episodesByVimeoID = Dictionary(grouping: episodes(), by: \.fullVideo.vimeoId)
      .compactMapValues(\.first)
    let episodesByTrailerVimeoID = Dictionary(grouping: episodes(), by: \.trailerVideo.vimeoId)
      .compactMapValues(\.first)
    func episode(for vimeoID: Int) -> (isTrailer: Bool, episode: Episode)? {
      episodesByVimeoID[vimeoID].map { (false, $0) }
        ?? episodesByTrailerVimeoID[vimeoID].map { (true, $0) }
    }

    for vimeoVideo in vimeoVideos.data {
      guard let (isTrailer, episode) = episode(for: vimeoVideo.id)
      else {
        print(
          """
          ⚠️ Vimeo video "\(vimeoVideo.name)" (\(vimeoVideo.id)) does not have an associated \
          episode.
          """
        )
        continue
      }
      guard let downloadURL = vimeoVideo.download.first(where: { $0.rendition == .p1080 })
      else {
        reportIssue(
          """
          🛑 Vimeo video "\(vimeoVideo.name)" (\(vimeoVideo.id)) does not have 1080p. Investigate.
          """
        )
        continue
      }
      guard
        let cloudflareVideo = cloudflareVideos.result.first(where: {
          $0.meta["vimeoID"] == String(vimeoVideo.id)
        })
      else {
        print(
          """
          ⬆️ Copying Vimeo video "\(vimeoVideo.name)" (\(vimeoVideo.id)) to Cloudflare
          """
        )
        let uploadEnvelope = try await cloudflare.copy(downloadURL.link)
        try await editVideo(
          cloudflareVideoID: uploadEnvelope.result.uid,
          vimeoVideo: vimeoVideo,
          episode: episode,
          isTrailer: isTrailer
        )
        continue
      }
      try await editVideo(
        cloudflareVideoID: cloudflareVideo.uid,
        vimeoVideo: vimeoVideo,
        episode: episode,
        isTrailer: isTrailer
      )
    }
  }
}

func editVideo(
  cloudflareVideoID: String,
  vimeoVideo: Vimeo.Video,
  episode: Episode,
  isTrailer: Bool
) async throws {
  @Dependency(CloudflareClient.self) var cloudflare
  @Dependency(\.siteRouter) var siteRouter
  print(
    """
    🔄 Refreshing Cloudflare video (\(cloudflareVideoID)) with Vimeo video "\(vimeoVideo.name)" \
    (\(vimeoVideo.id))
    """
  )
  _ = try await cloudflare.editVideo(
    .init(
      videoID: cloudflareVideoID,
      allowedOrigins: [
        "pointfree.co",
        "www.pointfree.co",
        "localhost:8080",
        "127.0.0.1:8080",
      ],
      meta: [
        "name": episode.cloudflareInternalName(isTrailer: isTrailer),
        "vimeoID": vimeoVideo.id.description,
        "episodeSequence": episode.sequence.description,
      ],
      publicDetails: Video.PublicDetails(
        channelLink: "https://www.pointfree.co",
        logo:
          "https://pointfreeco-production.s3.amazonaws.com/social-assets/pf-avatar-square.jpg",
        shareLink: siteRouter.url(for: .episodes(.show(episode))),
        title: episode.cloudflarePublicName(isTrailer: isTrailer)
      ),
      thumbnailTimestampPct: 0.5
    )
  )
}

extension Episode {
  func cloudflareInternalName(isTrailer: Bool) -> String {
    """
    #\(sequence) \(isTrailer ? "(Trailer)" : "") \(fullTitle)
    """
  }
  func cloudflarePublicName(isTrailer: Bool) -> String {
    (isTrailer ? "Trailer: " : "") + fullTitle
  }
}
