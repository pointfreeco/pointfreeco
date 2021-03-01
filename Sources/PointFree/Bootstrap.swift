import Backtrace
import Either
import Foundation
import GitHub
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude

public func bootstrap() -> EitherIO<Error, Prelude.Unit> {
  return EitherIO.debug(prefix: "⚠️ Bootstrapping PointFree...")
    .flatMap(const(installBacktrace))
    .flatMap(const(loadEnvironment))
    .flatMap(const(connectToPostgres))
    .flatMap(const(.debug(prefix: "✅ PointFree Bootstrapped!")))
}

private let installBacktrace =
  EitherIO.debug(prefix: "  ⚠️ Installing Backtrace...")
    .flatMap(const(EitherIO<Error, Prelude.Unit>(run: IO {
      Backtrace.install()
      return .right(unit)
    })))
    .flatMap(const(.debug(prefix: "  ✅ Backtrace installed!")))

private let stepDivider = EitherIO.debug(prefix: "  -----------------------------")

private let loadEnvironment =
  EitherIO.debug(prefix: "  ⚠️ Loading environment...")
    .flatMap(loadEnvVars)
    .flatMap(loadEpisodes)
    .flatMap(const(.debug(prefix: "  ✅ Loaded!")))

private let loadEnvVars = { (_: Prelude.Unit) -> EitherIO<Error, Prelude.Unit> in
  let envFilePath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent(".pf-env")

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

  Current.envVars = envVars
  Current.database = envVars.emergencyMode
    ? .noop
    : .init(
      databaseUrl: Current.envVars.postgres.databaseUrl,
      logger: Current.logger
    )
  Current.gitHub = .init(
    clientId: Current.envVars.gitHub.clientId,
    clientSecret: Current.envVars.gitHub.clientSecret,
    logger: Current.logger
  )
  Current.mailgun = .init(
    apiKey: Current.envVars.mailgun.apiKey,
    appSecret: Current.envVars.appSecret,
    domain: Current.envVars.mailgun.domain,
    logger: Current.logger
  )
  Current.stripe = .init(
    logger: Current.logger,
    secretKey: Current.envVars.stripe.secretKey
  )
  pointFreeRouter = PointFreeRouter(baseUrl: Current.envVars.baseUrl)

  return pure(unit)
}

private let loadEpisodes = { (_: Prelude.Unit) -> EitherIO<Error, Prelude.Unit> in
  #if !OSS
  Episode.bootstrapPrivateEpisodes()
  #endif
  assert(Episode.all.count == Set(Episode.all.map(^\.id)).count)
  assert(Episode.all.count == Set(Episode.all.map(^\.sequence)).count)

  Current.episodes = {
    let now = Current.date()
    return Episode.all
      .filter {
        Current.envVars.appEnv == .production
          ? $0.publishedAt <= now
          : true
    }
    .sorted(by: their(^\.sequence))
  }
  return pure(unit)
}

private let connectToPostgres =
  EitherIO.debug(prefix: "  ⚠️ Connecting to PostgreSQL at \(Current.envVars.postgres.databaseUrl)")
    .flatMap { _ in Current.database.migrate() }
    .catch { EitherIO.debug(prefix: "  ❌ Error! \($0)").flatMap(const(throwE($0))) }
    .retry(maxRetries: 999_999, backoff: const(.seconds(1)))
    .flatMap(const(.debug(prefix: "  ✅ Connected to PostgreSQL!")))
    .flatMap(const(stepDivider))
