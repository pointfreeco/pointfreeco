import Cloudflare
import Dependencies
import Models
import PointFreeRouter

extension CloudflareClient {
  public enum MetaVideoKind: String {
    case episode, trailer, clip
  }

  public func editVideo(
    cloudflareVideoID: Cloudflare.Video.ID,

    episode: Episode,
    kind: MetaVideoKind
  ) async throws -> Bool {
    @Dependency(\.siteRouter) var siteRouter
    return try await editVideo(
      cloudflareVideoID: cloudflareVideoID,
      cloudflareVideo: nil,
      meta: episode.cloudflareMeta(kind: kind),
      publicDetails: episode.cloudflarePublicDetails(
        kind: kind,
        url: siteRouter.url(for: .episodes(.show(episode)))
      ),
      kind: kind
    )
  }

  public func editVideo(
    cloudflareVideo: Cloudflare.Video,
    episode: Episode,
    kind: MetaVideoKind
  ) async throws -> Bool {
    @Dependency(\.siteRouter) var siteRouter
    return try await editVideo(
      cloudflareVideoID: cloudflareVideo.uid,
      cloudflareVideo: cloudflareVideo,
      meta: episode.cloudflareMeta(kind: kind),
      publicDetails: episode.cloudflarePublicDetails(
        kind: kind,
        url: siteRouter.url(for: .episodes(.show(episode)))
      ),
      kind: kind
    )
  }

  public func editVideo(
    cloudflareVideo: Cloudflare.Video,
    clip: Clip
  ) async throws -> Bool {
    @Dependency(\.siteRouter) var siteRouter
    return try await editVideo(
      cloudflareVideoID: cloudflareVideo.uid,
      cloudflareVideo: cloudflareVideo,
      meta: clip.cloudflareMeta(),
      publicDetails: clip.cloudflarePublicDetails(
        url: siteRouter.url(for: .clips(.clip(cloudflareVideoID: cloudflareVideo.uid)))
      ),
      kind: .clip
    )
  }

  private func editVideo(
    cloudflareVideoID: Cloudflare.Video.ID,
    cloudflareVideo: Cloudflare.Video?,
    meta: [String: String],
    publicDetails: Cloudflare.Video.PublicDetails,
    kind: MetaVideoKind
  ) async throws -> Bool {
    @Dependency(CloudflareClient.self) var cloudflare
    @Dependency(\.siteRouter) var siteRouter
    guard
      meta.keys.contains(where: { meta[$0]! != cloudflareVideo?.meta?[$0] })
        || publicDetails != cloudflareVideo?.publicDetails
        || allowedOrigins != cloudflareVideo?.allowedOrigins
    else {
      print(
        """
        ⏩ Skipping Cloudflare \(kind.rawValue) (\(cloudflareVideoID)) update. Nothing changed.
        """
      )
      return false
    }
    print(
      """
      🔄 Refreshing Cloudflare \(kind.rawValue) (\(cloudflareVideoID))
      """
    )
    _ = try await cloudflare.editVideo(
      .init(
        videoID: cloudflareVideoID,
        allowedOrigins: allowedOrigins,
        meta: meta,
        publicDetails: publicDetails,
        thumbnailTimestampPct: 0.5
      )
    )
    return true
  }
}

private let allowedOrigins = [
  "pointfree.co",
  "www.pointfree.co",
  "localhost:8080",
  "127.0.0.1:8080",
]

extension Episode {
  public func cloudflareInternalName(kind: CloudflareClient.MetaVideoKind) -> String {
    """
    #\(sequence)\(kind == .trailer ? " (Trailer) " : " ")\(fullTitle)
    """
  }

  public func cloudflarePublicName(kind: CloudflareClient.MetaVideoKind) -> String {
    (kind == .trailer ? "Trailer: " : "") + fullTitle
  }

  public func cloudflarePublicDetails(
    kind: CloudflareClient.MetaVideoKind,
    url: String
  ) -> Cloudflare.Video.PublicDetails {
    Cloudflare.Video.PublicDetails(
      channelLink: "https://www.pointfree.co",
      logo:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/81e7ec77-9dd7-4d5f-85fc-4a3a95c6f100/public",
      shareLink: url,
      title: cloudflarePublicName(kind: kind)
    )
  }

  public func cloudflareMeta(
    kind: CloudflareClient.MetaVideoKind
  ) -> [String: String] {
    [
      "name": cloudflareInternalName(kind: kind),
      "episodeSequence": sequence.description,
      "kind": kind.rawValue,
    ]
    .compactMapValues(\.self)
  }
}

extension Clip {
  public var cloudflareInternalName: String {
    "(Clip) \(title)"
  }

  public var cloudflarePublicName: String {
    title
  }

  public func cloudflarePublicDetails(url: String) -> Cloudflare.Video.PublicDetails {
    Cloudflare.Video.PublicDetails(
      channelLink: "https://www.pointfree.co",
      logo:
        "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/81e7ec77-9dd7-4d5f-85fc-4a3a95c6f100/public",
      shareLink: url,
      title: cloudflarePublicName
    )
  }

  public func cloudflareMeta() -> [String: String] {
    [
      "name": cloudflareInternalName,
      "kind": CloudflareClient.MetaVideoKind.clip.rawValue,
    ]
    .compactMapValues(\.self)
  }
}
