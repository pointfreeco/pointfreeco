import Database
import Either
import Models
import ModelsTestSupport
import PointFreePrelude
import Prelude

extension Client {
  public static let mock = Client(
    addUserIdToSubscriptionId: { _, _ in },
    createEnterpriseAccount: { _, _, _ in .mock },
    createEnterpriseEmail: { _, _ in .mock },
    createFeedRequestEvent: { _, _, _ in },
    createGift: { _ in .unfulfilled },
    createSubscription: { _, _, _, _ in .mock },
    deleteEnterpriseEmail: { _ in },
    deleteTeamInvite: { _ in },
    execute: { _ in throw unit },
    fetchAdmins: { [] },
    fetchEmailSettingsForUserId: { _ in [.mock] },
    fetchEnterpriseAccountForDomain: { _ in .mock },
    fetchEnterpriseAccountForSubscription: { _ in throw unit },
    fetchEnterpriseEmails: { [.mock] },
    fetchEpisodeCredits: { _ in [] },
    fetchEpisodeProgress: { _, _ in nil },
    fetchFreeEpisodeUsers: { [.mock] },
    fetchGift: { _ in .unfulfilled },
    fetchGiftByStripePaymentIntentId: { _ in .unfulfilled },
    fetchGiftsToDeliver: {
      [update(.unfulfilled) { $0.deliverAt = .init(timeIntervalSince1970: 1_234_567_890) }]
    },
    fetchSubscriptionById: { id in pure(.some(update(.mock) { $0.id = id })) },
    fetchSubscriptionByOwnerId: { userId in pure(.some(update(.mock) { $0.userId = userId })) },
    fetchSubscriptionTeammatesByOwnerId: const(pure([.mock])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([])),
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: { id in pure(update(.mock) { $0.id = id }) },
    fetchUserByReferralCode: { code in pure(update(.mock) { $0.referralCode = code }) },
    fetchUserByRssSalt: { _ in pure(.mock) },
    fetchUsersSubscribedToNewsletter: { _, _ in pure([.mock]) },
    fetchUsersToWelcome: const(pure([.mock])),
    incrementEpisodeCredits: const(pure([])),
    insertTeamInvite: { _, _ in pure(.mock) },
    migrate: unzurry(pure(unit)),
    redeemEpisodeCredit: { _, _ in pure(unit) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in pure(unit) },
    sawUser: const(pure(unit)),
    updateEmailSettings: { _, _ in pure(unit) },
    updateEpisodeProgress: { _, _, _ in pure(unit) },
    updateGift: { _, _ in pure(.fulfilled) },
    updateGiftStatus: { _, _, _ in pure(.fulfilled) },
    updateStripeSubscription: const(pure(.mock)),
    updateUser: { _, _, _, _, _ in pure(unit) },
    upsertUser: { _, _, _ in pure(.some(.mock)) }
  )
}
