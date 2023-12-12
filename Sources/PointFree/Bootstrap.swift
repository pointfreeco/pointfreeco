import Dependencies
import Models

public func bootstrap() async {
  print("⚠️ Bootstrapping PointFree...")
  defer { print("✅ PointFree Bootstrapped!") }

  #if !OSS
    print("  ⚠️ Bootstrapping transcripts")
    Episode.bootstrapPrivateEpisodes()
    print("  ✅ \(Episode.all.count) transcripts loaded")
  #endif

  await connectToPostgres()
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
