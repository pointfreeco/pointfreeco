import Either
import Foundation
import Prelude
import PostgreSQL

public struct Database {
  var addUserIdToSubscriptionId: (User.Id, Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  var createSubscription: (Stripe.Subscription, User.Id) -> EitherIO<Error, Prelude.Unit>
  var deleteTeamInvite: (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>
  var fetchAdmins: () -> EitherIO<Error, [User]>
  var fetchEmailSettingsForUserId: (User.Id) -> EitherIO<Error, [EmailSetting]>
  var fetchEpisodeCredits: (User.Id) -> EitherIO<Error, [EpisodeCredit]>
  var fetchFreeEpisodeUsers: () -> EitherIO<Error, [User]>
  var fetchSubscriptionById: (Subscription.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionByOwnerId: (User.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionTeammatesByOwnerId: (User.Id) -> EitherIO<Error, [User]>
  var fetchTeamInvite: (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>
  var fetchTeamInvites: (User.Id) -> EitherIO<Error, [TeamInvite]>
  var fetchUserByGitHub: (GitHub.User.Id) -> EitherIO<Error, User?>
  var fetchUserById: (User.Id) -> EitherIO<Error, User?>
  var fetchUsersSubscribedToNewsletter: (EmailSetting.Newsletter) -> EitherIO<Error, [User]>
  var fetchUsersToWelcome: (Int) -> EitherIO<Error, [User]>
  var incrementEpisodeCredits: ([User.Id]) -> EitherIO<Error, [User]>
  var insertTeamInvite: (EmailAddress, User.Id) -> EitherIO<Error, TeamInvite>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>
  var redeemEpisodeCredit: (Int, User.Id) -> EitherIO<Error, Prelude.Unit>
  var registerUser: (GitHub.UserEnvelope, EmailAddress) -> EitherIO<Error, User?>
  var removeTeammateUserIdFromSubscriptionId: (User.Id, Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  var updateStripeSubscription: (Stripe.Subscription) -> EitherIO<Error, Subscription?>
  var updateUser: (User.Id, String?, EmailAddress?, [EmailSetting.Newsletter]?, Int?) -> EitherIO<Error, Prelude.Unit>
  var upsertUser: (GitHub.UserEnvelope, EmailAddress) -> EitherIO<Error, User?>

  static let live = Database(
    addUserIdToSubscriptionId: PointFree.add(userId:toSubscriptionId:),
    createSubscription: PointFree.createSubscription,
    deleteTeamInvite: PointFree.deleteTeamInvite,
    fetchAdmins: PointFree.fetchAdmins,
    fetchEmailSettingsForUserId: PointFree.fetchEmailSettings(forUserId:),
    fetchEpisodeCredits: PointFree.fetchEpisodeCredits(for:),
    fetchFreeEpisodeUsers: PointFree.fetchFreeEpisodeUsers,
    fetchSubscriptionById: PointFree.fetchSubscription(id:),
    fetchSubscriptionByOwnerId: PointFree.fetchSubscription(ownerId:),
    fetchSubscriptionTeammatesByOwnerId: PointFree.fetchSubscriptionTeammates(ownerId:),
    fetchTeamInvite: PointFree.fetchTeamInvite,
    fetchTeamInvites: PointFree.fetchTeamInvites,
    fetchUserByGitHub: PointFree.fetchUser(byGitHubUserId:),
    fetchUserById: PointFree.fetchUser(byUserId:),
    fetchUsersSubscribedToNewsletter: PointFree.fetchUsersSubscribed(to:),
    fetchUsersToWelcome: PointFree.fetchUsersToWelcome(fromWeeksAgo:),
    incrementEpisodeCredits: PointFree.incrementEpisodeCredits(for:),
    insertTeamInvite: PointFree.insertTeamInvite,
    migrate: PointFree.migrate,
    redeemEpisodeCredit: PointFree.redeemEpisodeCredit(episodeSequence:userId:),
    registerUser: PointFree.registerUser(withGitHubEnvelope:email:),
    removeTeammateUserIdFromSubscriptionId: PointFree.remove(teammateUserId:fromSubscriptionId:),
    updateStripeSubscription: PointFree.update(stripeSubscription:),
    updateUser: PointFree.updateUser(withId:name:email:emailSettings:episodeCreditCount:),
    upsertUser: PointFree.upsertUser(withGitHubEnvelope:email:)
  )

  public struct EmailSetting: Codable, Equatable {
    public internal(set) var newsletter: Newsletter
    public internal(set) var userId: Database.User.Id

    public enum CodingKeys: String, CodingKey {
      case newsletter
      case userId = "user_id"
    }

    public enum Newsletter: String, RawRepresentable, Codable {
      case announcements
      case newBlogPost
      case newEpisode
      case welcomeEmails

      public static let allNewsletters: [Newsletter] = [
        .announcements,
        .newBlogPost,
        .newEpisode,
        .welcomeEmails
      ]

      public static let subscriberNewsletters: [Newsletter] = [
        .announcements,
        .newBlogPost,
        .newEpisode
      ]
    }
  }

  public struct EpisodeCredit: Decodable, Equatable {
    public internal(set) var episodeSequence: Int
    public internal(set) var userId: User.Id

    public enum CodingKeys: String, CodingKey {
      case episodeSequence = "episode_sequence"
      case userId = "user_id"
    }
  }

  public struct User: Decodable, Equatable {
    public internal(set) var email: EmailAddress
    public internal(set) var episodeCreditCount: Int
    public internal(set) var gitHubUserId: GitHub.User.Id
    public internal(set) var gitHubAccessToken: String
    public internal(set) var id: Id
    public internal(set) var isAdmin: Bool
    public internal(set) var name: String?
    public private(set) var subscriptionId: Subscription.Id?

    public typealias Id = Tagged<User, UUID>

    public enum CodingKeys: String, CodingKey {
      case email
      case episodeCreditCount = "episode_credit_count"
      case gitHubUserId = "github_user_id"
      case gitHubAccessToken = "github_access_token"
      case id
      case isAdmin = "is_admin"
      case name
      case subscriptionId = "subscription_id"
    }

    var displayName: String {
      return name ?? email.rawValue
    }
  }

  public struct Subscription: Decodable {
    internal(set) var id: Id
    internal(set) var stripeSubscriptionId: Stripe.Subscription.Id
    internal(set) var stripeSubscriptionStatus: Stripe.Subscription.Status
    internal(set) var userId: User.Id

    public typealias Id = Tagged<Subscription, UUID>

    private enum CodingKeys: String, CodingKey {
      case id
      case stripeSubscriptionId = "stripe_subscription_id"
      case stripeSubscriptionStatus = "stripe_subscription_status"
      case userId = "user_id"
    }
  }

  public struct TeamInvite: Decodable {
    internal(set) var createdAt: Date
    internal(set) var email: EmailAddress
    internal(set) var id: Id
    internal(set) var inviterUserId: User.Id

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
  with stripeSubscription: Stripe.Subscription, for userId: Database.User.Id
  )
  -> EitherIO<Error, Prelude.Unit> {
    return execute(
      """
      INSERT INTO "subscriptions" ("stripe_subscription_id", "stripe_subscription_status", "user_id")
      VALUES ($1, $2, $3)
      RETURNING "id"
      """,
      [
        stripeSubscription.id.rawValue,
        stripeSubscription.status.rawValue,
        userId.rawValue.uuidString,
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
            userId.rawValue.uuidString
          ]
        )
      }
      .map(const(unit))
}

private func update(stripeSubscription: Stripe.Subscription) -> EitherIO<Error, Database.Subscription?> {
  return firstRow(
    """
    UPDATE "subscriptions"
    SET "stripe_subscription_status" = $1, "updated_at" = NOW()
    WHERE "subscriptions"."stripe_subscription_id" = $2
    RETURNING "id", "stripe_subscription_id", "stripe_subscription_status", "user_id"
    """,
    [
      stripeSubscription.status.rawValue,
      stripeSubscription.id.rawValue
    ]
  )
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
      subscriptionId.rawValue.uuidString,
      userId.rawValue.uuidString,
    ]
  )
  .map(const(unit))
}

private func remove(
  teammateUserId: Database.User.Id,
  fromSubscriptionId subscriptionId: Database.Subscription.Id
  ) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    UPDATE "users"
    SET "subscription_id" = NULL,
        "updated_at" = NOW()
    WHERE "users"."id" = $1
    AND "users"."subscription_id" = $2
    """,
    [
      teammateUserId.rawValue.uuidString,
      subscriptionId.rawValue.uuidString,
      ]
    )
    .map(const(unit))
}

private func fetchSubscription(id: Database.Subscription.Id) -> EitherIO<Error, Database.Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
    [id.rawValue.rawValue]
  )
}

private func fetchSubscription(ownerId: Database.User.Id) -> EitherIO<Error, Database.Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "user_id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
    [ownerId.rawValue.uuidString]
  )
}

private func fetchSubscriptionTeammates(ownerId: Database.User.Id) -> EitherIO<Error, [Database.User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id"
    FROM "users"
    INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
    WHERE "subscriptions"."user_id" = $1
    """,
    [ownerId.rawValue.uuidString]
  )
}

private func updateUser(
  withId userId: Database.User.Id,
  name: String?,
  email: EmailAddress?,
  emailSettings: [Database.EmailSetting.Newsletter]?,
  episodeCreditCount: Int?
  ) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    UPDATE "users"
    SET "name" = COALESCE($1, "name"),
        "email" = COALESCE($2, "email"),
        "episode_credit_count" = COALESCE($3, "episode_credit_count"),
        "updated_at" = NOW()
    WHERE "id" = $4
    """,
    [
      name,
      email?.rawValue,
      episodeCreditCount,
      userId.rawValue.uuidString
    ]
    )
    .flatMap(const(updateEmailSettings(settings: emailSettings, forUserId: userId)))
}

// TODO: This should return a non-optional user
private func registerUser(
  withGitHubEnvelope envelope: GitHub.UserEnvelope,
  email: EmailAddress
  ) -> EitherIO<Error, Database.User?> {

  return upsertUser(withGitHubEnvelope: envelope, email: email)
    .flatMap { optionalUser in
      guard let user = optionalUser else { return pure(optionalUser) }

      return updateEmailSettings(settings: Database.EmailSetting.Newsletter.allNewsletters, forUserId: user.id)
        .map(const(optionalUser))
  }
}

private func updateEmailSettings(
  settings: [Database.EmailSetting.Newsletter]?,
  forUserId userId: Database.User.Id
  )
  -> EitherIO<Error, Prelude.Unit> {

    guard let settings = settings else { return pure(unit) }

    let deleteEmailSettings = execute(
      """
      DELETE FROM "email_settings"
      WHERE "user_id" = $1
      """,
      [userId.rawValue.uuidString]
      )
      .map(const(unit))

    let updateEmailSettings = sequence(
      settings.map { type in
        execute(
          """
          INSERT INTO "email_settings" ("newsletter", "user_id")
          VALUES ($1, $2)
          """,
          [
            type.rawValue,
            userId.rawValue.uuidString
          ]
        )
      }
    )
    .map(const(unit))

    return sequence([deleteEmailSettings, updateEmailSettings])
      .map(const(unit))
}

// TODO: This should return a non-optional user
private func upsertUser(
  withGitHubEnvelope envelope: GitHub.UserEnvelope,
  email: EmailAddress
  ) -> EitherIO<Error, Database.User?> {

  return execute(
    """
    INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name", "episode_credit_count")
    VALUES ($1, $2, $3, $4, 1)
    ON CONFLICT ("github_user_id") DO UPDATE
    SET "github_access_token" = $3, "name" = $4
    """,
    [
      email.rawValue,
      envelope.gitHubUser.id.rawValue,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name
    ]
    )
    .flatMap { _ in
      Current.database
        .fetchUserByGitHub(envelope.gitHubUser.id)
  }
}

private func fetchUser(byUserId id: Database.User.Id) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.rawValue.uuidString]
  )
}

private func fetchUsersSubscribed(to newsletter: Database.EmailSetting.Newsletter) -> EitherIO<Error, [Database.User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id"
    FROM "email_settings" LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
    WHERE "email_settings"."newsletter" = $1
    """,
    [newsletter.rawValue]
  )
}

