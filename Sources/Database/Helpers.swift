import Either
import PostgresKit
import Prelude
import Tagged

extension EitherIO where E == Error {
  init(_ eventLoopFuture: @escaping @autoclosure () -> EventLoopFuture<A>) {
    self.init(
      run: .init { callback in
        eventLoopFuture()
          .whenComplete {
            result in callback(.init(result: result))
          }
      }
    )
  }
}

extension PostgresDatabase {
  func run(_ query: SQLQueryString) -> EitherIO<Error, Unit> {
    EitherIO(self.sql().raw(query).run().map(const(unit)))
  }
}

extension SQLRawBuilder {
  func first<D>(decoding: D.Type) -> EitherIO<Error, D?> where D: Decodable {
    .init(self.first(decoding: D.self))
  }

  func first() -> EitherIO<Error, SQLRow?> {
    .init(self.first())
  }

  func all<D>(decoding: D.Type) -> EitherIO<Error, [D]> where D: Decodable {
    .init(self.all(decoding: D.self))
  }

  func run() -> EitherIO<Error, Prelude.Unit> {
    .init(self.run().map(const(unit)))
  }
}

extension EventLoopGroupConnectionPool where Source == PostgresConnectionSource {
  var sqlDatabase: SQLDatabase {
    self.database(logger: logger).sql()
  }
}

private let logger: Logger = {
  var logger = Logger(label: "Postgres")
  logger.logLevel = .trace
  return logger
}()

extension Either where L: Error {
  init(result: Result<R, L>) {
    switch result {
    case let .success(value):
      self = .right(value)
    case let .failure(error):
      self = .left(error)
    }
  }
}

extension Tagged: PostgresDataConvertible where RawValue: PostgresDataConvertible {
}
