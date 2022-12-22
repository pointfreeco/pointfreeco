import Either
import Prelude

struct NoopError: Error {}

extension Client {
  public static let noop = Self(
    addUserIdToSubscriptionId: { _, _ in throw NoopError() },
    createEnterpriseAccount: { _, _, _ in throw NoopError() },
    createEnterpriseEmail: { _, _ in throw NoopError() },
    createFeedRequestEvent: { _, _, _ in throw NoopError() },
    createGift: { _ in throw NoopError() },
    createSubscription: { _, _, _, _ in throw NoopError() },
    deleteEnterpriseEmail: { _ in throw NoopError() },
    deleteTeamInvite: { _ in throw NoopError() },
    execute: { _ in throw NoopError() },
    fetchAdmins: { throw NoopError() },
    fetchEmailSettingsForUserId: { _ in throw NoopError() },
    fetchEnterpriseAccountForDomain: { _ in throw NoopError() },
    fetchEnterpriseAccountForSubscription: { _ in throw NoopError() },
    fetchEnterpriseEmails: { throw NoopError() },
    fetchEpisodeCredits: { _ in throw NoopError() },
    fetchEpisodeProgress: { _, _ in throw NoopError() },
    fetchFreeEpisodeUsers: { throw NoopError() },
    fetchGift: { _ in throw NoopError() },
    fetchGiftByStripePaymentIntentId: { _ in throw NoopError() },
    fetchGiftsToDeliver: { throw NoopError() },
    fetchSubscriptionById: { _ in throw NoopError() },
    fetchSubscriptionByOwnerId: { _ in throw NoopError() },
    fetchSubscriptionTeammatesByOwnerId: { _ in throw NoopError() },
    fetchTeamInvite: { _ in throw NoopError() },
    fetchTeamInvites: { _ in throw NoopError() },
    fetchUserByGitHub: { _ in throw NoopError() },
    fetchUserById: { _ in throw NoopError() },
    fetchUserByReferralCode: { _ in throwE(NoopError()) },
    fetchUserByRssSalt: { _ in throwE(NoopError()) },
    fetchUsersSubscribedToNewsletter: { _, _ in throwE(NoopError()) },
    fetchUsersToWelcome: { _ in throwE(NoopError()) },
    incrementEpisodeCredits: { _ in throwE(NoopError()) },
    insertTeamInvite: { _, _ in throwE(NoopError()) },
    migrate: { pure(unit) },
    redeemEpisodeCredit: { _, _ in throwE(NoopError()) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in throwE(NoopError()) },
    sawUser: { _ in throwE(NoopError()) },
    updateEmailSettings: { _, _ in throwE(NoopError()) },
    updateEpisodeProgress: { _, _, _ in throwE(NoopError()) },
    updateGift: { _, _ in throwE(NoopError()) },
    updateGiftStatus: { _, _, _ in throwE(NoopError()) },
    updateStripeSubscription: { _ in throwE(NoopError()) },
    updateUser: { _, _, _, _, _ in throwE(NoopError()) },
    upsertUser: { _, _, _ in throwE(NoopError()) }
  )
}
