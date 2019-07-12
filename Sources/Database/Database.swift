import Either
import Foundation
import GitHub
import Logger
import Models
import PointFreePrelude
import Prelude
import PostgresNIO
import Stripe
import Tagged

public struct Client {
  public var addUserIdToSubscriptionId: (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  public var createEnterpriseAccount: (String, EnterpriseAccount.Domain, Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>
  public var createEnterpriseEmail: (EmailAddress, User.Id) -> EitherIO<Error, EnterpriseEmail?>
  public var createFeedRequestEvent: (FeedRequestEvent.FeedType, String, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var createSubscription: (Stripe.Subscription, Models.User.Id) -> EitherIO<Error, Models.Subscription?>
  public var deleteEnterpriseEmail: (User.Id) -> EitherIO<Error, Prelude.Unit>
  public var deleteTeamInvite: (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>
  public var execute: (String, [PostgresDataConvertible]) -> EitherIO<Swift.Error, [PostgresRow]>
  public var fetchAdmins: () -> EitherIO<Error, [Models.User]>
  public var fetchEmailSettingsForUserId: (Models.User.Id) -> EitherIO<Error, [EmailSetting]>
  public var fetchEnterpriseAccountForDomain: (EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseAccountForSubscription: (Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseEmails: () -> EitherIO<Error, [EnterpriseEmail]>
  public var fetchEpisodeCredits: (Models.User.Id) -> EitherIO<Error, [EpisodeCredit]>
  public var fetchFreeEpisodeUsers: () -> EitherIO<Error, [Models.User]>
  public var fetchSubscriptionById: (Models.Subscription.Id) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionByOwnerId: (Models.User.Id) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionTeammatesByOwnerId: (Models.User.Id) -> EitherIO<Error, [Models.User]>
  public var fetchTeamInvite: (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>
  public var fetchTeamInvites: (Models.User.Id) -> EitherIO<Error, [TeamInvite]>
  public var fetchUserByGitHub: (GitHubUser.Id) -> EitherIO<Error, Models.User?>
  public var fetchUserById: (Models.User.Id) -> EitherIO<Error, Models.User?>
  public var fetchUsersSubscribedToNewsletter: (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]>
  public var fetchUsersToWelcome: (Int) -> EitherIO<Error, [Models.User]>
  public var incrementEpisodeCredits: ([Models.User.Id]) -> EitherIO<Error, [Models.User]>
  public var insertTeamInvite: (EmailAddress, Models.User.Id) -> EitherIO<Error, TeamInvite>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>
  public var redeemEpisodeCredit: (Int, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var registerUser: (GitHubUserEnvelope, EmailAddress) -> EitherIO<Error, Models.User?>
  public var removeTeammateUserIdFromSubscriptionId: (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  public var sawUser: (Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var updateStripeSubscription: (Stripe.Subscription) -> EitherIO<Error, Models.Subscription?>
  public var updateUser: (Models.User.Id, String?, EmailAddress?, [EmailSetting.Newsletter]?, Int?) -> EitherIO<Error, Prelude.Unit>
  public var upsertUser: (GitHubUserEnvelope, EmailAddress) -> EitherIO<Error, Models.User?>

  public init(
    addUserIdToSubscriptionId: @escaping (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>,
    createEnterpriseAccount: @escaping (String, EnterpriseAccount.Domain, Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>,
    createEnterpriseEmail: @escaping (EmailAddress, User.Id) -> EitherIO<Error, EnterpriseEmail?>,
    createFeedRequestEvent: @escaping (FeedRequestEvent.FeedType, String, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    createSubscription: @escaping (Stripe.Subscription, Models.User.Id) -> EitherIO<Error, Models.Subscription?>,
    deleteEnterpriseEmail: @escaping (User.Id) -> EitherIO<Error, Prelude.Unit>,
    deleteTeamInvite: @escaping (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>,
    execute: @escaping (String, [PostgresDataConvertible]) -> EitherIO<Swift.Error, [PostgresRow]>,
    fetchAdmins: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchEmailSettingsForUserId: @escaping (Models.User.Id) -> EitherIO<Error, [EmailSetting]>,
    fetchEnterpriseAccountForDomain: @escaping (EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?>,
    fetchEnterpriseAccountForSubscription: @escaping (Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>,
    fetchEnterpriseEmails: @escaping () -> EitherIO<Error, [EnterpriseEmail]>,
    fetchEpisodeCredits: @escaping (Models.User.Id) -> EitherIO<Error, [EpisodeCredit]>,
    fetchFreeEpisodeUsers: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchSubscriptionById: @escaping (Models.Subscription.Id) -> EitherIO<Error, Models.Subscription?>,
    fetchSubscriptionByOwnerId: @escaping (Models.User.Id) -> EitherIO<Error, Models.Subscription?>,
    fetchSubscriptionTeammatesByOwnerId: @escaping (Models.User.Id) -> EitherIO<Error, [Models.User]>,
    fetchTeamInvite: @escaping (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>,
    fetchTeamInvites: @escaping (Models.User.Id) -> EitherIO<Error, [TeamInvite]>,
    fetchUserByGitHub: @escaping (GitHubUser.Id) -> EitherIO<Error, Models.User?>,
    fetchUserById: @escaping (Models.User.Id) -> EitherIO<Error, Models.User?>,
    fetchUsersSubscribedToNewsletter: @escaping (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]>,
    fetchUsersToWelcome: @escaping (Int) -> EitherIO<Error, [Models.User]>,
    incrementEpisodeCredits: @escaping ([Models.User.Id]) -> EitherIO<Error, [Models.User]>,
    insertTeamInvite: @escaping (EmailAddress, Models.User.Id) -> EitherIO<Error, TeamInvite>,
    migrate: @escaping () -> EitherIO<Error, Prelude.Unit>,
    redeemEpisodeCredit: @escaping (Int, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    registerUser: @escaping (GitHubUserEnvelope, EmailAddress) -> EitherIO<Error, Models.User?>,
    removeTeammateUserIdFromSubscriptionId: @escaping (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>,
    sawUser: @escaping (Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    updateStripeSubscription: @escaping (Stripe.Subscription) -> EitherIO<Error, Models.Subscription?>,
    updateUser: @escaping (Models.User.Id, String?, EmailAddress?, [EmailSetting.Newsletter]?, Int?) -> EitherIO<Error, Prelude.Unit>,
    upsertUser: @escaping (GitHubUserEnvelope, EmailAddress) -> EitherIO<Error, Models.User?>
    ) {
    self.addUserIdToSubscriptionId = addUserIdToSubscriptionId
    self.createEnterpriseAccount = createEnterpriseAccount
    self.createEnterpriseEmail = createEnterpriseEmail
    self.createFeedRequestEvent = createFeedRequestEvent
    self.createSubscription = createSubscription
    self.deleteEnterpriseEmail = deleteEnterpriseEmail
    self.deleteTeamInvite = deleteTeamInvite
    self.execute = execute
    self.fetchAdmins = fetchAdmins
    self.fetchEmailSettingsForUserId = fetchEmailSettingsForUserId
    self.fetchEnterpriseAccountForDomain = fetchEnterpriseAccountForDomain
    self.fetchEnterpriseAccountForSubscription = fetchEnterpriseAccountForSubscription
    self.fetchEnterpriseEmails = fetchEnterpriseEmails
    self.fetchEpisodeCredits = fetchEpisodeCredits
    self.fetchFreeEpisodeUsers = fetchFreeEpisodeUsers
    self.fetchSubscriptionById = fetchSubscriptionById
    self.fetchSubscriptionByOwnerId = fetchSubscriptionByOwnerId
    self.fetchSubscriptionTeammatesByOwnerId = fetchSubscriptionTeammatesByOwnerId
    self.fetchTeamInvite = fetchTeamInvite
    self.fetchTeamInvites = fetchTeamInvites
    self.fetchUserByGitHub = fetchUserByGitHub
    self.fetchUserById = fetchUserById
    self.fetchUsersSubscribedToNewsletter = fetchUsersSubscribedToNewsletter
    self.fetchUsersToWelcome = fetchUsersToWelcome
    self.incrementEpisodeCredits = incrementEpisodeCredits
    self.insertTeamInvite = insertTeamInvite
    self.migrate = migrate
    self.redeemEpisodeCredit = redeemEpisodeCredit
    self.registerUser = registerUser
    self.removeTeammateUserIdFromSubscriptionId = removeTeammateUserIdFromSubscriptionId
    self.sawUser = sawUser
    self.updateStripeSubscription = updateStripeSubscription
    self.updateUser = updateUser
    self.upsertUser = upsertUser
  }
}

extension Client {
  public init(databaseUrl: String, eventLoopGroup: EventLoopGroup, logger: Logger) {
    guard
      let components = URLComponents(string: databaseUrl),
      let host = components.host,
      let port = components.port,
      let user = components.user
      else { fatalError("Invalid database URL: \(databaseUrl)") }

    let conn = try! PostgresConnection
      .connect(
        to: .makeAddressResolvingHost(host, port: port),
        tlsConfiguration: .forClient(certificateVerification: .none),
        serverHostname: host,
        on: eventLoopGroup.next()
      )
      .flatMap { conn in
        conn
          .authenticate(
            username: user,
            database: String(components.path.dropFirst()),
            password: components.password
          )
          .map { conn }
    }

    let client = _Client(conn: conn, logger: logger)

    self.init(
      addUserIdToSubscriptionId: client.add(userId:toSubscriptionId:),
      createEnterpriseAccount: client.createEnterpriseAccount(companyName:domain:subscriptionId:),
      createEnterpriseEmail: client.createEnterpriseEmail(email:userId:),
      createFeedRequestEvent: client.createFeedRequestEvent(type:userAgent:userId:),
      createSubscription: client.createSubscription(with:for:),
      deleteEnterpriseEmail: client.deleteEnterpriseEmail(for:),
      deleteTeamInvite: client.deleteTeamInvite(id:),
      execute: client.execute,
      fetchAdmins: client.fetchAdmins,
      fetchEmailSettingsForUserId: client.fetchEmailSettings(forUserId:),
      fetchEnterpriseAccountForDomain: client.fetchEnterpriseAccount(forDomain:),
      fetchEnterpriseAccountForSubscription: client.fetchEnterpriseAccount(forSubscriptionId:),
      fetchEnterpriseEmails: client.fetchEnterpriseEmails,
      fetchEpisodeCredits: client.fetchEpisodeCredits(for:),
      fetchFreeEpisodeUsers: client.fetchFreeEpisodeUsers,
      fetchSubscriptionById: client.fetchSubscription(id:),
      fetchSubscriptionByOwnerId: client.fetchSubscription(ownerId:),
      fetchSubscriptionTeammatesByOwnerId: client.fetchSubscriptionTeammates(ownerId:),
      fetchTeamInvite: client.fetchTeamInvite(id:),
      fetchTeamInvites: client.fetchTeamInvites(inviterId:),
      fetchUserByGitHub: client.fetchUser(byGitHubUserId:),
      fetchUserById: client.fetchUser(byUserId:),
      fetchUsersSubscribedToNewsletter: client.fetchUsersSubscribed(to:nonsubscriberOrSubscriber:),
      fetchUsersToWelcome: client.fetchUsersToWelcome(fromWeeksAgo:),
      incrementEpisodeCredits: client.incrementEpisodeCredits(for:),
      insertTeamInvite: client.insertTeamInvite(email:inviterUserId:),
      migrate: client.migrate,
      redeemEpisodeCredit: client.redeemEpisodeCredit(episodeSequence:userId:),
      registerUser: client.registerUser(withGitHubEnvelope:email:),
      removeTeammateUserIdFromSubscriptionId: client.remove(teammateUserId:fromSubscriptionId:),
      sawUser: client.sawUser(id:),
      updateStripeSubscription: client.update(stripeSubscription:),
      updateUser: client.updateUser(withId:name:email:emailSettings:episodeCreditCount:),
      upsertUser: client.upsertUser(withGitHubEnvelope:email:)
    )
  }
}

private struct _Client {
  let conn: EventLoopFuture<PostgresConnection>
  let logger: Logger

  func add(
    userId: Models.User.Id,
    toSubscriptionId subscriptionId: Models.Subscription.Id
    ) -> EitherIO<Error, Prelude.Unit> {

    return self.execute(
      """
      UPDATE "users"
      SET "subscription_id" = $1
      WHERE "users"."id" = $2
      """,
      [
        subscriptionId.rawValue.uuidString,
        userId.rawValue.uuidString,
        ]
      )
      .map(const(unit))
  }

  func createEnterpriseAccount(
    companyName: String,
    domain: EnterpriseAccount.Domain,
    subscriptionId: Models.Subscription.Id
    ) -> EitherIO<Error, EnterpriseAccount?> {

    return self.firstRow(
      """
      INSERT INTO "enterprise_accounts"
      ("company_name", "domain", "subscription_id")
      VALUES
      ($1, $2, $3)
      RETURNING *
      """, [
        companyName,
        domain.rawValue,
        subscriptionId.rawValue
      ])
  }

  func createEnterpriseEmail(email: EmailAddress, userId: User.Id) -> EitherIO<Error, EnterpriseEmail?> {
    return self.firstRow(
      """
      INSERT INTO "enterprise_emails"
      ("email", "user_id")
      VALUES
      ($1, $2)
      RETURNING *
      """, [
        email.rawValue,
        userId.rawValue
      ])
  }

  func createFeedRequestEvent(
    type: FeedRequestEvent.FeedType,
    userAgent: String,
    userId: Models.User.Id
    ) -> EitherIO<Error, Prelude.Unit> {

    return self.execute(
      """
      INSERT INTO "feed_request_events"
      ("type", "user_agent", "user_id")
      VALUES
      ($1, $2, $3)
      ON CONFLICT ("type", "user_agent", "user_id") DO UPDATE
      SET "count" = "feed_request_events"."count" + 1
      """,
      [
        type.rawValue,
        userAgent,
        userId.rawValue
      ]
      )
      .map(const(unit))
  }

  func createSubscription(
    with stripeSubscription: Stripe.Subscription, for userId: Models.User.Id
    )
    -> EitherIO<Error, Models.Subscription?> {

      let subscription: EitherIO<Error, Models.Subscription?> = self.firstRow(
        """
        INSERT INTO "subscriptions" ("stripe_subscription_id", "stripe_subscription_status", "user_id")
        VALUES ($1, $2, $3)
        RETURNING *
        """,[
        stripeSubscription.id.rawValue,
        stripeSubscription.status.rawValue,
        userId.rawValue
        ])

      return subscription.flatMap { subscription in
        self.execute(
          """
          UPDATE "users"
          SET "subscription_id" = $1
          WHERE "users"."id" = $2
          """,
          [
            subscription?.id.rawValue,
            subscription?.userId.rawValue
          ]
        )
        .map(const(subscription))
      }
  }

  func update(stripeSubscription: Stripe.Subscription) -> EitherIO<Error, Models.Subscription?> {
    return self.firstRow(
      """
    UPDATE "subscriptions"
    SET "stripe_subscription_status" = $1
    WHERE "subscriptions"."stripe_subscription_id" = $2
    RETURNING "id", "stripe_subscription_id", "stripe_subscription_status", "user_id"
    """,
      [
        stripeSubscription.status.rawValue,
        stripeSubscription.id.rawValue
      ]
    )
  }

  func remove(
    teammateUserId: Models.User.Id,
    fromSubscriptionId subscriptionId: Models.Subscription.Id
    ) -> EitherIO<Error, Prelude.Unit> {
    return self.execute(
      """
    UPDATE "users"
    SET "subscription_id" = NULL
    WHERE "users"."id" = $1
    AND "users"."subscription_id" = $2
    """,
      [
        teammateUserId.rawValue,
        subscriptionId.rawValue
      ]
      )
      .map(const(unit))
  }

  func fetchSubscription(id: Models.Subscription.Id) -> EitherIO<Error, Models.Subscription?> {
    return self.firstRow(
      """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
      [id.rawValue]
    )
  }

  func fetchSubscription(ownerId: Models.User.Id) -> EitherIO<Error, Models.Subscription?> {
    return self.firstRow(
      """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "user_id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
      [ownerId.rawValue]
    )
  }

  func fetchSubscriptionTeammates(ownerId: Models.User.Id) -> EitherIO<Error, [Models.User]> {
    return self.rows(
      """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "users"
    INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
    WHERE "subscriptions"."user_id" = $1
    """,
      [ownerId.rawValue]
    )
  }

  func sawUser(
    id userId: Models.User.Id
    ) -> EitherIO<Error, Prelude.Unit> {

    return self.execute(
      """
    UPDATE "users"
    SET "updated_at" = NOW()
    WHERE "id" = $1
    """,
      [userId.rawValue]
      )
      .map(const(unit))
  }

  func updateUser(
    withId userId: Models.User.Id,
    name: String?,
    email: EmailAddress?,
    emailSettings: [EmailSetting.Newsletter]?,
    episodeCreditCount: Int?
    ) -> EitherIO<Error, Prelude.Unit> {

    return self.execute(
      """
    UPDATE "users"
    SET "name" = COALESCE($1, "name"),
        "email" = COALESCE($2, "email"),
        "episode_credit_count" = COALESCE($3, "episode_credit_count")
    WHERE "id" = $4
    """,
      [
        name,
        email?.rawValue,
        episodeCreditCount,
        userId.rawValue
      ]
      )
      .flatMap(const(updateEmailSettings(settings: emailSettings, forUserId: userId)))
  }

  // TODO: This should return a non-optional user
  func registerUser(
    withGitHubEnvelope envelope: GitHubUserEnvelope,
    email: EmailAddress
    ) -> EitherIO<Error, Models.User?> {

    return upsertUser(withGitHubEnvelope: envelope, email: email)
      .flatMap { optionalUser in
        guard let user = optionalUser else { return pure(optionalUser) }

        return self.updateEmailSettings(settings: EmailSetting.Newsletter.allNewsletters, forUserId: user.id)
          .map(const(optionalUser))
    }
  }

  func updateEmailSettings(
    settings: [EmailSetting.Newsletter]?,
    forUserId userId: Models.User.Id
    )
    -> EitherIO<Error, Prelude.Unit> {

      guard let settings = settings else { return pure(unit) }

      let deleteEmailSettings = self.execute(
        """
      DELETE FROM "email_settings"
      WHERE "user_id" = $1
      """,
        [userId.rawValue.uuidString]
        )
        .map(const(unit))

      let updateEmailSettings = sequence(
        settings.map { type in
          self.execute(
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
  func upsertUser(
    withGitHubEnvelope envelope: GitHubUserEnvelope,
    email: EmailAddress
    ) -> EitherIO<Error, Models.User?> {

    return self.execute(
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
      .flatMap { _ in self.fetchUser(byGitHubUserId: envelope.gitHubUser.id) }
  }

  func fetchEnterpriseAccount(forDomain domain: EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?> {
    return self.firstRow(
      """
      SELECT "company_name", "domain", "id", "subscription_id"
      FROM "enterprise_accounts"
      WHERE "domain" = $1
      LIMIT 1
      """,
      [domain.rawValue]
    )
  }

  func fetchEnterpriseAccount(forSubscriptionId subscriptionId: Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?> {
    return self.firstRow(
      """
      SELECT "company_name", "domain", "id", "subscription_id"
      FROM "enterprise_accounts"
      WHERE "subscription_id" = $1
      LIMIT 1
      """,
      [subscriptionId.rawValue]
    )
  }

  func fetchEnterpriseEmails() -> EitherIO<Error, [EnterpriseEmail]> {
    return self.rows("""
      SELECT *
      FROM "enterprise_emails"
      """)
  }

  func fetchUser(byUserId id: Models.User.Id) -> EitherIO<Error, Models.User?> {
    return self.firstRow(
      """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id",
           "rss_salt"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
      [id.rawValue]
    )
  }

  func fetchUsersSubscribed(to newsletter: EmailSetting.Newsletter, nonsubscriberOrSubscriber: Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]> {
    let condition: String
    switch nonsubscriberOrSubscriber {
    case .none:
      condition = ""
    case .some(.left):
      condition = " AND \"users\".\"subscription_id\" IS NULL"
    case .some(.right):
      condition = " AND \"users\".\"subscription_id\" IS NOT NULL"
    }
    return self.rows(
      """
      SELECT "users"."email",
      "users"."episode_credit_count",
      "users"."github_user_id",
      "users"."github_access_token",
      "users"."id",
      "users"."is_admin",
      "users"."name",
      "users"."subscription_id",
      "users"."rss_salt"
      FROM "email_settings" LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
      WHERE "email_settings"."newsletter" = $1\(condition)
      """,
      [newsletter.rawValue]
    )
  }

  func fetchUsersToWelcome(fromWeeksAgo weeksAgo: Int) -> EitherIO<Error, [Models.User]> {
    let daysAgo = weeksAgo * 7
    return self.rows(
      """
      SELECT
      "users"."email",
      "users"."episode_credit_count",
      "users"."github_user_id",
      "users"."github_access_token",
      "users"."id",
      "users"."is_admin",
      "users"."name",
      "users"."subscription_id",
      "users"."rss_salt"
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
      [EmailSetting.Newsletter.welcomeEmails.rawValue]
    )
  }

  func incrementEpisodeCredits(for userIds: [Models.User.Id]) -> EitherIO<Error, [Models.User]> {
    guard !userIds.isEmpty else { return pure([]) }
    return self.rows(
      """
      UPDATE "users"
      SET "episode_credit_count" = "episode_credit_count" + 1
      WHERE "id" IN (\(userIds.map { "'\($0.rawValue.uuidString)'" }.joined(separator: ",")))
      RETURNING *
      """
    )
  }

  func fetchUser(byGitHubUserId userId: GitHubUser.Id) -> EitherIO<Error, Models.User?> {
    return self.firstRow(
      """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id",
           "rss_salt"
    FROM "users"
    WHERE "github_user_id" = $1
    LIMIT 1
    """,
      [userId.rawValue]
    )
  }

  func fetchTeamInvite(id: TeamInvite.Id) -> EitherIO<Error, TeamInvite?> {
    return self.firstRow(
      """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "id" = $1
    LIMIT 1
    """,
      [id.rawValue]
    )
  }

  func deleteEnterpriseEmail(for userId: User.Id) -> EitherIO<Error, Prelude.Unit> {
    return self.execute("""
      DELETE FROM "enterprise_emails"
      WHERE "user_id" = $1
      """, [
        userId.rawValue
      ])
      .map(const(unit))
  }

  func deleteTeamInvite(id: TeamInvite.Id) -> EitherIO<Error, Prelude.Unit> {
    return self.execute(
      """
    DELETE FROM "team_invites"
    WHERE "id" = $1
    """,
      [id.rawValue]
      )
      .map(const(unit))
  }

  func fetchTeamInvites(inviterId: Models.User.Id) -> EitherIO<Error, [Models.TeamInvite]> {
    return self.rows(
      """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "inviter_user_id" = $1
    """,
      [inviterId.rawValue]
    )
  }

  func fetchAdmins() -> EitherIO<Error, [Models.User]> {
    return self.rows(
      """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "users"
    WHERE "users"."is_admin" = TRUE
    """,
      []
    )
  }

  func insertTeamInvite(
    email: EmailAddress,
    inviterUserId: Models.User.Id
    ) -> EitherIO<Error, TeamInvite> {

    return self.execute(
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
      .flatMap { rows -> EitherIO<Error, TeamInvite> in
        (rows.first?.column("id")?.uuid)
          .map(
            TeamInvite.Id.init
              >>> self.fetchTeamInvite
              >>> mapExcept(requireSome)
          )
          ?? throwE(unit)
    }
  }

  func fetchEmailSettings(forUserId userId: Models.User.Id) -> EitherIO<Error, [EmailSetting]> {

    return self.rows(
      """
    SELECT "newsletter", "user_id"
    FROM "email_settings"
    WHERE "user_id" = $1
    """,
      [userId.rawValue]
    )
  }

  func fetchEpisodeCredits(for userId: Models.User.Id) -> EitherIO<Error, [EpisodeCredit]> {
    return self.rows(
      """
    SELECT "episode_sequence", "user_id"
    FROM "episode_credits"
    WHERE "user_id" = $1
    """,
      [userId.rawValue]
    )
  }

  func fetchFreeEpisodeUsers() -> EitherIO<Error, [Models.User]> {
    return self.rows(
      """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
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
        EmailSetting.Newsletter.newEpisode.rawValue
      ]
    )
  }

  func redeemEpisodeCredit(episodeSequence: Int, userId: Models.User.Id) -> EitherIO<Error, Prelude.Unit> {

    return self.execute(
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

  func migrate() -> EitherIO<Error, Prelude.Unit> {
    return self.execute(
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
      .flatMap(const(execute(
        """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "rss_salt" uuid DEFAULT uuid_generate_v1mc() NOT NULL
      """
      )))
      .flatMap(const(execute(
        """
      CREATE TABLE IF NOT EXISTS "feed_request_events" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "type" character varying NOT NULL,
        "user_agent" character varying NOT NULL,
        "user_id" uuid REFERENCES "users" ("id"),
        "count" integer NOT NULL DEFAULT 1,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
      )
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_feed_request_events_on_type_user_agent_user_id"
      ON "feed_request_events" ("type", "user_agent", "user_id")
      """
      )))
      .flatMap(const(execute(
        """
      ALTER TABLE "feed_request_events"
      ADD COLUMN IF NOT EXISTS
      "updated_at" timestamp without time zone DEFAULT NOW() NOT NULL
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_email_settings_on_newsletter_user_id"
      ON "email_settings" ("newsletter", "user_id")
      """
      )))
      .flatMap(const(execute(
        """
      CREATE OR REPLACE FUNCTION update_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW."updated_at" = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE PLPGSQL;
      """
      )))
      .flatMap(const(execute(
        """
      DO $$
      DECLARE
        "table" text;
      BEGIN
        FOR "table" IN
          SELECT "table_name" FROM "information_schema"."columns"
          WHERE column_name = 'updated_at'
        LOOP
          IF NOT EXISTS (
            SELECT 1 FROM "information_schema"."triggers"
            WHERE "trigger_name" = 'update_updated_at_' || "table"
          ) THEN
            EXECUTE format(
              '
              CREATE TRIGGER "update_updated_at_%I"
              BEFORE UPDATE ON "%I"
              FOR EACH ROW EXECUTE PROCEDURE update_updated_at()
              ',
              "table", "table"
            );
          END IF;
        END LOOP;
      END;
      $$ LANGUAGE PLPGSQL;
      """
      )))
      .flatMap(const(execute(
        """
      CREATE TABLE IF NOT EXISTS "enterprise_accounts" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "company_name" character varying NOT NULL,
        "domain" character varying NOT NULL,
        "subscription_id" uuid REFERENCES "subscriptions" ("id") NOT NULL,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      )
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_domain"
      ON "enterprise_accounts" ("domain")
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_accounts_on_subscription_id"
      ON "enterprise_accounts" ("subscription_id")
      """
      )))
      .flatMap(const(execute(
        """
      CREATE TABLE IF NOT EXISTS "enterprise_emails" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "email" character varying NOT NULL,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      )
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_email"
      ON "enterprise_emails" (lower("email"))
      """
      )))
      .flatMap(const(execute(
        """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_enterprise_emails_on_user_id"
      ON "enterprise_emails" ("user_id")
      """
      )))
      .map(const(unit))
  }

  func rows<T: Decodable>(
    _ query: String,
    _ binds: [PostgresDataConvertible] = []
    ) -> EitherIO<Swift.Error, [T]> {

    return self.execute(query, binds)
      .flatMap { rows in
        .wrap { try rows.map { try T(from: RowDecoder(row: $0)) } }
    }
  }

  func firstRow<T: Decodable>(
    _ query: String,
    _ binds: [PostgresDataConvertible] = []
    ) -> EitherIO<Swift.Error, T?> {

    return self.rows(query, binds)
      .map(^\.first)
  }

  func execute(
    _ query: String,
    _ binds: [PostgresDataConvertible] = []
    ) -> EitherIO<Swift.Error, [PostgresRow]> {

    return EitherIO<Swift.Error, [PostgresRow]>.wrap {
      try self.conn
        .flatMap { $0.query(query, binds.map(^\.postgresData!)) }
        .wait()
    }
  }
}

public enum DatabaseError: Error {
  case invalidUrl
}
