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
    fetchEpisodeProgress: { _, _ in throw unit },
    fetchEpisodeProgresses: { _ in throw unit },
    fetchFreeEpisodeUsers: { [.mock] },
    fetchGift: { _ in .unfulfilled },
    fetchGiftByStripePaymentIntentId: { _ in .unfulfilled },
    fetchGiftsToDeliver: {
      [update(.unfulfilled) { $0.deliverAt = .init(timeIntervalSince1970: 1_234_567_890) }]
    },
    fetchLivestreams: { [] },
    fetchSubscriptionById: { id in update(.mock) { $0.id = id } },
    fetchSubscriptionByOwnerId: { userId in update(.mock) { $0.userId = userId } },
    fetchSubscriptionByTeamInviteCode: { teamInviteCode in
      update(.mock) { $0.teamInviteCode = teamInviteCode }
    },
    fetchSubscriptionTeammatesByOwnerId: { _ in [.mock] },
    fetchTeamInvite: { _ in .mock },
    fetchTeamInvites: { _ in [] },
    fetchUserByGitHub: { _ in .mock },
    fetchUserById: { id in update(.mock) { $0.id = id } },
    fetchUserByReferralCode: { code in update(.mock) { $0.referralCode = code } },
    fetchUserByRssSalt: { _ in .mock },
    fetchUsersSubscribedToNewsletter: { _, _ in [.mock] },
    fetchUsersToWelcome: { _ in [.mock] },
    incrementEpisodeCredits: { _ in [] },
    insertTeamInvite: { _, _ in .mock },
    migrate: {},
    redeemEpisodeCredit: { _, _ in },
    removeTeammateUserIdFromSubscriptionId: { _, _ in },
    sawUser: { _ in },
    updateEmailSettings: { _, _ in },
    updateEpisodeProgress: { _, _, _, _ in },
    updateGift: { _, _ in .fulfilled },
    updateGiftStatus: { _, _, _ in .fulfilled },
    updateStripeSubscription: { _ in .mock },
    updateUser: { _, _, _, _, _ in },
    upsertUser: { _, _, _ in .mock }
  )
}
