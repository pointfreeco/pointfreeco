import Database
import Dependencies
import Foundation
import PostgresKit
import Testing

/// A trait that provisions a dedicated Postgres schema for each test in a shared test database
/// that is prepared a single time per test run.
///
/// Apply to a suite or test to exercise real SQL queries in full isolation from other tests:
///
/// ```swift
/// @Suite(.database) struct FeatureTests { ... }
/// ```
struct DatabaseTrait: TestTrait, SuiteTrait, TestScoping {
  var isRecursive: Bool { true }

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: @Sendable () async throws -> Void
  ) async throws {
    guard testCase != nil else { return try await function() }
    try await TestDatabase.withTestDatabase { pool in
      try await withDependencies {
        $0.database = .live(pool: pool)
      } operation: {
        try await function()
      }
    }
  }
}

extension Trait where Self == DatabaseTrait {
  static var database: Self { Self() }
}

enum TestDatabase {
  /// Creates a schema in the shared test database, migrates it, hands a connection pool bound to
  /// it (via `search_path`) to `body`, and drops the schema when `body` finishes.
  ///
  /// Schema-level isolation is used rather than database-level cloning because
  /// `CREATE DATABASE`/`DROP DATABASE` are serialized inside the Postgres server (~70ms per test
  /// that no amount of test parallelism can hide), whereas schema creation and migration run on
  /// the test's own connections and parallelize across cores.
  static func withTestDatabase<R: Sendable>(
    _ body: @Sendable (EventLoopGroupConnectionPool<PostgresConnectionSource>) async throws -> R
  ) async throws -> R {
    let sharedConfiguration = try await sharedDatabase.value
    // Each test gets a single-event-loop pool (one connection) inside a gated permit, so total
    // connections stay bounded below the server's `max_connections` no matter how many tests
    // are in flight.
    return try await gate.withGate {
      try await provision(sharedConfiguration, body)
    }
  }

  /// The gate shared by every `.database` test; also available to gate other
  /// database-adjacent work.
  static let gate = Gate(limit: 16)

  private static func provision<R: Sendable>(
    _ sharedConfiguration: SQLPostgresConfiguration,
    _ body: (EventLoopGroupConnectionPool<PostgresConnectionSource>) async throws -> R
  ) async throws -> R {
    let suffix = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    let schemaName = "test_\(suffix)"

    var configuration = sharedConfiguration
    // Every connection the test makes resolves unqualified table names to its own schema, and
    // extension types/functions to the shared "extensions" schema.
    configuration.coreConfiguration.options.additionalStartupParameters = [
      ("search_path", "\(schemaName),extensions")
    ]
    let pool = EventLoopGroupConnectionPool(
      source: PostgresConnectionSource(sqlConfiguration: configuration),
      on: MultiThreadedEventLoopGroup.singleton.next()
    )
    let database = pool.database(logger: logger).sql()
    let result: Result<R, any Error>
    do {
      try await database.run("CREATE SCHEMA \(ident: schemaName)")
      // The deterministic ID shims must exist before migrating: column defaults bind to the
      // function resolved via `search_path` at DDL time.
      try await database.run("CREATE SEQUENCE test_uuids")
      try await database.run("CREATE SEQUENCE test_shortids")
      try await database.run(
        """
        CREATE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
        RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      try await database.run(
        """
        CREATE FUNCTION gen_shortid(table_name text, column_name text)
        RETURNS text AS $$
        BEGIN
          RETURN table_name||'-'||column_name||nextval('test_shortids')::text;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      try await Client.live(pool: pool).migrate()
      result = .success(try await body(pool))
    } catch {
      result = .failure(error)
    }
    // Best effort: schemas leaked here are discarded when the next run recreates the database.
    try? await database.run("DROP SCHEMA IF EXISTS \(ident: schemaName) CASCADE")
    try await pool.shutdownAsync()
    return try result.get()
  }

  private static let sharedDatabaseName = "pointfreeco_test_modern"
  private static let advisoryLockKey = 0x7066_7465_7374 as Int64  // "pftest"

  /// Prepares the shared test database exactly once per test run: recreates it from scratch
  /// (which also discards schemas leaked by crashed runs) and installs the extensions the
  /// migrations rely on into a shared "extensions" schema.
  private static let sharedDatabase = Task<SQLPostgresConfiguration, any Error> {
    var sharedConfiguration = try Self.baseConfiguration()

    // A single-threaded, single-connection pool so that the session-scoped advisory lock is
    // held on one connection for the entire rebuild.
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let lockPool = EventLoopGroupConnectionPool(
      source: PostgresConnectionSource(sqlConfiguration: sharedConfiguration),
      on: eventLoopGroup
    )
    sharedConfiguration.coreConfiguration.database = sharedDatabaseName
    do {
      let admin = lockPool.database(logger: logger).sql()
      try await admin.run("SELECT pg_advisory_lock(\(bind: advisoryLockKey))")
      try await admin.run("DROP DATABASE IF EXISTS \(ident: sharedDatabaseName) WITH (FORCE)")
      try await admin.run("CREATE DATABASE \(ident: sharedDatabaseName)")

      let setupPool = EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(sqlConfiguration: sharedConfiguration),
        on: eventLoopGroup
      )
      do {
        let setup = setupPool.database(logger: logger).sql()
        try await setup.run("CREATE SCHEMA \(ident: "extensions")")
        for `extension` in ["pgcrypto", "uuid-ossp", "citext"] {
          try await setup.run(
            "CREATE EXTENSION IF NOT EXISTS \(ident: `extension`) WITH SCHEMA \(ident: "extensions")"
          )
        }
      } catch {
        try? await setupPool.shutdownAsync()
        throw error
      }
      try await setupPool.shutdownAsync()

      try await admin.run("SELECT pg_advisory_unlock(\(bind: advisoryLockKey))")
      try await lockPool.shutdownAsync()
    } catch {
      try? await lockPool.shutdownAsync()
      throw error
    }
    return sharedConfiguration
  }

  private static func baseConfiguration() throws -> SQLPostgresConfiguration {
    let url =
      ProcessInfo.processInfo.environment["DATABASE_URL"]
      ?? "postgres://pointfreeco:@localhost:5432/pointfreeco_test"
    precondition(
      url.contains("localhost"),
      "Refusing to run tests against a non-localhost database."
    )
    return try SQLPostgresConfiguration(url: url)
  }
}

extension SQLDatabase {
  fileprivate func run(_ query: SQLQueryString) async throws {
    try await self.raw(query).run()
  }
}

private let logger = Logger(label: "TestDatabase")
