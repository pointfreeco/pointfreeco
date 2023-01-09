import Backtrace
import Dependencies
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
    .flatMap(const(connectToPostgres()))
    .flatMap(const(.debug(prefix: "✅ PointFree Bootstrapped!")))
}

private let stepDivider = EitherIO.debug(prefix: "  -----------------------------")

private func connectToPostgres() -> EitherIO<Error, Prelude.Unit> {
  @Dependency(\.envVars.postgres.databaseUrl) var databaseUrl
  @Dependency(\.database.migrate) var migrate

  return EitherIO.debug(prefix: "  ⚠️ Connecting to PostgreSQL at \(databaseUrl)")
  .flatMap { _ in EitherIO { try await migrate() } }
  .catch { EitherIO.debug(prefix: "  ❌ Error! \($0)").flatMap(const(throwE($0))) }
  .retry(maxRetries: 999_999, backoff: const(.seconds(1)))
  .flatMap(const(.debug(prefix: "  ✅ Connected to PostgreSQL!")))
  .flatMap(const(stepDivider))
}
