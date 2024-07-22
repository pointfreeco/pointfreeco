import Dependencies
import EnvVars
import Models

public func bootstrap() async {
  @Dependency(\.fireAndForget) var fireAndForget

  print("⚠️ Bootstrapping PointFree...")
  defer { print("✅ PointFree Bootstrapped!") }

  print("  ⚠️ Bootstrapping transcripts")
  Episode.bootstrapPrivateEpisodes()
  print("  ✅ \(Episode.all.count) transcripts loaded")

  await connectToPostgres()
  await fireAndForget {
    await updateCollectionClips()
  }
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

private func updateCollectionClips() async {
  print("  ⚠️ Updating collection clips")
  defer {
    print("  ✅ Vimeo collection updated!")
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
            let clip = try await database.fetchClip(vimeoVideoID: clip.vimeoVideoID)
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
