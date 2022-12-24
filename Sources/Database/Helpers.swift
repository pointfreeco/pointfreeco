import PostgresKit
import Tagged

extension EventLoopGroupConnectionPool where Source == PostgresConnectionSource {
  var sqlDatabase: SQLDatabase {
    self.database(logger: logger).sql()
  }
}

extension SQLDatabase {
  func run(_ query: SQLQueryString) async throws {
    try await self.raw(query).run()
  }

  func all<D: Decodable>(
    _ query: SQLQueryString,
    decoding model: D.Type = D.self
  ) async throws -> [D] {
    try await self.raw(query)
      .all()
      .map { try $0.decode(model: model, keyDecodingStrategy: .convertFromSnakeCase) }
  }

  func first<D: Decodable>(
    _ query: SQLQueryString,
    decoding model: D.Type = D.self
  ) async throws -> D {
    try await self.raw(query)
      .first()
      .unwrap()
      .decode(model: model, keyDecodingStrategy: .convertFromSnakeCase)
  }
}

extension Tagged: PostgresDataConvertible where RawValue: PostgresDataConvertible {}

private let logger = Logger(label: "Postgres")
