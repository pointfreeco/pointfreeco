import Either
import Foundation
import PostgreSQL
import Prelude

public struct User {
  let email: String
  let gitHubUserId: Int
  let gitHubAccessToken: String
  let id: Int
  let name: String
  let subscriptionId: Int?
}

public struct Subscription {
  let stripeSubscriptionId: String
  let userId: Int
}

// FIXME
public struct StripeSubscription {
  let id: String
}

public enum DatabaseError: Error {
  case invalidUrl
}

private let connInfo = URLComponents(string: AppEnvironment.current.envVars.postgres.databaseUrl)
  .flatMap {
    curry(ConnInfo.basic)
      <¢> $0.host
      <*> $0.port
      <*> $0.path
      <*> $0.user
      <*> $0.password
  }.map(Either.right)
  ?? .left(DatabaseError.invalidUrl as Error)

private let postgres = lift(connInfo).flatMap(EitherIO.init <<< IO.wrap(Either.wrap(Database.init)))

private let conn = postgres
  .flatMap { db in .wrap(db.makeConnection) }

public func execute(_ query: String, _ representable: [NodeRepresentable]) -> EitherIO<Error, Node> {
  return conn.flatMap { conn in
    .wrap { try conn.execute(query, representable) }
  }
}

public func createSubscription(from stripeSubscription: StripeSubscription, for user: User)
  -> EitherIO<Error, Prelude.Unit> {
    return execute(
      """
      INSERT INTO "subscriptions" ("stripe_susbcription_id", "user_id")
      VALUES ($1, $2)
      RETURNING "id"
      """,
      [
        stripeSubscription.id,
        user.id,
      ]
      )
      .flatMap { node in
        execute(
          """
          UPDATE "users"
          SET "subscription_id" = $1
          WHERE "users"."id" = $2
          """,
          [
            node[0, "id"]?.int,
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

public func curry<A, B, C, D, E, F, G>(_ fn: @escaping (A, B, C, D, E, F) -> G)
  -> (A)
  -> (B)
  -> (C)
  -> (D)
  -> (E)
  -> (F)
  -> G {
    return { a in
      { b in
        { c in
          { d in
            { e in
              { f in
                fn(a, b, c, d, e, f)
              }
            }
          }
        }
      }
    }
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
    .map { result in
      return curry(User.init)
        <¢> result[0, "email"]?.string
        <*> result[1, "github_user_id"]?.int
        <*> result[2, "github_access_token"]?.string
        <*> result[3, "id"]?.int
        <*> result[4, "name"]?.string
        <*> .some(result[5, "subscription_id"]?.int)
  }
}
