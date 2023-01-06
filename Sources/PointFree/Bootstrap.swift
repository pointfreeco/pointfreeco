import Backtrace
import Either
import Foundation
import GitHub
import Mailgun
import Models
import NIO
import PointFreePrelude
import PointFreeRouter
import PostgresKit
import Prelude

public func bootstrap() -> EitherIO<Error, Prelude.Unit> {
  Backtrace.install()

  return EitherIO.debug(prefix: "⚠️ Bootstrapping PointFree...")
    .flatMap(const(connectToPostgres))
    .flatMap(const(.debug(prefix: "✅ PointFree Bootstrapped!")))
}

private let stepDivider = EitherIO.debug(prefix: "  -----------------------------")

private let connectToPostgres =
  EitherIO.debug(prefix: "  ⚠️ Connecting to PostgreSQL at \(Current.envVars.postgres.databaseUrl)")
  .flatMap { _ in EitherIO { try await Current.database.migrate() } }
  .catch { EitherIO.debug(prefix: "  ❌ Error! \($0)").flatMap(const(throwE($0))) }
  .retry(maxRetries: 999_999, backoff: const(.seconds(1)))
  .flatMap(const(.debug(prefix: "  ✅ Connected to PostgreSQL!")))
  .flatMap(const(stepDivider))
