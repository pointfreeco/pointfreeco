import Backtrace
import Dependencies
import Models

public func bootstrap() async {
  print("⚠️ Bootstrapping PointFree...")
  defer { print("✅ PointFree Bootstrapped!") }

  Backtrace.install()

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
    defer { print("  ✅ Connected to PostgreSQL!") }

    do {
      try await migrate()
      return
    } catch {
      print("  ❌ Error! \(error)")
      try? await Task.sleep(for: .seconds(1))
    }
  }
}
