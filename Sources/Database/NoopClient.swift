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
    deleteEnterpriseEmail: { _ in throwE(NoopError()) },
    deleteTeamInvite: { _ in throwE(NoopError()) },
    execute: { _ in throwE(NoopError()) },
    fetchAdmins: { throwE(NoopError()) },
    fetchEmailSettingsForUserId: { _ in throwE(NoopError()) },
    fetchEnterpriseAccountForDomain: { _ in throwE(NoopError()) },
    fetchEnterpriseAccountForSubscription: { _ in throwE(NoopError()) },
    fetchEnterpriseEmails: { throwE(NoopError()) },
    fetchEpisodeCredits: { _ in throwE(NoopError()) },
    fetchEpisodeProgress: { _, _ in throwE(NoopError()) },
    fetchFreeEpisodeUsers: { throwE(NoopError()) },
    fetchGift: { _ in throwE(NoopError()) },
    fetchGiftByStripePaymentIntentId: { _ in throwE(NoopError()) },
    fetchGiftsToDeliver: { throwE(NoopError()) },
    fetchSubscriptionById: { _ in throwE(NoopError()) },
    fetchSubscriptionByOwnerId: { _ in throwE(NoopError()) },
    fetchSubscriptionTeammatesByOwnerId: { _ in throwE(NoopError()) },
    fetchTeamInvite: { _ in throwE(NoopError()) },
    fetchTeamInvites: { _ in throwE(NoopError()) },
    fetchUserByGitHub: { _ in throwE(NoopError()) },
    fetchUserById: { _ in throwE(NoopError()) },
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
