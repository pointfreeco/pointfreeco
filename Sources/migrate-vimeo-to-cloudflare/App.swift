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

    @Dependency(\.envVars.appEnv) var appEnv
    @Dependency(\.episodes) var episodes
    @Dependency(CloudflareClient.self) var cloudflare
    @Dependency(\.vimeoClient) var vimeo

    guard appEnv == .production
    else {
      struct MigrationMustRunInProductionEnvironment: Error {}
      throw MigrationMustRunInProductionEnvironment()
    }

    Episode.bootstrapPrivateEpisodes()

    let cloudflareVideos = try await cloudflare.videos()

    print("⏳ Loading Vimeo videos")
    let startPage = 1
    let perPage = 100
    let pageCount = try await {
      Int(ceil(Double(try await vimeo.videos(page: 3, perPage: 1).total) / Double(perPage)))
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
      return try await group.reduce(into: []) { $0 += $1 }
    }
    print("✅ Loaded \(vimeoVideos.count) Vimeo videos")

    let episodesByVimeoID = Dictionary(grouping: episodes(), by: \.fullVideo.vimeoId)
      .compactMapValues(\.first)
    let episodesByTrailerVimeoID = Dictionary(grouping: episodes(), by: \.trailerVideo.vimeoId)
      .compactMapValues(\.first)
    func episode(for vimeoID: Vimeo.Video.ID) -> (
      kind: CloudflareClient.MetaVideoKind, episode: Episode
    )? {
      episodesByVimeoID[vimeoID.rawValue].map { (.episode, $0) }
        ?? episodesByTrailerVimeoID[vimeoID.rawValue].map { (.trailer, $0) }
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

      guard let downloadURL = vimeoVideo.download?.first(where: { $0.rendition == .p1080 })
      else {
        reportIssue(
          """
          🛑 Vimeo video "\(vimeoVideo.name)" (\(vimeoVideo.id)) does not have 1080p. Investigate.
          """
        )
        continue
      }
      // 🛑🛑🛑🛑🛑🛑🛑🛑 TODO: REMOVE
      return

      guard let (kind, episode) = episode(for: vimeoVideo.id)
      else {
        reportWarning(
          """
          ⚠️ Vimeo video "\(vimeoVideo.name)" (\(vimeoVideo.id)) does not have an associated \
          episode.
          """
        )
        continue
      }
      try await Task.sleep(for: .seconds(1))
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
        _ = try await cloudflare.editVideo(
          cloudflareVideoID: uploadEnvelope.result.uid,
          vimeoVideo: vimeoVideo,
          episode: episode,
          kind: kind
        )
        continue
      }
      _ = try await cloudflare.editVideo(
        cloudflareVideo: cloudflareVideo,
        vimeoVideo: vimeoVideo,
        episode: episode,
        kind: kind
      )
    }
  }
}
