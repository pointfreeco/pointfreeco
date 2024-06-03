import Dependencies
import Models
import VimeoClient

public func bootstrap() async {
  @Dependency(\.fireAndForget) var fireAndForget

  print("⚠️ Bootstrapping PointFree...")
  defer { print("✅ PointFree Bootstrapped!") }

  await connectToPostgres()
  await fireAndForget {
    await updateClips()
  }

  #if !OSS
    print("  ⚠️ Bootstrapping transcripts")
    //Episode.bootstrapPrivateEpisodes()
    print("  ✅ \(Episode.all.count) transcripts loaded")
  #endif
}

private func connectToPostgres() async {
  @Dependency(\.envVars.postgres.databaseUrl) var databaseUrl
  @Dependency(\.database.migrate) var migrate

  while true {
    print("  ⚠️ Connecting to PostgreSQL at \(databaseUrl)")
    do {
      try await migrate()
      print("  ✅ Connected to PostgreSQL!")
      break
    } catch {
      print("  ❌ Error! \(error)")
      print("     Make sure you are running postgres: pg_ctl -D /usr/local/var/postgres start")
      try? await Task.sleep(for: .seconds(1))
    }
  }
}

private func updateClips() async {
  print("  ⚠️ Updating Vimeo clips")
  defer {
    print("  ✅ Vimeo clips updated!")
  }

  @Dependency(\.collections) var collections
  @Dependency(\.database) var database
  @Dependency(\.vimeoClient) var vimeoClient

  do {
    let clipsCollectionID = 15685787
    for vimeoVideo in try await vimeoClient.videos(inCollection: clipsCollectionID).data {
      do {
        try await database.updateClip(vimeoVideo: vimeoVideo)
        print("    ✅ Vimeo clip updated: \(vimeoVideo.name)")
      } catch {
        print("    ❌ Clip error: \(error)")
      }
    }
  } catch {
    print("  ❌ Vimeo error: \(error)")
  }

  print("  ⚠️ Updating collection clips")

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
            let clip = try await database.fetchClip(vimeoVideoID: clip.vimeoID)
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

  do {
    try await collections.update(updatedCollections)
    print("  ✅ Updated collection clips")
  } catch {
    print("  ❌ Updating collection clips")
  }
}