private func fetchUsersToWelcome(fromWeeksAgo weeksAgo: Int) -> EitherIO<Error, [Database.User]> {
  let daysAgo = weeksAgo * 7
  return rows(
    """
    SELECT
        "users"."email",
        "users"."episode_credit_count",
        "users"."github_user_id",
        "users"."github_access_token",
        "users"."id",
        "users"."is_admin",
        "users"."name",
        "users"."subscription_id"
    FROM
        "email_settings"
        LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
        LEFT JOIN "subscriptions" on "users"."id" = "subscriptions"."user_id"
    WHERE
        "email_settings"."newsletter" = $1
        AND "users"."created_at" BETWEEN CURRENT_DATE - INTERVAL '\(daysAgo) DAY'
        AND CURRENT_DATE - INTERVAL '\(daysAgo - 1) DAY'
        AND "users"."subscription_id" IS NULL
        AND "subscriptions"."user_id" IS NULL;
    """,
    [Database.EmailSetting.Newsletter.welcomeEmails.rawValue]
  )
}

private func incrementEpisodeCredits(for userIds: [Database.User.Id]) -> EitherIO<Error, [Database.User]> {
  guard !userIds.isEmpty else { return pure([]) }
  return rows(
    """
    UPDATE "users"
    SET "episode_credit_count" = "episode_credit_count" + 1
    WHERE "id" IN (\(userIds.map { "'\($0.rawValue.uuidString)'" }.joined(separator: ",")))
    RETURNING *
    """,
    []
  )
}

