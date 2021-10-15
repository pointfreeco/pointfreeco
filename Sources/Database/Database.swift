import Either
import EmailAddress
import Foundation
import GitHub
import Logging
import Models
import PointFreePrelude
import Prelude
import PostgresKit
import Stripe
import Tagged

public struct Client {
  public var addUserIdToSubscriptionId: (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  public var createEnterpriseAccount: (String, EnterpriseAccount.Domain, Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>
  public var createEnterpriseEmail: (EmailAddress, User.Id) -> EitherIO<Error, EnterpriseEmail?>
  public var createFeedRequestEvent: (FeedRequestEvent.FeedType, String, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var createGift: (CreateGiftRequest) -> EitherIO<Error, Gift>
  public var createSubscription: (Stripe.Subscription, Models.User.Id, Bool, Models.User.Id?) -> EitherIO<Error, Models.Subscription?>
  public var deleteEnterpriseEmail: (User.Id) -> EitherIO<Error, Prelude.Unit>
  public var deleteTeamInvite: (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>
  public var execute: (SQLQueryString) -> EitherIO<Swift.Error, [SQLRow]>
  public var fetchAdmins: () -> EitherIO<Error, [Models.User]>
  public var fetchEmailSettingsForUserId: (Models.User.Id) -> EitherIO<Error, [EmailSetting]>
  public var fetchEnterpriseAccountForDomain: (EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseAccountForSubscription: (Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>
  public var fetchEnterpriseEmails: () -> EitherIO<Error, [EnterpriseEmail]>
  public var fetchEpisodeCredits: (Models.User.Id) -> EitherIO<Error, [EpisodeCredit]>
  public var fetchEpisodeProgress: (User.Id, Episode.Sequence) -> EitherIO<Error, Int?>
  public var fetchFreeEpisodeUsers: () -> EitherIO<Error, [Models.User]>
  public var fetchGift: (Gift.Id) -> EitherIO<Error, Gift?>
  public var fetchGiftByStripeCouponId: (Coupon.Id) -> EitherIO<Error, Gift>
  public var fetchGiftByStripePaymentIntentId: (PaymentIntent.Id) -> EitherIO<Error, Gift>
  public var fetchSubscriptionById: (Models.Subscription.Id) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionByOwnerId: (Models.User.Id) -> EitherIO<Error, Models.Subscription?>
  public var fetchSubscriptionTeammatesByOwnerId: (Models.User.Id) -> EitherIO<Error, [Models.User]>
  public var fetchTeamInvite: (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>
  public var fetchTeamInvites: (Models.User.Id) -> EitherIO<Error, [TeamInvite]>
  public var fetchUserByGitHub: (GitHubUser.Id) -> EitherIO<Error, Models.User?>
  public var fetchUserById: (Models.User.Id) -> EitherIO<Error, Models.User?>
  public var fetchUserByReferralCode: (Models.User.ReferralCode) -> EitherIO<Error, Models.User?>
  public var fetchUserByRssSalt: (Models.User.RssSalt) -> EitherIO<Error, Models.User?>
  public var fetchUsersSubscribedToNewsletter: (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]>
  public var fetchUsersToWelcome: (Int) -> EitherIO<Error, [Models.User]>
  public var incrementEpisodeCredits: ([Models.User.Id]) -> EitherIO<Error, [Models.User]>
  public var insertTeamInvite: (EmailAddress, Models.User.Id) -> EitherIO<Error, TeamInvite>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>
  public var redeemEpisodeCredit: (Episode.Sequence, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var removeTeammateUserIdFromSubscriptionId: (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  public var sawUser: (Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var updateEmailSettings: ([EmailSetting.Newsletter]?, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var updateEpisodeProgress: (Episode.Sequence, Int, Models.User.Id) -> EitherIO<Error, Prelude.Unit>
  public var updateGift: (Gift.Id, Stripe.Coupon.Id) -> EitherIO<Error, Gift>
  public var updateStripeSubscription: (Stripe.Subscription) -> EitherIO<Error, Models.Subscription?>
  public var updateUser: (Models.User.Id, String?, EmailAddress?, Int?, Models.User.RssSalt?) -> EitherIO<Error, Prelude.Unit>
  public var upsertUser: (GitHubUserEnvelope, EmailAddress, () -> Date) -> EitherIO<Error, Models.User?>

  public init(
    addUserIdToSubscriptionId: @escaping (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>,
    createEnterpriseAccount: @escaping (String, EnterpriseAccount.Domain, Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>,
    createEnterpriseEmail: @escaping (EmailAddress, User.Id) -> EitherIO<Error, EnterpriseEmail?>,
    createFeedRequestEvent: @escaping (FeedRequestEvent.FeedType, String, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    createGift: @escaping (CreateGiftRequest) -> EitherIO<Error, Gift>,
    createSubscription: @escaping (Stripe.Subscription, Models.User.Id, Bool, Models.User.Id?) -> EitherIO<Error, Models.Subscription?>,
    deleteEnterpriseEmail: @escaping (User.Id) -> EitherIO<Error, Prelude.Unit>,
    deleteTeamInvite: @escaping (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>,
    execute: @escaping (SQLQueryString) -> EitherIO<Swift.Error, [SQLRow]>,
    fetchAdmins: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchEmailSettingsForUserId: @escaping (Models.User.Id) -> EitherIO<Error, [EmailSetting]>,
    fetchEnterpriseAccountForDomain: @escaping (EnterpriseAccount.Domain) -> EitherIO<Error, EnterpriseAccount?>,
    fetchEnterpriseAccountForSubscription: @escaping (Models.Subscription.Id) -> EitherIO<Error, EnterpriseAccount?>,
    fetchEnterpriseEmails: @escaping () -> EitherIO<Error, [EnterpriseEmail]>,
    fetchEpisodeCredits: @escaping (Models.User.Id) -> EitherIO<Error, [EpisodeCredit]>,
    fetchEpisodeProgress: @escaping (User.Id, Episode.Sequence) -> EitherIO<Error, Int?>,
    fetchFreeEpisodeUsers: @escaping () -> EitherIO<Error, [Models.User]>,
    fetchGift: @escaping (Gift.Id) -> EitherIO<Error, Gift?>,
    fetchGiftByStripeCouponId: @escaping (Coupon.Id) -> EitherIO<Error, Gift>,
    fetchGiftByStripePaymentIntentId: @escaping (PaymentIntent.Id) -> EitherIO<Error, Gift>,
    fetchSubscriptionById: @escaping (Models.Subscription.Id) -> EitherIO<Error, Models.Subscription?>,
    fetchSubscriptionByOwnerId: @escaping (Models.User.Id) -> EitherIO<Error, Models.Subscription?>,
    fetchSubscriptionTeammatesByOwnerId: @escaping (Models.User.Id) -> EitherIO<Error, [Models.User]>,
    fetchTeamInvite: @escaping (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>,
    fetchTeamInvites: @escaping (Models.User.Id) -> EitherIO<Error, [TeamInvite]>,
    fetchUserByGitHub: @escaping (GitHubUser.Id) -> EitherIO<Error, Models.User?>,
    fetchUserById: @escaping (Models.User.Id) -> EitherIO<Error, Models.User?>,
    fetchUserByReferralCode: @escaping (Models.User.ReferralCode) -> EitherIO<Error, Models.User?>,
    fetchUserByRssSalt: @escaping (Models.User.RssSalt) -> EitherIO<Error, Models.User?>,
    fetchUsersSubscribedToNewsletter: @escaping (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [Models.User]>,
    fetchUsersToWelcome: @escaping (Int) -> EitherIO<Error, [Models.User]>,
    incrementEpisodeCredits: @escaping ([Models.User.Id]) -> EitherIO<Error, [Models.User]>,
    insertTeamInvite: @escaping (EmailAddress, Models.User.Id) -> EitherIO<Error, TeamInvite>,
    migrate: @escaping () -> EitherIO<Error, Prelude.Unit>,
    redeemEpisodeCredit: @escaping (Episode.Sequence, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    removeTeammateUserIdFromSubscriptionId: @escaping (Models.User.Id, Models.Subscription.Id) -> EitherIO<Error, Prelude.Unit>,
    sawUser: @escaping (Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    updateEmailSettings: @escaping ([EmailSetting.Newsletter]?, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    updateEpisodeProgress: @escaping (Episode.Sequence, Int, Models.User.Id) -> EitherIO<Error, Prelude.Unit>,
    updateGift: @escaping (Gift.Id, Stripe.Coupon.Id) -> EitherIO<Error, Gift>,
    updateStripeSubscription: @escaping (Stripe.Subscription) -> EitherIO<Error, Models.Subscription?>,
    updateUser: @escaping (Models.User.Id, String?, EmailAddress?, Int?, Models.User.RssSalt?) -> EitherIO<Error, Prelude.Unit>,
    upsertUser: @escaping (GitHubUserEnvelope, EmailAddress, () -> Date) -> EitherIO<Error, Models.User?>
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
    self.fetchGiftByStripeCouponId = fetchGiftByStripeCouponId
    self.fetchGiftByStripePaymentIntentId = fetchGiftByStripePaymentIntentId
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
    id: Models.User.Id,
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
    public var stripeCouponId: Coupon.Id?
    public var stripePaymentIntentId: PaymentIntent.Id
    public var toEmail: EmailAddress
    public var toName: String

    public init(
      deliverAt: Date?,
      fromEmail: EmailAddress,
      fromName: String,
      message: String,
      monthsFree: Int,
      stripeCouponId: Coupon.Id?,
      stripePaymentIntentId: PaymentIntent.Id,
      toEmail: EmailAddress,
      toName: String
    ) {
      self.fromEmail = fromEmail
      self.fromName = fromName
      self.deliverAt = deliverAt
      self.message = message
      self.monthsFree = monthsFree
      self.stripeCouponId = stripeCouponId
      self.stripePaymentIntentId = stripePaymentIntentId
      self.toEmail = toEmail
      self.toName = toName
    }
  }

  #if DEBUG
    public func resetForTesting(pool: EventLoopGroupConnectionPool<PostgresConnectionSource>) throws
    {
      let database = pool.database(logger: Logger(label: "Postgres"))
      _ = try database.run("DROP SCHEMA IF EXISTS public CASCADE").run.perform().unwrap()
      _ = try database.run("CREATE SCHEMA public").run.perform().unwrap()
      _ = try database.run("GRANT ALL ON SCHEMA public TO pointfreeco").run.perform().unwrap()
      _ = try database.run("GRANT ALL ON SCHEMA public TO public").run.perform().unwrap()
      _ = try self.migrate().run.perform().unwrap()
      _ = try database.run("CREATE SEQUENCE test_uuids").run.perform().unwrap()
      _ = try database.run("CREATE SEQUENCE test_shortids").run.perform().unwrap()
      _ = try database.run(
        """
        CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
        RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      .run.perform().unwrap()
      _ = try database.run(
        """
        CREATE OR REPLACE FUNCTION gen_shortid(table_name text, column_name text)
        RETURNS text AS $$
        BEGIN
          RETURN table_name||'-'||column_name||nextval('test_shortids')::text;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )
      .run.perform().unwrap()
    }
  #endif
}
