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
    fetchEnterpriseEmails: { .failing("Database.Client.fetchEnterpriseEmails") },
    fetchEpisodeCredits: { _ in .failing("Database.Client.fetchEpisodeCredits") },
    fetchEpisodeProgress: { _, _ in .failing("Database.Client.fetchEpisodeProgress") },
    fetchFreeEpisodeUsers: { .failing("Database.Client.fetchFreeEpisodeUsers") },
    fetchGift: { _ in .failing("Database.Client.fetchGift") },
    fetchGiftByStripePaymentIntentId: { _ in
      .failing("Database.Client.fetchGiftByStripePaymentIntentId")
    },
    fetchGiftsToDeliver: { .failing("Database.Client.fetchGiftsToDeliver") },
    fetchSubscriptionById: { _ in .failing("Database.Client.fetchSubscriptionById") },
    fetchSubscriptionByOwnerId: { _ in .failing("Database.Client.fetchSubscriptionByOwnerId") },
    fetchSubscriptionTeammatesByOwnerId: { _ in
      .failing("Database.Client.fetchSubscriptionTeammatesByOwnerId")
    },
    fetchTeamInvite: { _ in .failing("Database.Client.fetchTeamInvite") },
    fetchTeamInvites: { _ in .failing("Database.Client.fetchTeamInvites") },
    fetchUserByGitHub: { _ in .failing("Database.Client.fetchUserByGitHub") },
    fetchUserById: { _ in .failing("Database.Client.fetchUserById") },
    fetchUserByReferralCode: { _ in .failing("Database.Client.fetchUserByReferralCode") },
    fetchUserByRssSalt: { _ in .failing("Database.Client.fetchUserByRssSalt") },
    fetchUsersSubscribedToNewsletter: { _, _ in
      .failing("Database.Client.fetchUsersSubscribedToNewsletter")
    },
    fetchUsersToWelcome: { _ in .failing("Database.Client.fetchUsersToWelcome") },
    incrementEpisodeCredits: { _ in .failing("Database.Client.incrementEpisodeCredits") },
    insertTeamInvite: { _, _ in .failing("Database.Client.insertTeamInvite") },
    migrate: { .failing("Database.Client.migrate") },
    redeemEpisodeCredit: { _, _ in .failing("Database.Client.redeemEpisodeCredit") },
    removeTeammateUserIdFromSubscriptionId: { _, _ in
      .failing("Database.Client.removeTeammateUserIdFromSubscriptionId")
    },
    sawUser: { _ in .failing("Database.Client.sawUser") },
    updateEmailSettings: { _, _ in .failing("Database.Client.updateEmailSettings") },
    updateEpisodeProgress: { _, _, _ in .failing("Database.Client.updateEpisodeProgress") },
    updateGift: { _, _ in .failing("Database.Client.updateGift") },
    updateGiftStatus: { _, _, _ in .failing("Database.Client.updateGiftStatus") },
    updateStripeSubscription: { _ in .failing("Database.Client.updateStripeSubscription") },
    updateUser: { _, _, _, _, _ in .failing("Database.Client.updateUser") },
    upsertUser: { _, _, _ in .failing("Database.Client.upsertUser") }
  )
}
