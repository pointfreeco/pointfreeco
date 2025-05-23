import Cloudflare
import Dependencies
import Models
import PointFreeRouter
import Vimeo

extension CloudflareClient {
  public func editVideo(
    cloudflareVideoID: Cloudflare.Video.ID,
    vimeoVideo: Vimeo.Video?,
    episode: Episode,
    isTrailer: Bool
  ) async throws {
    try await editVideo(
      cloudflareVideoID: cloudflareVideoID,
      cloudflareVideo: nil,
      vimeoVideo: vimeoVideo,
      episode: episode,
      isTrailer: isTrailer
    )
  }

  public func editVideo(
    cloudflareVideo: Cloudflare.Video,
    vimeoVideo: Vimeo.Video?,
    episode: Episode,
    isTrailer: Bool
  ) async throws {
    try await editVideo(
      cloudflareVideoID: cloudflareVideo.uid,
      cloudflareVideo: cloudflareVideo,
      vimeoVideo: vimeoVideo,
      episode: episode,
      isTrailer: isTrailer
    )
  }

  private func editVideo(
    cloudflareVideoID: Cloudflare.Video.ID,
    cloudflareVideo: Cloudflare.Video?,
    vimeoVideo: Vimeo.Video?,
    episode: Episode,
    isTrailer: Bool
  ) async throws {
    @Dependency(CloudflareClient.self) var cloudflare
    @Dependency(\.siteRouter) var siteRouter

    let newMeta = episode.cloudflareMeta(isTrailer: isTrailer, vimeoVideo: vimeoVideo)
    let newPublicDetails = episode.cloudflarePublicDetails(
      isTrailer: isTrailer,
      url: siteRouter.url(for: .episodes(.show(episode)))
    )
    guard
      newMeta != cloudflareVideo?.meta
        || newPublicDetails != cloudflareVideo?.publicDetails
        || allowedOrigins != cloudflareVideo?.allowedOrigins
    else {
      print(
      """
      ⏩ Skipping Cloudflare video (\(cloudflareVideoID)) update. Nothing changed.
      """
      )
      return
    }
//    print(
//      """
//      🔄 Refreshing Cloudflare video (\(cloudflareVideoID)) \
//      \(vimeoVideo.map { "with Vimeo video \"\($0.name)\" (\($0.id))" } ?? "")
//      """
//    )
    _ = try await cloudflare.editVideo(
      .init(
        videoID: cloudflareVideoID,
        allowedOrigins: allowedOrigins,
        meta: newMeta,
        publicDetails: newPublicDetails,
        thumbnailTimestampPct: 0.5
      )
    )
  }
}

private let allowedOrigins = [
  "pointfree.co",
  "www.pointfree.co",
  "localhost:8080",
  "127.0.0.1:8080",
]

extension Episode {
  public func cloudflareInternalName(isTrailer: Bool) -> String {
    """
    #\(sequence) \(isTrailer ? "(Trailer)" : "") \(fullTitle)
    """
  }

  public func cloudflarePublicName(isTrailer: Bool) -> String {
    (isTrailer ? "Trailer: " : "") + fullTitle
  }

  public func cloudflarePublicDetails(
    isTrailer: Bool,
    url: String
  ) -> Cloudflare.Video.PublicDetails {
    Cloudflare.Video.PublicDetails(
      channelLink: "https://www.pointfree.co",
      logo:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/81e7ec77-9dd7-4d5f-85fc-4a3a95c6f100/public",
      shareLink: url,
      title: cloudflarePublicName(isTrailer: isTrailer)
    )
  }

  public func cloudflareMeta(isTrailer: Bool, vimeoVideo: Vimeo.Video?) -> [String: String] {
    [
      "name": cloudflareInternalName(isTrailer: isTrailer),
//      "vimeoID": vimeoVideo?.id.description,
      "episodeSequence": sequence.description,
      "kind": isTrailer ? "trailer" : "episode",
    ]
    .compactMapValues(\.self)
  }
}