private func fetchUser(byGitHubUserId userId: GitHub.User.Id) -> EitherIO<Error, Database.User?> {
  return firstRow(
    """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id"
    FROM "users"
    WHERE "github_user_id" = $1
    LIMIT 1
    """,
    [userId.rawValue]
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
    [id.rawValue.uuidString]
  )
}

private func deleteTeamInvite(id: Database.TeamInvite.Id) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    DELETE FROM "team_invites"
    WHERE "id" = $1
    """,
    [id.rawValue.uuidString]
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
    [inviterId.rawValue.uuidString]
  )
}

private func fetchAdmins() -> EitherIO<Error, [Database.User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id"
    FROM "users"
    WHERE "users"."is_admin" = TRUE
    """,
    []
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
      email.rawValue,
      inviterUserId.rawValue.uuidString
    ]
    )
    .flatMap { node -> EitherIO<Error, Database.TeamInvite> in
      node[0, "id"]?.string
        .flatMap(UUID.init(uuidString:))
        .map(
          Database.TeamInvite.Id.init
            >>> Current.database.fetchTeamInvite
            >>> mapExcept(requireSome)
        )
        ?? throwE(unit)
    }
}

private func fetchEmailSettings(forUserId userId: Database.User.Id) -> EitherIO<Error, [Database.EmailSetting]> {

  return rows(
    """
    SELECT "newsletter", "user_id"
    FROM "email_settings"
    WHERE "user_id" = $1
    """,
    [userId.rawValue.uuidString]
  )
}

