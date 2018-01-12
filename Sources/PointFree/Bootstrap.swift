import Either
import Prelude

public func bootstrap() -> EitherIO<Error, Prelude.Unit> {

  return print(message: "Bootstrapping PointFree...")
    .flatMap(const(connectToPostgres))
    .flatMap(const(syncronizeMailgunNewsletterRoutes))
    .flatMap(const(print(message: "PointFree Bootstrapped!")))
}

private func print(message: String) -> EitherIO<Error, Prelude.Unit> {
  return EitherIO<Error, Prelude.Unit>(run: IO {
    print(message)
    return .right(unit)
  })
}

private let connectToPostgres =
  print(message: "Connecting to PostgreSQL...")
    .flatMap { _ in AppEnvironment.current.database.migrate() }
    .flatMap(const(print(message: "Connected to PostgreSQL!")))
    .retry(maxRetries: 999_999, backoff: const(.seconds(1)))

