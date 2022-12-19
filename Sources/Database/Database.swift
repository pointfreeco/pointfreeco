import Either
import EmailAddress
import Foundation
import GitHub
import Logging
import Models
import PointFreePrelude
import PostgresKit
import Prelude
import Stripe
import Tagged

public struct Client {
  public var addUserIdToSubscriptionId:
    (Models.User.ID, Models.Subscription.ID) -> EitherIO<Error, Prelude.Unit>
  public var createEnterpriseAccount:
    (String, EnterpriseAccount.Domain, Models.Subscription.ID) -> EitherIO<
      Error, EnterpriseAccount?
    >
  public var createEnterpriseEmail: (EmailAddress, User.ID) -> EitherIO<Error, EnterpriseEmail?>
  public var createFeedRequestEvent:
    (FeedRequestEvent.FeedType, String, Models.User.ID) -> EitherIO<Error, Prelude.Unit>
  public var createGift: (CreateGiftRequest) -> EitherIO<Error, Gift>
  public var createSubscription:
    (Stripe.Subscription, Models.User.ID, Bool, Models.User.ID?) -> EitherIO<
      Error, Models.Subscription?
    >
  public var deleteEnterpriseEmail: (User.ID) -> EitherIO<Error, Prelude.Unit>
  public var deleteTeamInvite: (TeamInvite.ID) -> EitherIO<Error, Prelude.Unit>
  public var execute: (SQLQueryString) -> EitherIO<Swift.Error, [SQLRow]>
  public var fetchAdmins: () -> EitherIO<Error, [Models.User]>
  public var fetchEmailSettingsForUserId: (Models.User.ID) -> EitherIO<Error, [EmailSetting]>
  public var fetchEnterpriseAccountForDomain:
    (EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseAccountForSubscription:
    (Models.Subscription.ID) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseEmails: () -> EitherIO<Error, [EnterpriseEmail]>
  public var fetchEpisodeCredits: (Models.User.ID) -> EitherIO<Error, [EpisodeCredit]>
  public var fetchEpisodeProgress: (User.ID, Episode.Sequence) -> EitherIO<Error, Int?>
  public var fetchFreeEpisodeUsers: () -> EitherIO<Error, [Models.User]>
  public var fetchGift: (Gift.ID) -> EitherIO<Error, Gift>
  public var fetchGiftByStripePaymentIntentId: (PaymentIntent.ID) -> EitherIO<Error, Gift>
  public var fetchGiftsToDeliver: () -> EitherIO<Error, [Gift]>
  public var fetchSubscriptionById:
    (Models.Subscription.ID) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionByOwnerId: (Models.User.ID) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionTeammatesByOwnerId: (Models.User.ID) -> EitherIO<Error, [Models.User]>
  public var fetchTeamInvite: (TeamInvite.ID) -> EitherIO<Error, TeamInvite?>
  public var fetchTeamInvites: (Models.User.ID) -> EitherIO<Error, [TeamInvite]>
  public var fetchUserByGitHub: (GitHubUser.ID) -> EitherIO<Error, Models.User?>
  public var fetchUserById: (Models.User.ID) -> EitherIO<Error, Models.User?>
  public var fetchUserByReferralCode: (Models.User.ReferralCode) -> EitherIO<Error, Models.User?>
  public var fetchUserByRssSalt: (Models.User.RssSalt) -> EitherIO<Error, Models.User?>
  public var fetchUsersSubscribedToNewsletter:
    (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]>
  public var fetchUsersToWelcome: (Int) -> EitherIO<Error, [Models.User]>
  public var incrementEpisodeCredits: ([Models.User.ID]) -> EitherIO<Error, [Models.User]>
  public var insertTeamInvite: (EmailAddress, Models.User.ID) -> EitherIO<Error, TeamInvite>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>
  public var redeemEpisodeCredit:
    (Episode.Sequence, Models.User.ID) -> EitherIO<Error, Prelude.Unit>
  public var removeTeammateUserIdFromSubscriptionId:
    (Models.User.ID, Models.Subscription.ID) -> EitherIO<Error, Prelude.Unit>
  public var sawUser: (Models.User.ID) -> EitherIO<Error, Prelude.Unit>
  public var updateEmailSettings:
    ([EmailSetting.Newsletter]?, Models.User.ID) -> EitherIO<Error, Prelude.Unit>
  public var updateEpisodeProgress:
    (Episode.Sequence, Int, Models.User.ID) -> EitherIO<Error, Prelude.Unit>
  public var updateGift: (Gift.ID, Stripe.Subscription.ID) -> EitherIO<Error, Gift>
  public var updateGiftStatus:
    (Gift.ID, Stripe.PaymentIntent.Status, _ delivered: Bool) -> EitherIO<Error, Gift>
  public var updateStripeSubscription:
    (Stripe.Subscription) -> EitherIO<Error, Models.Subscription?>
  public var updateUser:
    (Models.User.ID, String?, EmailAddress?, Int?, Models.User.RssSalt?) -> EitherIO<
      Error, Prelude.Unit
    >
  public var upsertUser:
    (GitHubUserEnvelope, EmailAddress, () -> Date) -> EitherIO<Error, Models.User?>

  public init(
    addUserIdToSubscriptionId: @escaping (Models.User.ID, Models.Subscription.ID) -> EitherIO<
      Error, Prelude.Unit
    >,
    createEnterpriseAccount: @escaping (String, EnterpriseAccount.Domain, Models.Subscription.ID) ->
      EitherIO<Error, EnterpriseAccount?>,
    createEnterpriseEmail: @escaping (EmailAddress, User.ID) -> EitherIO<Error, EnterpriseEmail?>,
    createFeedRequestEvent: @escaping (FeedRequestEvent.FeedType, String, Models.User.ID) ->
      EitherIO<Error, Prelude.Unit>,
    createGift: @escaping (CreateGiftRequest) -> EitherIO<Error, Gift>,
    createSubscription: @escaping (Stripe.Subscription, Models.User.ID, Bool, Models.User.ID?) ->
      EitherIO<Error, Models.Subscription?>,
    deleteEnterpriseEmail: @escaping (User.ID) -> EitherIO<Error, Prelude.Unit>,
    deleteTeamInvite: @escaping (TeamInvite.ID) -> EitherIO<Error, Prelude.Unit>,
    execute: @escaping (SQLQueryString) -> EitherIO<Swift.Error, [SQLRow]>,
    fetchAdmins: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchEmailSettingsForUserId: @escaping (Models.User.ID) -> EitherIO<Error, [EmailSetting]>,
    fetchEnterpriseAccountForDomain: @escaping (EnterpriseAccount.Domain) -> EitherIO<
      Error, EnterpriseAccount?
    >,
    fetchEnterpriseAccountForSubscription: @escaping (Models.Subscription.ID) -> EitherIO<
      Error, EnterpriseAccount?
    >,
    fetchEnterpriseEmails: @escaping () -> EitherIO<Error, [EnterpriseEmail]>,
    fetchEpisodeCredits: @escaping (Models.User.ID) -> EitherIO<Error, [EpisodeCredit]>,
    fetchEpisodeProgress: @escaping (User.ID, Episode.Sequence) -> EitherIO<Error, Int?>,
    fetchFreeEpisodeUsers: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchGift: @escaping (Gift.ID) -> EitherIO<Error, Gift>,
    fetchGiftByStripePaymentIntentId: @escaping (PaymentIntent.ID) -> EitherIO<Error, Gift>,
    fetchGiftsToDeliver: @escaping () -> EitherIO<Error, [Gift]>,
    fetchSubscriptionById: @escaping (Models.Subscription.ID) -> EitherIO<
      Error, Models.Subscription?
    >,
    fetchSubscriptionByOwnerId: @escaping (Models.User.ID) -> EitherIO<Error, Models.Subscription?>,
    fetchSubscriptionTeammatesByOwnerId: @escaping (Models.User.ID) -> EitherIO<
      Error, [Models.User]
    >,
    fetchTeamInvite: @escaping (TeamInvite.ID) -> EitherIO<Error, TeamInvite?>,
    fetchTeamInvites: @escaping (Models.User.ID) -> EitherIO<Error, [TeamInvite]>,
    fetchUserByGitHub: @escaping (GitHubUser.ID) -> EitherIO<Error, Models.User?>,
    fetchUserById: @escaping (Models.User.ID) -> EitherIO<Error, Models.User?>,
    fetchUserByReferralCode: @escaping (Models.User.ReferralCode) -> EitherIO<Error, Models.User?>,
    fetchUserByRssSalt: @escaping (Models.User.RssSalt) -> EitherIO<Error, Models.User?>,
    fetchUsersSubscribedToNewsletter: @escaping (
      EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?
    ) -> EitherIO<Error, [Models.User]>,
    fetchUsersToWelcome: @escaping (Int) -> EitherIO<Error, [Models.User]>,
    incrementEpisodeCredits: @escaping ([Models.User.ID]) -> EitherIO<Error, [Models.User]>,
    insertTeamInvite: @escaping (EmailAddress, Models.User.ID) -> EitherIO<Error, TeamInvite>,
    migrate: @escaping () -> EitherIO<Error, Prelude.Unit>,
    redeemEpisodeCredit: @escaping (Episode.Sequence, Models.User.ID) -> EitherIO<
      Error, Prelude.Unit
    >,
    removeTeammateUserIdFromSubscriptionId: @escaping (Models.User.ID, Models.Subscription.ID) ->
      EitherIO<Error, Prelude.Unit>,
    sawUser: @escaping (Models.User.ID) -> EitherIO<Error, Prelude.Unit>,
    updateEmailSettings: @escaping ([EmailSetting.Newsletter]?, Models.User.ID) -> EitherIO<
      Error, Prelude.Unit
    >,
    updateEpisodeProgress: @escaping (Episode.Sequence, Int, Models.User.ID) -> EitherIO<
      Error, Prelude.Unit
    >,
    updateGift: @escaping (Gift.ID, Stripe.Subscription.ID) -> EitherIO<Error, Gift>,
    updateGiftStatus: @escaping (Gift.ID, Stripe.PaymentIntent.Status, _ delivered: Bool) ->
      EitherIO<Error, Gift>,
    updateStripeSubscription: @escaping (Stripe.Subscription) -> EitherIO<
      Error, Models.Subscription?
    >,
    updateUser: @escaping (Models.User.ID, String?, EmailAddress?, Int?, Models.User.RssSalt?) ->
      EitherIO<Error, Prelude.Unit>,
    upsertUser: @escaping (GitHubUserEnvelope, EmailAddress, () -> Date) -> EitherIO<
      Error, Models.User?
    >
  ) {
    self.addUserIdToSubscriptionId = addUserIdToSubscriptionId
    self.createEnterpriseAccount = createEnterpriseAccount
    self.createEnterpriseEmail = createEnterpriseEmail
    self.createFeedRequestEvent = createFeedRequestEvent
    self.createGift = createGift
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
    self.fetchEpisodeProgress = fetchEpisodeProgress
    self.fetchFreeEpisodeUsers = fetchFreeEpisodeUsers
    self.fetchGift = fetchGift
    self.fetchGiftByStripePaymentIntentId = fetchGiftByStripePaymentIntentId
    self.fetchGiftsToDeliver = fetchGiftsToDeliver
    self.fetchSubscriptionById = fetchSubscriptionById
    self.fetchSubscriptionByOwnerId = fetchSubscriptionByOwnerId
    self.fetchSubscriptionTeammatesByOwnerId = fetchSubscriptionTeammatesByOwnerId
    self.fetchTeamInvite = fetchTeamInvite
    self.fetchTeamInvites = fetchTeamInvites
    self.fetchUserByGitHub = fetchUserByGitHub
    self.fetchUserById = fetchUserById
    self.fetchUserByReferralCode = fetchUserByReferralCode
    self.fetchUserByRssSalt = fetchUserByRssSalt
    self.fetchUsersSubscribedToNewsletter = fetchUsersSubscribedToNewsletter
    self.fetchUsersToWelcome = fetchUsersToWelcome
    self.incrementEpisodeCredits = incrementEpisodeCredits
    self.insertTeamInvite = insertTeamInvite
    self.migrate = migrate
    self.redeemEpisodeCredit = redeemEpisodeCredit
    self.removeTeammateUserIdFromSubscriptionId = removeTeammateUserIdFromSubscriptionId
    self.sawUser = sawUser
    self.updateEmailSettings = updateEmailSettings
    self.updateEpisodeProgress = updateEpisodeProgress
    self.updateGift = updateGift
    self.updateGiftStatus = updateGiftStatus
    self.updateStripeSubscription = updateStripeSubscription
    self.updateUser = updateUser
    self.upsertUser = upsertUser
  }

  public func registerUser(
    withGitHubEnvelope envelope: GitHubUserEnvelope,
    email: EmailAddress,
    now: () -> Date
  ) -> EitherIO<Error, Models.User?> {

    self.upsertUser(envelope, email, now)
      .flatMap { optionalUser in
        guard let user = optionalUser else { return pure(optionalUser) }

        return self.updateEmailSettings(EmailSetting.Newsletter.allNewsletters, user.id)
          .map(const(optionalUser))
      }
  }

  public func updateUser(
    id: Models.User.ID,
    name: String? = nil,
    email: EmailAddress? = nil,
    emailSettings: [EmailSetting.Newsletter]? = nil,
    episodeCreditCount: Int? = nil,
    rssSalt: Models.User.RssSalt? = nil
  ) -> EitherIO<Error, Prelude.Unit> {
    self.updateUser(id, name, email, episodeCreditCount, rssSalt)
      .flatMap(const(self.updateEmailSettings(emailSettings, id)))
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
      let database = pool.database(logger: Logger(label: "Postgres"))
      _ = try await database.run("DROP SCHEMA IF EXISTS public CASCADE").run.performAsync().unwrap()
      _ = try await database.run("CREATE SCHEMA public").run.performAsync().unwrap()
      _ = try await database.run("GRANT ALL ON SCHEMA public TO pointfreeco").run.performAsync()
        .unwrap()
      _ = try await database.run("GRANT ALL ON SCHEMA public TO public").run.performAsync().unwrap()
      _ = try await self.migrate().run.performAsync().unwrap()
      _ = try await database.run("CREATE SEQUENCE test_uuids").run.performAsync().unwrap()
      _ = try await database.run("CREATE SEQUENCE test_shortids").run.performAsync().unwrap()
      _ = try await database.run(
        """
        CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
        RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      .run.performAsync().unwrap()
      _ = try await database.run(
        """
        CREATE OR REPLACE FUNCTION gen_shortid(table_name text, column_name text)
        RETURNS text AS $$
        BEGIN
          RETURN table_name||'-'||column_name||nextval('test_shortids')::text;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      .run.performAsync().unwrap()
    }
  #endif
}
