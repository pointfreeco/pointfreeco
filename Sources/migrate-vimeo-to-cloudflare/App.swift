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

    print("⏳ Loading Vimeo videos")
    let startPage = 1
    let perPage = 100
    let pageCount = try await {
      Int(ceil(Double(try await vimeo.videos(page: nil, perPage: 1).total) / Double(perPage)))
    }()
    let vimeoVideos = try await withThrowingTaskGroup { group in
      for page in startPage...pageCount {
        group.addTask {
          print("   ℹ️ Loading batch \(page)...")
          defer { print("   ℹ️ Loaded batch \(page)!") }
          let batch = try await vimeo.videos(page: page, perPage: perPage)
          return batch.data
        }
      }
      return try await group .reduce(into: []) { $0 += $1 }
    }
    print("✅ Loaded \(vimeoVideos.count) Vimeo videos")

    let vimeoVideosByID = Dictionary(grouping: vimeoVideos, by: \.id)
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


    var warnings: [String] = []
    var issues: [String] = []
    func reportWarning(_ warning: String) {
      warnings.append(warning)
      print(warning)
    }
    func reportIssue(_ issue: String) {
      issues.append(issue)
      IssueReporting.reportIssue(issue)
    }
    defer {
      print("Migration finished!")
      if !warnings.isEmpty {
        print("Warnings:")
        print(warnings.map { "  \($0)" }.joined(separator: "\n"))
      }
      if !issues.isEmpty {
        print("Issues:")
        print(issues.map { "  \($0)" }.joined(separator: "\n"))
      }
    }

    for vimeoVideo in vimeoVideos {
      try await Task.sleep(for: .seconds(1))
      guard let (isTrailer, episode) = episode(for: vimeoVideo.id)
      else {
        reportWarning(
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
  cloudflareVideoID: Cloudflare.Video.ID,
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
          "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/81e7ec77-9dd7-4d5f-85fc-4a3a95c6f100/public",
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
