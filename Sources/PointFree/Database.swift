import Either
import Foundation
import Prelude

public struct Database {
  var createSubscription: (StripeSubscription, User) -> EitherIO<Error, Prelude.Unit>
  var createUser: (GitHub.UserEnvelope) -> EitherIO<Error, Prelude.Unit>
  var fetchUser: (GitHub.AccessToken) -> EitherIO<Error, User?>
  var migrate: () -> EitherIO<Error, Prelude.Unit>

  static let `default` = Database(
    createSubscription: PointFree.createSubscription,
    createUser: PointFree.createUser,
    fetchUser: PointFree.fetchUser,
    migrate: PointFree.migrate
  )

  public struct User {
    let email: String
    let gitHubUserId: Int
    let gitHubAccessToken: String
    let id: UUID
    let name: String
    let subscriptionId: UUID?
  }

  public struct Subscription {
    let id: UUID
    let stripeSubscriptionId: String
    let userId: UUID
  }
}

private func createSubscription(with stripeSubscription: StripeSubscription, for user: Database.User)
  -> EitherIO<Error, Prelude.Unit> {
    return execute(
      """
      INSERT INTO "subscriptions" ("stripe_subscription_id", "user_id")
      VALUES ($1, $2)
      RETURNING "id"
      """,
      [
        stripeSubscription.id,
        user.id.uuidString,
        ]
      )
      .flatMap { node in
        execute(
          """
          UPDATE "users" SET (
            "subscription_id" = $1,
            "updated_at" = NOW()
          )
          WHERE "users"."id" = $2
          """,
          [
            node[0, "id"]?.string,
            user.id
          ]
        )
      }
      .map(const(unit))
}

private func createUser(with envelope: GitHub.UserEnvelope) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
      INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name")
      VALUES ($1, $2, $3, $4)
      ON CONFLICT ("github_user_id") DO UPDATE
      SET "email" = $1, "github_access_token" = $3, "name" = $4
      """,
    [
      envelope.gitHubUser.email,
      envelope.gitHubUser.id,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name
    ]
    )
    .map(const(unit))
}

private func fetchUser(with token: GitHub.AccessToken) -> EitherIO<Error, Database.User?> {
  return execute(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "github_access_token" = $1
    LIMIT 1
    """,
    [token.accessToken]
    )
    .map { result -> Database.User? in
      let uuid = result[3, "id"].flatMap(get(\.string) >>> flatMap(UUID.init(uuidString:)))

      let subscriptionId = result[5, "subscription_id"]
        .flatMap(get(\.string) >>> flatMap(UUID.init(uuidString:)))

      return curry(Database.User.init)
        <¢> result[0, "email"]?.string
        <*> result[1, "github_user_id"]?.int
        <*> result[2, "github_access_token"]?.string
        <*> uuid
        <*> result[4, "name"]?.string
        <*> .some(subscriptionId)
  }
}

private func migrate() -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "public"
    """
    )
    .flatMap(const(execute(
      """
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "public"
      """
    )))
    .flatMap(const(execute(
      """
      CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "public"
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "users" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "email" citext NOT NULL UNIQUE,
        "github_user_id" integer UNIQUE,
        "github_access_token" character varying,
        "name" character varying,
        "subscription_id" uuid,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "subscriptions" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL,
        "stripe_subscription_id" character varying NOT NULL,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      );
      """
    )))
    .map(const(unit))
}

#if os(iOS)
  enum PostgreSQL {
    enum ConnInfo {
      case basic(String, Int, String, String, String)
    }
    struct Database {
      init(_ connInfo: ConnInfo) throws {
      }
      func makeConnection() throws -> Connection {
        return Connection()
      }
    }
    struct Connection {
      func execute(_ query: String, _ representable: [NodeRepresentable] = []) throws -> Node {
        return Node()
      }
    }
    public typealias NodeRepresentable = Any
    struct Node {
      subscript(_: Int, _: String) -> Node? {
        return nil
      }
      var int: Int?
      var string: String?
    }
  }
#else
  import PostgreSQL
#endif

/// FIXME: Move to Stripe.swift
public struct StripeSubscription {
  let id: String
}

public enum DatabaseError: Error {
  case invalidUrl
}

private let connInfo = URLComponents(string: AppEnvironment.current.envVars.postgres.databaseUrl)
  .flatMap { url -> PostgreSQL.ConnInfo? in
    curry(PostgreSQL.ConnInfo.basic)
      <¢> url.host
      <*> url.port
      <*> String(url.path.dropFirst())
      <*> url.user
      <*> url.password
  }
  .map(Either.right)
  ?? .left(DatabaseError.invalidUrl as Error)

private let postgres = lift(connInfo)
  .flatMap(EitherIO.init <<< IO.wrap(Either.wrap(PostgreSQL.Database.init)))

private let conn = postgres
  .flatMap { db in .wrap(db.makeConnection) }

// public let execute = EitherIO.init <<< IO.wrap(Either.wrap(conn.execute))
private func execute(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, PostgreSQL.Node> {

    return conn.flatMap { conn in
      .wrap { try conn.execute(query, representable) }
    }
}
