import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation
import GitHub
import Logging
import Models
import PointFreePrelude
import PostgresKit
import Stripe
import Tagged

@DependencyClient
public struct Client {
  public var addUserIdToSubscriptionId:
    (Models.User.ID, Models.Subscription.ID) async throws -> Void
  public var createEnterpriseAccount:
    (String, EnterpriseAccount.Domain, Models.Subscription.ID) async throws -> EnterpriseAccount
  public var createEnterpriseEmail: (EmailAddress, User.ID) async throws -> EnterpriseEmail
  public var createFeedRequestEvent:
    (FeedRequestEvent.FeedType, String, Models.User.ID) async throws -> Void
  public var createGift: (CreateGiftRequest) async throws -> Gift
  public var createSubscription:
    (Stripe.Subscription, Models.User.ID, Bool, Models.User.ID?) async throws -> Models.Subscription
  public var deleteEnterpriseEmail: (User.ID) async throws -> Void
  public var deleteTeamInvite: (TeamInvite.ID) async throws -> Void
  public var execute: (SQLQueryString) async throws -> [SQLRow]
  public var fetchAdmins: () async throws -> [Models.User]
  public var fetchEmailSettingsForUserId: (Models.User.ID) async throws -> [EmailSetting]
  public var fetchEnterpriseAccountForDomain:
    (EnterpriseAccount.Domain) async throws -> EnterpriseAccount
  public var fetchEnterpriseAccountForSubscription:
    (Models.Subscription.ID) async throws -> EnterpriseAccount
  public var fetchEnterpriseEmails: () async throws -> [EnterpriseEmail]
  public var fetchEpisodeCredits: (Models.User.ID) async throws -> [EpisodeCredit]
  public var fetchEpisodeProgress: (User.ID, Episode.Sequence) async throws -> EpisodeProgress
  public var fetchEpisodeProgresses: (User.ID) async throws -> [EpisodeProgress]
  public var fetchFreeEpisodeUsers: () async throws -> [Models.User]
  public var fetchGift: (Gift.ID) async throws -> Gift
  public var fetchGiftByStripePaymentIntentId: (PaymentIntent.ID) async throws -> Gift
  public var fetchGiftsToDeliver: () async throws -> [Gift]
  public var fetchLivestreams: () async throws -> [Livestream]
  public var fetchSubscriptionById: (Models.Subscription.ID) async throws -> Models.Subscription
  public var fetchSubscriptionByOwnerId: (Models.User.ID) async throws -> Models.Subscription
  public var fetchSubscriptionByTeamInviteCode:
    (Models.Subscription.TeamInviteCode) async throws -> Models.Subscription
  public var fetchSubscriptionTeammatesByOwnerId: (Models.User.ID) async throws -> [Models.User]
  public var fetchTeamInvite: (TeamInvite.ID) async throws -> TeamInvite
  public var fetchTeamInvites: (Models.User.ID) async throws -> [TeamInvite]
  public var fetchUserByGitHub: (GitHubUser.ID) async throws -> Models.User
  public var fetchUserById: (Models.User.ID) async throws -> Models.User
  public var fetchUserByReferralCode: (Models.User.ReferralCode) async throws -> Models.User
  public var fetchUserByRssSalt: (Models.User.RssSalt) async throws -> Models.User
  public var fetchUsersSubscribedToNewsletter:
    (EmailSetting.Newsletter, Models.User.SubscriberState?) async throws -> [Models.User]
  public var fetchUsersToWelcome: (Int) async throws -> [Models.User]
  public var incrementEpisodeCredits: ([Models.User.ID]) async throws -> [Models.User]
  public var insertTeamInvite: (EmailAddress, Models.User.ID) async throws -> TeamInvite
  public var migrate: () async throws -> Void
  public var redeemEpisodeCredit: (Episode.Sequence, Models.User.ID) async throws -> Void
  public var regenerateTeamInviteCode: (Models.Subscription.ID) async throws -> Void
  public var removeTeammateUserIdFromSubscriptionId:
    (Models.User.ID, Models.Subscription.ID) async throws -> Void
  public var sawUser: (Models.User.ID) async throws -> Void
  public var updateEmailSettings: ([EmailSetting.Newsletter]?, Models.User.ID) async throws -> Void
  public var updateEpisodeProgress:
    (Episode.Sequence, Int, Bool, Models.User.ID) async throws -> Void
  public var updateGift: (Gift.ID, Stripe.Subscription.ID) async throws -> Gift
  public var updateGiftStatus:
    (Gift.ID, Stripe.PaymentIntent.Status, _ delivered: Bool) async throws -> Gift
  public var updateStripeSubscription: (Stripe.Subscription) async throws -> Models.Subscription
  public var updateUser:
    (Models.User.ID, String?, EmailAddress?, Int?, Models.User.RssSalt?) async throws -> Void
  public var upsertUser:
    (GitHubUserEnvelope, EmailAddress, @escaping () -> Date) async throws ->
      Models.User

