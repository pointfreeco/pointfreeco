import Cloudflare
import Dependencies
import EnvVars
import IssueReporting
import Models
import PointFreePrelude

public func bootstrap() async {
  prepareDependencies {
    $0[CloudflareClient.self] =
      .live(
        accountID: $0.envVars.cloudflare.accountID,
        apiToken: $0.envVars.cloudflare.streamAPIKey
      )
  }
  IssueReporters.current += [.adminEmail]

  @Dependency(\.fireAndForget) var fireAndForget

  print("⏳ Bootstrapping PointFree...")
  defer { print("✅ PointFree Bootstrapped!") }

  print("  ⏳ Bootstrapping transcripts")
  Episode.bootstrapPrivateEpisodes()
  print("  ✅ \(Episode.all.count) transcripts loaded")

  await connectToPostgres()
  await fireAndForget {
    await updateCollectionClips()
  }
  await fireAndForget {
    try await updateCloudflareVideos()
  }
}

private func connectToPostgres() async {
  @Dependency(\.envVars.postgres.databaseUrl) var databaseUrl
  @Dependency(\.database.migrate) var migrate

  while true {
    print("  ⏳ Connecting to PostgreSQL at \(databaseUrl)")
    do {
      try await migrate()
      print("  ✅ Connected to PostgreSQL!")
      break
    } catch {
      #if DEBUG
        print("  ❌ Error! \(String(reflecting: error))")
      #else
        print("  ❌ Error! \(error)")
      #endif
      print("     Make sure you are running postgres: pg_ctl -D /usr/local/var/postgres start")
      try? await Task.sleep(for: .seconds(1))
    }
  }
}

private func updateCollectionClips() async {
  print("  ⏳ Updating collection clips")
  defer {
    print("  ✅ Collections updated!")
  }

  @Dependency(\.collections) var collections
  @Dependency(\.database) var database

  var updatedCollections = Episode.Collection.all
  for (collectionIndex, var collection) in updatedCollections.enumerated() {
    defer { updatedCollections[collectionIndex] = collection }
    for (sectionIndex, var section) in collection.sections.enumerated() {
      defer { collection.sections[sectionIndex] = section }
      for (lessonIndex, var lesson) in section.coreLessons.enumerated() {
        defer { section.coreLessons[lessonIndex] = lesson }

        switch lesson {
        case .clip(let clip):
          do {
            let clip = try await database.fetchClip(cloudflareVideoID: clip.cloudflareVideoID)
            lesson = .clip(clip)
          } catch {
            print("    ❌ Clip error: \(error)")
          }
        case .episode:
          break
        }
      }
    }
  }

  await collections.update(updatedCollections)
}

private func updateCloudflareVideos() async throws {
  print("  ⏳ Updating Cloudflare videos")
  defer {
    print("  ✅ Cloudflare videos updated!")
  }

  @Dependency(\.database) var database
  @Dependency(\.envVars) var envVars
  @Dependency(\.episodes) var episodes
  @Dependency(CloudflareClient.self) var cloudflare

  guard
    envVars.appEnv == .production,
    envVars.baseUrl.absoluteString.contains("pointfree.co")
  else {
    print("    ⏩ Skip updating Cloudflare videos when not in production environment.")
    return
  }

  await withErrorReporting {
    // TODO: Paginate to make sure we get all. Currently this endpoint is limited to 1,000 videos.
    let videos = try await cloudflare.videos()
    let clips = try await database.fetchClips(includeHidden: true)

    for video in videos.result {
      let episode = episodes().first(where: {
        $0.fullVideo.id == video.uid
          || $0.trailerVideo.id == video.uid
      })
      let clip = clips.first(where: { $0.cloudflareVideoID == video.uid })
      if let episode {
        let didUpdate = try await retry(maxRetries: 100, backoff: { _ in .seconds(10) }) {
          try await cloudflare.editVideo(
            cloudflareVideo: video,
            episode: episode,
            kind: episode.trailerVideo.id == video.uid ? .trailer : .episode
          )
        }
        if didUpdate {
          try await Task.sleep(for: .seconds(0.5))
        }
      } else if let clip {
        let didUpdate = try await retry(maxRetries: 100, backoff: { _ in .seconds(10) }) {
          try await cloudflare.editVideo(
            cloudflareVideo: video,
            clip: clip
          )
        }
        if didUpdate {
          try await Task.sleep(for: .seconds(0.5))
        }
      }
    }
  }
}
