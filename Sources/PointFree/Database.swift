import Either
import Foundation
import Prelude
import PostgreSQL

public struct Database {
  var createSubscription: (Stripe.Subscription, User) -> EitherIO<Error, Prelude.Unit>
  var fetchUserByGitHub: (GitHub.AccessToken) -> EitherIO<Error, User?>
  var fetchUserById: (User.Id) -> EitherIO<Error, User?>
  var upsertUser: (GitHub.UserEnvelope) -> EitherIO<Error, Database.User?>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>

  static let live = Database(
    createSubscription: PointFree.createSubscription,
    fetchUserByGitHub: PointFree.fetchUser(gitHubAccessToken:),
    fetchUserById: PointFree.fetchUser(byUserId:),
    upsertUser: PointFree.upsertUser(withGitHubEnvelope:),
    migrate: PointFree.migrate
  )

  public struct User: Decodable {
    public let email: EmailAddress
    public let gitHubUserId: GitHub.User.Id
    public let gitHubAccessToken: String
    public let id: Id
    public let name: String
    public let subscriptionId: Subscription.Id?

    public typealias Id = Tagged<User, UUID>

    private enum CodingKeys: String, CodingKey {
      case email
      case gitHubUserId = "github_user_id"
      case gitHubAccessToken = "github_access_token"
      case id
      case name
      case subscriptionId = "subscription_id"
    }
  }

  public struct Subscription: Decodable {
    let id: Id
    let stripeSubscriptionId: Stripe.Subscription.Id
    let userId: User.Id

    public typealias Id = Tagged<Subscription, UUID>

    private enum CodingKeys: String, CodingKey {
      case id
      case stripeSubscriptionId = "stripe_subscription_id"
      case userId = "user_id"
    }
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
        stripeSubscription.id.unwrap,
        user.id.unwrap.uuidString,
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
            user.id.unwrap.uuidString
          ]
        )
      }
      .map(const(unit))
}

private func upsertUser(withGitHubEnvelope envelope: GitHub.UserEnvelope) -> EitherIO<Error, Database.User?> {
  return execute(
    """
    INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name")
    VALUES ($1, $2, $3, $4)
    ON CONFLICT ("github_user_id") DO UPDATE
    SET "email" = $1, "github_access_token" = $3, "name" = $4
    """,
    [
      envelope.gitHubUser.email.unwrap,
      envelope.gitHubUser.id.unwrap,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name
    ]
    )
    .flatMap { _ in fetchUser(gitHubAccessToken: envelope.accessToken) }
}

private func fetchUser(byUserId id: Database.User.Id) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.unwrap.uuidString]
  )
}

private func fetchUser(gitHubAccessToken: GitHub.AccessToken) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "github_access_token" = $1
    LIMIT 1
    """,
    // TODO: make this fetch by the github id, not access token, since it can change. also maybe build in
    //       a fetch and update to refresh the token.
    [gitHubAccessToken.accessToken]
  )
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

private func rows<T: Decodable>(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, [T]> {

    return execute(query, representable)
      .flatMap { node in
        EitherIO.wrap {
          try DatabaseDecoder().decode([T].self, from: node)
        }
    }
}

private func firstRow<T: Decodable>(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, T?> {

    return rows(query, representable)
      .map(^\.first)
}

// public let execute = EitherIO.init <<< IO.wrap(Either.wrap(conn.execute))
private func execute(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, PostgreSQL.Node> {

    return conn.flatMap { conn in
      .wrap { try conn.execute(query, representable) }
    }
}