  public func fetchSubscription(user: Models.User) async throws -> Models.Subscription {
    do {
      return try await self.fetchSubscriptionById(user.subscriptionId.unwrap())
    } catch {
      return try await self.fetchSubscriptionByOwnerId(user.id)
    }
  }

  public func registerUser(
    withGitHubEnvelope envelope: GitHubUserEnvelope,
    email: EmailAddress,
    now: @escaping () -> Date
  ) async throws -> User {
    let user = try await self.upsertUser(envelope, email, now)
    try await self.updateEmailSettings(EmailSetting.Newsletter.allNewsletters, user.id)
    return user
  }

  public func updateUser(
    id: Models.User.ID,
    name: String? = nil,
    email: EmailAddress? = nil,
    emailSettings: [EmailSetting.Newsletter]? = nil,
    episodeCreditCount: Int? = nil,
    rssSalt: Models.User.RssSalt? = nil
  ) async throws {
    try await self.updateUser(id, name, email, episodeCreditCount, rssSalt)
    try await self.updateEmailSettings(emailSettings, id)
  }

  public struct CreateGiftRequest: Equatable {
    public var deliverAt: Date?
    public var fromEmail: EmailAddress
    public var fromName: String
    public var message: String
    public var monthsFree: Int
    public var stripePaymentIntentId: PaymentIntent.ID
    public var toEmail: EmailAddress
    public var toName: String

    public init(
      deliverAt: Date?,
      fromEmail: EmailAddress,
      fromName: String,
      message: String,
      monthsFree: Int,
      stripePaymentIntentId: PaymentIntent.ID,
      toEmail: EmailAddress,
      toName: String
    ) {
      self.fromEmail = fromEmail
      self.fromName = fromName
      self.deliverAt = deliverAt
      self.message = message
      self.monthsFree = monthsFree
      self.stripePaymentIntentId = stripePaymentIntentId
      self.toEmail = toEmail
      self.toName = toName
    }
  }

  #if DEBUG
    public func resetForTesting(
      pool: EventLoopGroupConnectionPool<PostgresConnectionSource>
    ) async throws {
      let database = pool.sqlDatabase
      try await database.run("DROP SCHEMA IF EXISTS public CASCADE")
      try await database.run("CREATE SCHEMA public")
      try await database.run("GRANT ALL ON SCHEMA public TO pointfreeco")
      try await database.run("GRANT ALL ON SCHEMA public TO public")
      try await self.migrate()
      try await database.run("CREATE SEQUENCE test_uuids")
      try await database.run("CREATE SEQUENCE test_shortids")
      try await database.run(
        """
        CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
        RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      try await database.run(
        """
        CREATE OR REPLACE FUNCTION gen_shortid(table_name text, column_name text)
        RETURNS text AS $$
        BEGIN
          RETURN table_name||'-'||column_name||nextval('test_shortids')::text;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
    }
  #endif
}

extension Client: TestDependencyKey {
  public static let testValue = Self()
}

extension DependencyValues {
  public var database: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
