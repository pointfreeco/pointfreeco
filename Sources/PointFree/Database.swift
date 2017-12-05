import Either
import Foundation
import Prelude
import PostgreSQL

public struct Database {
  var createSubscription: (Stripe.Subscription, User) -> EitherIO<Error, Prelude.Unit>
  var fetchUserByGitHub: (GitHub.AccessToken) -> EitherIO<Error, User?>
  var fetchUserById: (UUID) -> EitherIO<Error, User?>
  var upsertUser: (GitHub.UserEnvelope) -> EitherIO<Error, Database.User?>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>

  static let live = Database(
    createSubscription: PointFree.createSubscription,
    fetchUserByGitHub: PointFree.fetchUserByGitHub,
    fetchUserById: PointFree.fetchUserById,
    upsertUser: PointFree.upsertUser,
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

private func createSubscription(with stripeSubscription: Stripe.Subscription, for user: Database.User)
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

private func upsertUser(with envelope: GitHub.UserEnvelope) -> EitherIO<Error, Database.User?> {
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
    .flatMap { _ in fetchUserByGitHub(with: envelope.accessToken) }
}

private func fetchUserById(uuid: UUID) -> EitherIO<Error, Database.User?> {
  return execute(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
    [uuid.uuidString]
    )
    .map(Database.User.create(from:))
}

private func fetchUserByGitHub(with token: GitHub.AccessToken) -> EitherIO<Error, Database.User?> {
  return execute(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "github_access_token" = $1
    LIMIT 1
    """,
    [token.accessToken]
    )
    .map(Database.User.create(from:))
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

extension Database.User {
  static func create(from result: Node) -> Database.User? {
    let uuid = result["id"]?.array?.first?.wrapped.string.flatMap(UUID.init(uuidString:))
    let subscriptionId = result["subscription_id"]?.array?.first?.wrapped.string.flatMap(UUID.init(uuidString:))

    return curry(Database.User.init)
      <¢> result["email"]?.array?.first?.wrapped.string
      <*> result["github_user_id"]?.array?.first?.wrapped.int
      <*> result["github_access_token"]?.array?.first?.wrapped.string
      <*> uuid
      <*> result["name"]?.array?.first?.wrapped.string
      <*> .some(subscriptionId)
  }
}
