import PointFreePrelude
import XCTestDynamicOverlay

extension Client {
  public static let failing = Self(
    addUserIdToSubscriptionId: unimplemented("Database.Client.addUserIdToSubscriptionId"),
    createEnterpriseAccount: unimplemented("Database.Client.createEnterpriseAccount"),
    createEnterpriseEmail: unimplemented("Database.Client.createEnterpriseEmail"),
    createFeedRequestEvent: unimplemented("Database.Client.createFeedRequestEvent"),
    createGift: unimplemented("Database.Client.createGift"),
    createSubscription: unimplemented("Database.Client.createSubscription"),
    deleteEnterpriseEmail: unimplemented("Database.Client.deleteEnterpriseEmail"),
    deleteTeamInvite: unimplemented("Database.Client.deleteTeamInvite"),
    execute: unimplemented("Database.Client.execute"),
    fetchAdmins: unimplemented("Database.Client.fetchAdmins"),
    fetchEmailSettingsForUserId: unimplemented("Database.Client.fetchEmailSettingsForUserId"),
    fetchEnterpriseAccountForDomain: unimplemented(
      "Database.Client.fetchEnterpriseAccountForDomain"
    ),
    fetchEnterpriseAccountForSubscription: unimplemented(
      "Database.Client.fetchEnterpriseAccountForSubscription"
    ),
    fetchEnterpriseEmails: unimplemented("Database.Client.fetchEnterpriseEmails"),
    fetchEpisodeCredits: unimplemented("Database.Client.fetchEpisodeCredits"),
    fetchEpisodeProgress: unimplemented("Database.Client.fetchEpisodeProgress"),
    fetchEpisodeProgresses: unimplemented("Database.Client.fetchEpisodeProgresses"),
    fetchFreeEpisodeUsers: unimplemented("Database.Client.fetchFreeEpisodeUsers"),
    fetchGift: unimplemented("Database.Client.fetchGift"),
    fetchGiftByStripePaymentIntentId: unimplemented(
      "Database.Client.fetchGiftByStripePaymentIntentId"
    ),
    fetchGiftsToDeliver: unimplemented("Database.Client.fetchGiftsToDeliver"),
    fetchLivestreams: unimplemented("Database.Client.fetchLivestreams"),
    fetchSubscriptionById: unimplemented("Database.Client.fetchSubscriptionById"),
    fetchSubscriptionByOwnerId: unimplemented("Database.Client.fetchSubscriptionByOwnerId"),
    fetchSubscriptionTeammatesByOwnerId: unimplemented(
      "Database.Client.fetchSubscriptionTeammatesByOwnerId"
    ),
    fetchTeamInvite: unimplemented("Database.Client.fetchTeamInvite"),
    fetchTeamInvites: unimplemented("Database.Client.fetchTeamInvites"),
    fetchUserByGitHub: unimplemented("Database.Client.fetchUserByGitHub"),
    fetchUserById: unimplemented("Database.Client.fetchUserById"),
    fetchUserByReferralCode: unimplemented("Database.Client.fetchUserByReferralCode"),
    fetchUserByRssSalt: unimplemented("Database.Client.fetchUserByRssSalt"),
    fetchUsersSubscribedToNewsletter: unimplemented(
      "Database.Client.fetchUsersSubscribedToNewsletter"
    ),
    fetchUsersToWelcome: unimplemented("Database.Client.fetchUsersToWelcome"),
    incrementEpisodeCredits: unimplemented("Database.Client.incrementEpisodeCredits"),
    insertTeamInvite: unimplemented("Database.Client.insertTeamInvite"),
    migrate: unimplemented("Database.Client.migrate"),
    redeemEpisodeCredit: unimplemented("Database.Client.redeemEpisodeCredit"),
    removeTeammateUserIdFromSubscriptionId: unimplemented(
      "Database.Client.removeTeammateUserIdFromSubscriptionId"
    ),
    sawUser: unimplemented("Database.Client.sawUser"),
    updateEmailSettings: unimplemented("Database.Client.updateEmailSettings"),
    updateEpisodeProgress: unimplemented("Database.Client.updateEpisodeProgress"),
    updateGift: unimplemented("Database.Client.updateGift"),
    updateGiftStatus: unimplemented("Database.Client.updateGiftStatus"),
    updateStripeSubscription: unimplemented("Database.Client.updateStripeSubscription"),
    updateUser: unimplemented("Database.Client.updateUser"),
    upsertUser: unimplemented("Database.Client.upsertUser")
  )
}
