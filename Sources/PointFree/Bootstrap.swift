import Either
import Foundation
import Optics
import Prelude

public func bootstrap() -> EitherIO<Error, Prelude.Unit> {
  return print(message: "⚠️ Bootstrapping PointFree...")
    .flatMap(const(loadEnvironment))
    .flatMap(const(connectToPostgres))
    .flatMap(const(print(message: "✅ PointFree Bootstrapped!")))
}

private func print(message: String) -> EitherIO<Error, Prelude.Unit> {
  return EitherIO<Error, Prelude.Unit>(run: IO {
    print(message)
    return .right(unit)
  })
}

private let stepDivider = print(message: "  -----------------------------")

private let loadEnvironment =
  print(message: "  ⚠️ Loading environment...")
    .flatMap(loadEnvVars)
    .flatMap(loadEpisodes)
    .flatMap(const(print(message: "  ✅ Loaded!")))

private let loadEnvVars = { (_: Prelude.Unit) -> EitherIO<Error, Prelude.Unit> in
  let envFilePath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent(".env")

  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  let defaultEnvVarDict = (try? encoder.encode(Current.envVars))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
    ?? [:]

  let localEnvVarDict = (try? Data(contentsOf: envFilePath))
    .flatMap { try? decoder.decode([String: String].self, from: $0) }
    ?? [:]

  let envVarDict = defaultEnvVarDict
    .merging(localEnvVarDict, uniquingKeysWith: { $1 })
    .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })

  let envVars = (try? JSONSerialization.data(withJSONObject: envVarDict))
    .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
    ?? Current.envVars

  update(&Current, \.envVars .~ envVars)
  return pure(unit)
}

private let loadEpisodes = { (_: Prelude.Unit) -> EitherIO<Error, Prelude.Unit> in
  #if OSS
  let allEpisodes = allPublicEpisodes
  #else
  let allEpisodes = allPublicEpisodes + allPrivateEpisodes
  #endif

  assert(allEpisodes.count == Set(allEpisodes.map(^\.id)).count)
  assert(allEpisodes.count == Set(allEpisodes.map(^\.sequence)).count)
  update(
    &Current, (\Environment.episodes) .~ {
      let now = Current.date()
      return allEpisodes
        .filter {
          Current.envVars.appEnv == .production
            ? $0.publishedAt <= now
            : true
      }
    }
  )
  return pure(unit)
}

private let connectToPostgres =
  print(message: "  ⚠️ Connecting to PostgreSQL at \(Current.envVars.postgres.databaseUrl)")
    .flatMap { _ in Current.database.migrate() }
    .catch { print(message: "  ❌ Error! \($0)").flatMap(const(throwE($0))) }
    .retry(maxRetries: 999_999, backoff: const(.seconds(1)))
    .flatMap(const(print(message: "  ✅ Connected to PostgreSQL!")))
    .flatMap(const(stepDivider))
