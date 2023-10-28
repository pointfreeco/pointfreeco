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

extension Tagged: PostgresEncodable where RawValue: PostgresEncodable {}

extension Tagged: PostgresDecodable where RawValue: PostgresDecodable {
  public init<JSONDecoder: PostgresJSONDecoder>(
    from byteBuffer: inout ByteBuffer,
    type: PostgresDataType,
    format: PostgresFormat,
    context: PostgresDecodingContext<JSONDecoder>
  ) throws {
    self.init(
      rawValue: try RawValue(
        from: &byteBuffer,
        type: type,
        format: format,
        context: context
      )
    )
  }
}

extension Tagged: PostgresArrayEncodable where RawValue: PostgresArrayEncodable {
  public static var psqlArrayType: PostgresDataType {
    RawValue.psqlArrayType
  }
}

extension Tagged: PostgresThrowingDynamicTypeEncodable where RawValue: PostgresEncodable {}

private let logger = Logger(label: "Postgres")
