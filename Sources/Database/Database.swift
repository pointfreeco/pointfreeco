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
  @DependencyEndpoint(method: "addUser")
  public var addUserIdToSubscriptionId:
    (
      _ id: Models.User.ID,
      _ toSubscriptionID: Models.Subscription.ID
    ) async throws -> Void
  public var createEnterpriseAccount:
    (
      _ companyName: String,
      _ domain: EnterpriseAccount.Domain,
      _ subscriptionID: Models.Subscription.ID
    ) async throws -> EnterpriseAccount
  public var createEnterpriseEmail:
    (
      _ emailAddress: EmailAddress,
      _ userID: User.ID
    ) async throws -> EnterpriseEmail
  public var createFeedRequestEvent:
    (
      _ feedType: FeedRequestEvent.FeedType,
      _ userAgent: String,
      _ userID: Models.User.ID
    ) async throws -> Void
  public var createGift:
    (
      _ deliverAt: Date?,
      _ fromEmail: EmailAddress,
      _ fromName: String,
      _ message: String,
      _ monthsFree: Int,
      _ stripePaymentIntentId: PaymentIntent.ID,
      _ toEmail: EmailAddress,
      _ toName: String
    ) async throws -> Gift
  public var createSubscription:
    (
      _ subscription: Stripe.Subscription,
      _ userID: Models.User.ID,
      _ isOwnerTakingSeat: Bool,
      _ referrerID: Models.User.ID?
    ) async throws -> Models.Subscription
  public var deleteEnterpriseEmail: (_ userID: User.ID) async throws -> Void
  public var deleteTeamInvite: (_ id: TeamInvite.ID) async throws -> Void
  public var execute: (_ sql: SQLQueryString) async throws -> [SQLRow]
  public var fetchAdmins: () async throws -> [Models.User]
  @DependencyEndpoint(method: "fetchEmailSettings")
  public var fetchEmailSettingsForUserId: (_ userID: Models.User.ID) async throws -> [EmailSetting]
  @DependencyEndpoint(method: "fetchEnterpriseAccount")
  public var fetchEnterpriseAccountForDomain:
    (_ forDomain: EnterpriseAccount.Domain) async throws -> EnterpriseAccount
  @DependencyEndpoint(method: "fetchEnterpriseAccount")
  public var fetchEnterpriseAccountForSubscription:
    (_ forSubscriptionID: Models.Subscription.ID) async throws -> EnterpriseAccount
  public var fetchEnterpriseEmails: () async throws -> [EnterpriseEmail]
  public var fetchEpisodeCredits: (_ userID: Models.User.ID) async throws -> [EpisodeCredit]
  public var fetchEpisodeProgress:
    (
      _ userID: User.ID,
      _ sequence: Episode.Sequence
    ) async throws -> EpisodeProgress
  public var fetchEpisodeProgresses: (_ userID: User.ID) async throws -> [EpisodeProgress]
  public var fetchFreeEpisodeUsers: () async throws -> [Models.User]
  @DependencyEndpoint(method: "fetchGift")
  public var fetchGift: (_ id: Gift.ID) async throws -> Gift
  @DependencyEndpoint(method: "fetchGift")
  public var fetchGiftByStripePaymentIntentId:
    (_ paymentIntentID: PaymentIntent.ID) async throws -> Gift
  public var fetchGiftsToDeliver: () async throws -> [Gift]
  public var fetchLivestreams: () async throws -> [Livestream]
  @DependencyEndpoint(method: "fetchSubscription")
  public var fetchSubscriptionById:
    (_ id: Models.Subscription.ID) async throws -> Models.Subscription
  @DependencyEndpoint(method: "fetchSubscription")
  public var fetchSubscriptionByOwnerId:
    (_ ownerID: Models.User.ID) async throws -> Models.Subscription
  @DependencyEndpoint(method: "fetchSubscription")
  public var fetchSubscriptionByTeamInviteCode:
    (_ teamInviteCode: Models.Subscription.TeamInviteCode) async throws -> Models.Subscription
  @DependencyEndpoint(method: "fetchSubscriptionTeammates")
  public var fetchSubscriptionTeammatesByOwnerId:
    (_ ownerID: Models.User.ID) async throws -> [Models.User]
  public var fetchTeamInvite: (_ id: TeamInvite.ID) async throws -> TeamInvite
  public var fetchTeamInvites: (_ inviterID: Models.User.ID) async throws -> [TeamInvite]
  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserByGitHub: (_ gitHubID: GitHubUser.ID) async throws -> Models.User
  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserById: (_ id: Models.User.ID) async throws -> Models.User
  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserByReferralCode:
    (_ referralCode: Models.User.ReferralCode) async throws -> Models.User
  @DependencyEndpoint(method: "fetchUser")
  public var fetchUserByRssSalt: (_ rssSalt: Models.User.RssSalt) async throws -> Models.User
  @DependencyEndpoint(method: "fetchUsers")
  public var fetchUsersSubscribedToNewsletter:
    (
      _ subscribedToNewsletter: EmailSetting.Newsletter,
      _ subscriberState: Models.User.SubscriberState?
    ) async throws -> [Models.User]
  public var fetchUsersToWelcome: (_ registeredWeeksAgo: Int) async throws -> [Models.User]
  public var incrementEpisodeCredits: (_ userIDs: [Models.User.ID]) async throws -> [Models.User]
  public var insertTeamInvite:
    (
      _ emailAddress: EmailAddress,
      _ inviterUserID: Models.User.ID
    ) async throws -> TeamInvite
  public var migrate: () async throws -> Void
  public var redeemEpisodeCredit:
    (_ sequence: Episode.Sequence, _ userID: Models.User.ID) async throws -> Void
  public var regenerateTeamInviteCode:
    (_ subscriptionID: Models.Subscription.ID) async throws -> Void

  @DependencyEndpoint(method: "removeTeammate")
  public var removeTeammateUserIdFromSubscriptionId:
    (
      _ userID: Models.User.ID,
      _ fromSubscriptionID: Models.Subscription.ID
    ) async throws -> Void
  public var sawUser: (_ id: Models.User.ID) async throws -> Void
  public var updateEmailSettings:
    (_ newsletters: [EmailSetting.Newsletter]?, _ userID: Models.User.ID) async throws -> Void
  public var updateEpisodeProgress:
    (_ sequence: Episode.Sequence, _ progress: Int, _ isFinished: Bool, _ userID: Models.User.ID)
      async throws -> Void
  public var updateGift:
    (_ id: Gift.ID, _ subscriptionID: Stripe.Subscription.ID) async throws -> Gift
  public var updateGiftStatus:
    (_ id: Gift.ID, _ status: Stripe.PaymentIntent.Status, _ delivered: Bool) async throws -> Gift
  public var updateStripeSubscription: (Stripe.Subscription) async throws -> Models.Subscription
  public var updateUser:
    (
      _ id: Models.User.ID,
      _ name: String?,
      _ emailAddress: EmailAddress?,
      _ episodeCreditCount: Int?,
      _ rssSalt: Models.User.RssSalt?
    ) async throws -> Void
  public var upsertUser:
    (
      _ gitHubUserEnvelope: GitHubUserEnvelope,
      _ emailAddress: EmailAddress,
      _ date: @escaping () -> Date
    ) async throws -> Models.User

  public func fetchSubscription(user: Models.User) async throws -> Models.Subscription {
    do {
      return try await self.fetchSubscription(id: user.subscriptionId.unwrap())
    } catch {
      return try await self.fetchSubscription(ownerID: user.id)
    }
  }

  public func registerUser(
    withGitHubEnvelope envelope: GitHubUserEnvelope,
    email: EmailAddress,
    now: @escaping () -> Date
  ) async throws -> User {
    let user = try await self.upsertUser(
      gitHubUserEnvelope: envelope,
      emailAddress: email,
      date: now
    )
    try await self.updateEmailSettings(
      newsletters: EmailSetting.Newsletter.allNewsletters,
      userID: user.id
    )
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
    try await self.updateUser(
      id: id,
      name: name,
      emailAddress: email,
      episodeCreditCount: episodeCreditCount,
      rssSalt: rssSalt
    )
    try await self.updateEmailSettings(newsletters: emailSettings, userID: id)
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
