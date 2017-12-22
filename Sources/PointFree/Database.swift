import Either
import Foundation
import Prelude
import PostgreSQL

public struct Database {
  var addUserIdToSubscriptionId: (User.Id, Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  var createSubscription: (Stripe.Subscription.Id, User.Id) -> EitherIO<Error, Prelude.Unit>
  var deleteTeamInvite: (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>
  var insertTeamInvite: (EmailAddress, User.Id) -> EitherIO<Error, TeamInvite>
  var fetchSubscriptionById: (Subscription.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionByOwnerId: (User.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionTeammatesByOwnerId: (User.Id) -> EitherIO<Error, [User]>
  var fetchTeamInvite: (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>
  var fetchTeamInvites: (User.Id) -> EitherIO<Error, [TeamInvite]>
  var fetchUserByGitHub: (GitHub.User.Id) -> EitherIO<Error, User?>
  var fetchUserById: (User.Id) -> EitherIO<Error, User?>
  var updateUser: (User.Id, String, EmailAddress) -> EitherIO<Error, Prelude.Unit>
  var upsertUser: (GitHub.UserEnvelope) -> EitherIO<Error, User?>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>

  static let live = Database(
    addUserIdToSubscriptionId: PointFree.add(userId:toSubscriptionId:),
    createSubscription: PointFree.createSubscription,
    deleteTeamInvite: PointFree.deleteTeamInvite,
    insertTeamInvite: PointFree.insertTeamInvite,
    fetchSubscriptionById: PointFree.fetchSubscription(id:),
    fetchSubscriptionByOwnerId: PointFree.fetchSubscription(ownerId:),
    fetchSubscriptionTeammatesByOwnerId: PointFree.fetchSubscriptionTeammates(ownerId:),
    fetchTeamInvite: PointFree.fetchTeamInvite,
    fetchTeamInvites: PointFree.fetchTeamInvites,
    fetchUserByGitHub: PointFree.fetchUser(byGitHubUserId:),
    fetchUserById: PointFree.fetchUser(byUserId:),
    updateUser: PointFree.updateUser(withId:name:email:),
    upsertUser: PointFree.upsertUser(withGitHubEnvelope:),
    migrate: PointFree.migrate
  )

  public struct User: Decodable {
    public let email: EmailAddress
    public let gitHubUserId: GitHub.User.Id
    public let gitHubAccessToken: String
    public let id: Id
    public let name: String
    public private(set) var subscriptionId: Subscription.Id?

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

  public struct TeamInvite: Decodable {
    let createdAt: Date
    let email: EmailAddress
    let id: Id
    let inviterUserId: User.Id

    public typealias Id = Tagged<TeamInvite, UUID>

    private enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case email
      case id
      case inviterUserId = "inviter_user_id"
    }
  }
}

private func createSubscription(
  with stripeSubscriptionId: Stripe.Subscription.Id, for userId: Database.User.Id
  )
  -> EitherIO<Error, Prelude.Unit> {
    return execute(
      """
      INSERT INTO "subscriptions" ("stripe_subscription_id", "user_id")
      VALUES ($1, $2)
      RETURNING "id"
      """,
      [
        stripeSubscriptionId.unwrap,
        userId.unwrap.uuidString,
        ]
      )
      .flatMap { node in
        execute(
          """
          UPDATE "users"
          SET "subscription_id" = $1, "updated_at" = NOW()
          WHERE "users"."id" = $2
          """,
          [
            node[0, "id"]?.string,
            userId.unwrap.uuidString
          ]
        )
      }
      .map(const(unit))
}

private func add(userId: Database.User.Id, toSubscriptionId subscriptionId: Database.Subscription.Id) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    UPDATE "users"
    SET "subscription_id" = $1,
        "updated_at" = NOW()
    WHERE "users"."id" = $2
    """,
    [
      userId.unwrap.uuidString,
      subscriptionId.unwrap.uuidString,
    ]
  )
  .map(const(unit))
}

private func fetchSubscription(id: Database.Subscription.Id) -> EitherIO<Error, Database.Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id"
    FROM "subscriptions"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.unwrap.uuidString]
  )
}

private func fetchSubscription(ownerId: Database.User.Id) -> EitherIO<Error, Database.Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id"
    FROM "subscriptions"
    WHERE "user_id" = $1
    LIMIT 1
    """,
    [ownerId.unwrap.uuidString]
  )
}

private func fetchSubscriptionTeammates(ownerId: Database.User.Id) -> EitherIO<Error, [Database.User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."name",
           "users"."subscription_id"
    FROM "users"
    INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
    WHERE "subscriptions"."user_id" = $1
    AND "users"."id" != $1
    """,
    [ownerId.unwrap.uuidString]
  )
}

private func updateUser(withId id: Database.User.Id, name: String, email: EmailAddress) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    UPDATE "users"
    SET "name" = $1, "email" = $2
    WHERE "id" = $3
    """,
    [
      name,
      email.unwrap,
      id.unwrap.uuidString,
    ]
    )
    .map(const(unit))
}

private func upsertUser(withGitHubEnvelope envelope: GitHub.UserEnvelope) -> EitherIO<Error, Database.User?> {
  return execute(
    """
    INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name")
    VALUES ($1, $2, $3, $4)
    ON CONFLICT ("github_user_id") DO UPDATE
    SET "github_access_token" = $3, "name" = $4
    """,
    [
      envelope.gitHubUser.email.unwrap,
      envelope.gitHubUser.id.unwrap,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name
    ]
    )
    .flatMap { _ in
      AppEnvironment.current.database
        .fetchUserByGitHub(envelope.gitHubUser.id)
  }
}

private func fetchUser(byUserId id: Database.User.Id) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name", "subscription_id"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.unwrap.uuidString]
  )
}

private func fetchUser(byGitHubUserId userId: GitHub.User.Id) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name", "subscription_id"
    FROM "users"
    WHERE "github_user_id" = $1
    LIMIT 1
    """,
    [userId.unwrap]
  )
}

private func fetchTeamInvite(id: Database.TeamInvite.Id) -> EitherIO<Error, Database.TeamInvite?> {
  return firstRow(
    """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.unwrap.uuidString]
  )
}

private func deleteTeamInvite(id: Database.TeamInvite.Id) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    DELETE
    FROM "team_invites"
    WHERE "id" = $1
    """,
    [id.unwrap.uuidString]
  )
  .map(const(unit))
}

private func fetchTeamInvites(inviterId: Database.User.Id) -> EitherIO<Error, [Database.TeamInvite]> {
  return rows(
    """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "inviter_user_id" = $1
    """,
    [inviterId.unwrap.uuidString]
  )
}

private func insertTeamInvite(
  email: EmailAddress,
  inviterUserId: Database.User.Id
  ) -> EitherIO<Error, Database.TeamInvite> {

  return execute(
    """
    INSERT INTO "team_invites" ("email", "inviter_user_id")
    VALUES ($1, $2)
    RETURNING "id"
    """,
    [
      email.unwrap,
      inviterUserId.unwrap.uuidString
    ]
    )
    .flatMap { node -> EitherIO<Error, Database.TeamInvite> in
      node[0, "id"]?.string
        .flatMap(UUID.init(uuidString:))
        .map(
          Database.TeamInvite.Id.init
            >>> AppEnvironment.current.database.fetchTeamInvite
            >>> mapExcept(requireSome)
        )
        ?? throwE(unit)
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
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "team_invites" (
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "email" character varying,
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "inviter_user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
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
func execute(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, PostgreSQL.Node> {

    return conn.flatMap { conn in
      .wrap { try conn.execute(query, representable) }
    }
}
