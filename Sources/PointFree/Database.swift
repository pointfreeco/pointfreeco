import Either
import Foundation
import PostgreSQL
import Prelude

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

/// FIXME: Move to Stripe.swift
public struct StripeSubscription {
  let id: String
}

public enum DatabaseError: Error {
  case invalidUrl
}

private let connInfo = URLComponents(string: AppEnvironment.current.envVars.postgres.databaseUrl)
  .flatMap { url -> ConnInfo? in
    curry(ConnInfo.basic)
      <¢> url.host
      <*> url.port
      <*> String(url.path.dropFirst())
      <*> url.user
      <*> url.password
  }
  .map(Either.right)
  ?? .left(DatabaseError.invalidUrl as Error)

private let postgres = lift(connInfo).flatMap(EitherIO.init <<< IO.wrap(Either.wrap(Database.init)))

private let conn = postgres
  .flatMap { db in .wrap(db.makeConnection) }

// public let execute = EitherIO.init <<< IO.wrap(Either.wrap(conn.execute))
public func execute(_ query: String, _ representable: [NodeRepresentable] = []) -> EitherIO<Error, Node> {
  return conn.flatMap { conn in
    .wrap { try conn.execute(query, representable) }
  }
}

public func createSubscription(from stripeSubscription: StripeSubscription, for user: User)
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

public func createUser(from envelope: GitHubUserEnvelope) -> EitherIO<Error, Prelude.Unit> {
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
      envelope.gitHubUser.name,
      ]
    )
    .map(const(unit))
}

public func fetchUser(from token: GitHubAccessToken) -> EitherIO<Error, User?> {
  return execute(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "github_token" = $1
    LIMIT 1
    """,
    [token.accessToken]
    )
    .map { result -> User? in
      let uuid = result[3, "id"].flatMap { $0.string.flatMap(UUID.init(uuidString:)) }
      let subscriptionId = result[5, "subscription_id"].flatMap { $0.string.flatMap(UUID.init(uuidString:)) }

      return curry(User.init)
        <¢> result[0, "email"]?.string
        <*> result[1, "github_user_id"]?.int
        <*> result[2, "github_access_token"]?.string
        <*> uuid
        <*> result[4, "name"]?.string
        <*> .some(subscriptionId)
  }
}

public func migrate() -> EitherIO<Error, Prelude.Unit> {
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