private func fetchEpisodeCredits(for userId: Database.User.Id) -> EitherIO<Error, [Database.EpisodeCredit]> {
  return rows(
    """
    SELECT "episode_sequence", "user_id"
    FROM "episode_credits"
    WHERE "user_id" = $1
    """,
    [userId.rawValue.uuidString]
  )
}

private func fetchFreeEpisodeUsers() -> EitherIO<Error, [Database.User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id"
    FROM "users"
    LEFT JOIN "subscriptions" ON "subscriptions"."id" = "users"."subscription_id"
    LEFT JOIN "email_settings" ON "email_settings"."user_id" = "users"."id"
    WHERE (
      "subscriptions"."stripe_subscription_status" IS NULL
        OR "subscriptions"."stripe_subscription_status" != $1
    )
    AND "email_settings"."newsletter" = $2;
    """,
    [
      Stripe.Subscription.Status.active.rawValue,
      Database.EmailSetting.Newsletter.newEpisode.rawValue
    ]
  )
}

private func redeemEpisodeCredit(episodeSequence: Int, userId: Database.User.Id) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    INSERT INTO "episode_credits" ("episode_sequence", "user_id")
    VALUES ($1, $2)
    """,
    [
      episodeSequence,
      userId.rawValue.uuidString
    ]
    )
    .map(const(unit))
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
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "email_settings" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "newsletter" character varying,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "subscriptions"
      ADD COLUMN IF NOT EXISTS
      "stripe_subscription_status" character varying NOT NULL DEFAULT 'active'
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "is_admin" boolean NOT NULL DEFAULT FALSE
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_on_stripe_subscription_id"
      ON "subscriptions" ("stripe_subscription_id")
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "episode_credits" (
        "episode_sequence" integer,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_credits_on_episode_sequence_and_user_id"
      ON "episode_credits" ("episode_sequence", "user_id")
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "episode_credit_count" integer NOT NULL DEFAULT 0
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "episode_credits"
      ADD COLUMN IF NOT EXISTS
      "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
      """
    )))
    .map(const(unit))
}

public enum DatabaseError: Error {
  case invalidUrl
}

private let connInfo = URLComponents(string: Current.envVars.postgres.databaseUrl)
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
      return .wrap { return try conn.execute(query, representable) }
    }
}
