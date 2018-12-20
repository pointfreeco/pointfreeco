// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import PointFreeTests; @testable import StyleguideTests;
extension AboutTests {
  static var allTests: [(String, (AboutTests) -> () throws -> Void)] = [
    ("testAbout", testAbout)
  ]
}
extension AccountTests {
  static var allTests: [(String, (AccountTests) -> () throws -> Void)] = [
    ("testAccount", testAccount),
    ("testAccount_WithRssFeatureFlag", testAccount_WithRssFeatureFlag),
    ("testTeam_OwnerIsNotSubscriber", testTeam_OwnerIsNotSubscriber),
    ("testAccount_WithExtraInvoiceInfo", testAccount_WithExtraInvoiceInfo),
    ("testAccountWithFlashNotice", testAccountWithFlashNotice),
    ("testAccountWithFlashWarning", testAccountWithFlashWarning),
    ("testAccountWithFlashError", testAccountWithFlashError),
    ("testAccountWithPastDue", testAccountWithPastDue),
    ("testAccountCancelingSubscription", testAccountCancelingSubscription),
    ("testAccountCanceledSubscription", testAccountCanceledSubscription),
    ("testEpisodeCredits_1Credit_NoneChosen", testEpisodeCredits_1Credit_NoneChosen),
    ("testEpisodeCredits_1Credit_1Chosen", testEpisodeCredits_1Credit_1Chosen),
    ("testAccountWithDiscount", testAccountWithDiscount)
  ]
}
extension AppleDeveloperMerchantIdDomainAssociationTests {
  static var allTests: [(String, (AppleDeveloperMerchantIdDomainAssociationTests) -> () throws -> Void)] = [
    ("testNotLoggedIn_IndividualMonthly", testNotLoggedIn_IndividualMonthly)
  ]
}
extension AtomFeedTests {
  static var allTests: [(String, (AtomFeedTests) -> () throws -> Void)] = [
    ("testAtomFeed", testAtomFeed),
    ("testEpisodeFeed", testEpisodeFeed),
    ("testEpisodeFeed_WithRecentlyFreeEpisode", testEpisodeFeed_WithRecentlyFreeEpisode)
  ]
}
extension AuthTests {
  static var allTests: [(String, (AuthTests) -> () throws -> Void)] = [
    ("testRegister", testRegister),
    ("testAuth", testAuth),
    ("testAuth_WithFetchAuthTokenFailure", testAuth_WithFetchAuthTokenFailure),
    ("testAuth_WithFetchAuthTokenBadVerificationCode", testAuth_WithFetchAuthTokenBadVerificationCode),
    ("testAuth_WithFetchAuthTokenBadVerificationCodeRedirect", testAuth_WithFetchAuthTokenBadVerificationCodeRedirect),
    ("testAuth_WithFetchUserFailure", testAuth_WithFetchUserFailure),
    ("testLogin", testLogin),
    ("testLogin_AlreadyLoggedIn", testLogin_AlreadyLoggedIn),
    ("testLoginWithRedirect", testLoginWithRedirect),
    ("testLogout", testLogout),
    ("testHome_LoggedOut", testHome_LoggedOut),
    ("testHome_LoggedIn", testHome_LoggedIn)
  ]
}
extension BlogTests {
  static var allTests: [(String, (BlogTests) -> () throws -> Void)] = [
    ("testBlogIndex", testBlogIndex),
    ("testBlogIndex_WithLotsOfPosts", testBlogIndex_WithLotsOfPosts),
    ("testBlogIndex_Unauthed", testBlogIndex_Unauthed),
    ("testBlogShow", testBlogShow),
    ("testBlogShow_Unauthed", testBlogShow_Unauthed),
    ("testBlogAtomFeed", testBlogAtomFeed),
    ("testBlogAtomFeed_Unauthed", testBlogAtomFeed_Unauthed)
  ]
}
extension CancelTests {
  static var allTests: [(String, (CancelTests) -> () throws -> Void)] = [
    ("testCancel", testCancel),
    ("testCancelLoggedOut", testCancelLoggedOut),
    ("testCancelNoSubscription", testCancelNoSubscription),
    ("testCancelCancelingSubscription", testCancelCancelingSubscription),
    ("testCancelCanceledSubscription", testCancelCanceledSubscription),
    ("testCancelStripeFailure", testCancelStripeFailure),
    ("testCancelEmail", testCancelEmail),
    ("testReactivate", testReactivate),
    ("testReactivateLoggedOut", testReactivateLoggedOut),
    ("testReactivateNoSubscription", testReactivateNoSubscription),
    ("testReactivateActiveSubscription", testReactivateActiveSubscription),
    ("testReactivateCanceledSubscription", testReactivateCanceledSubscription),
    ("testReactivateStripeFailure", testReactivateStripeFailure),
    ("testReactivateEmail", testReactivateEmail)
  ]
}
extension ChangeEmailConfirmationTests {
  static var allTests: [(String, (ChangeEmailConfirmationTests) -> () throws -> Void)] = [
    ("testChangeEmailConfirmationEmail", testChangeEmailConfirmationEmail),
    ("testChangedEmail", testChangedEmail)
  ]
}
extension ChangeTests {
  static var allTests: [(String, (ChangeTests) -> () throws -> Void)] = [
    ("testChangeShow", testChangeShow),
    ("testChangeShowLoggedOut", testChangeShowLoggedOut),
    ("testChangeShowNoSubscription", testChangeShowNoSubscription),
    ("testChangeShowCancelingSubscription", testChangeShowCancelingSubscription),
    ("testChangeShowCanceledSubscription", testChangeShowCanceledSubscription),
    ("testChangeShowDiscountSubscription", testChangeShowDiscountSubscription),
    ("testChangeUpdateUpgradeIndividualPlan", testChangeUpdateUpgradeIndividualPlan),
    ("testChangeUpdateDowngradeIndividualPlan", testChangeUpdateDowngradeIndividualPlan),
    ("testChangeUpdateUpgradeTeamPlan", testChangeUpdateUpgradeTeamPlan),
    ("testChangeUpdateDowngradeTeamPlan", testChangeUpdateDowngradeTeamPlan),
    ("testChangeUpdateAddSeatsIndividualPlan", testChangeUpdateAddSeatsIndividualPlan),
    ("testChangeUpgradeIndividualMonthlyToTeamYearly", testChangeUpgradeIndividualMonthlyToTeamYearly),
    ("testChangeUpdateAddSeatsTeamPlan", testChangeUpdateAddSeatsTeamPlan),
    ("testChangeUpdateRemoveSeats", testChangeUpdateRemoveSeats),
    ("testChangeUpdateRemoveSeatsInvalidNumber", testChangeUpdateRemoveSeatsInvalidNumber)
  ]
}
extension DatabaseTests {
  static var allTests: [(String, (DatabaseTests) -> () throws -> Void)] = [
    ("testCreate", testCreate)
  ]
}
extension DiscountsTests {
  static var allTests: [(String, (DiscountsTests) -> () throws -> Void)] = [
    ("testDiscounts_LoggedOut", testDiscounts_LoggedOut),
    ("testDiscounts_LoggedIn", testDiscounts_LoggedIn)
  ]
}
extension EitherIOTests {
  static var allTests: [(String, (EitherIOTests) -> () throws -> Void)] = [
    ("testRetry_Fails", testRetry_Fails),
    ("testRetry_Succeeds", testRetry_Succeeds),
    ("testRetry_MaxRetriesZero_Success", testRetry_MaxRetriesZero_Success),
    ("testRetry_MaxRetriesZero_Failure", testRetry_MaxRetriesZero_Failure)
  ]
}
extension EmailInviteTests {
  static var allTests: [(String, (EmailInviteTests) -> () throws -> Void)] = [
    ("testEmailInvite", testEmailInvite),
    ("testInviteAcceptance", testInviteAcceptance)
  ]
}
extension EnvVarTests {
  static var allTests: [(String, (EnvVarTests) -> () throws -> Void)] = [
    ("testDecoding", testDecoding)
  ]
}
extension EnvironmentTests {
  static var allTests: [(String, (EnvironmentTests) -> () throws -> Void)] = [
    ("testDefault", testDefault)
  ]
}
extension EpisodeTests {
  static var allTests: [(String, (EpisodeTests) -> () throws -> Void)] = [
    ("testEpisodePage", testEpisodePage),
    ("testEpisodePageSubscriber", testEpisodePageSubscriber),
    ("testFreeEpisodePage", testFreeEpisodePage),
    ("testFreeEpisodePageSubscriber", testFreeEpisodePageSubscriber),
    ("testEpisodeNotFound", testEpisodeNotFound),
    ("testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit", testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit),
    ("testEpisodeCredit_PrivateEpisode_NonSubscriber_UsedCredit", testEpisodeCredit_PrivateEpisode_NonSubscriber_UsedCredit),
    ("testEpisodeCredit_PrivateEpisode_NonSubscriber_HasCredits", testEpisodeCredit_PrivateEpisode_NonSubscriber_HasCredits),
    ("testRedeemEpisodeCredit_HappyPath", testRedeemEpisodeCredit_HappyPath),
    ("testRedeemEpisodeCredit_NotEnoughCredits", testRedeemEpisodeCredit_NotEnoughCredits),
    ("testRedeemEpisodeCredit_PublicEpisode", testRedeemEpisodeCredit_PublicEpisode),
    ("testRedeemEpisodeCredit_AlreadyCredited", testRedeemEpisodeCredit_AlreadyCredited),
    ("test_permission", test_permission),
    ("testEpisodePage_ExercisesAndReferences", testEpisodePage_ExercisesAndReferences)
  ]
}
extension FreeEpisodeEmailTests {
  static var allTests: [(String, (FreeEpisodeEmailTests) -> () throws -> Void)] = [
    ("testFreeEpisodeEmail", testFreeEpisodeEmail)
  ]
}
extension GitHubTests {
  static var allTests: [(String, (GitHubTests) -> () throws -> Void)] = [
    ("testRequests", testRequests)
  ]
}
extension HomeTests {
  static var allTests: [(String, (HomeTests) -> () throws -> Void)] = [
    ("testHomepage_LoggedOut", testHomepage_LoggedOut),
    ("testHomepage_Subscriber", testHomepage_Subscriber),
    ("testEpisodesIndex", testEpisodesIndex)
  ]
}
extension HtmlCssInlinerTests {
  static var allTests: [(String, (HtmlCssInlinerTests) -> () throws -> Void)] = [
    ("testHtmlCssInliner", testHtmlCssInliner)
  ]
}
extension InviteTests {
  static var allTests: [(String, (InviteTests) -> () throws -> Void)] = [
    ("testShowInvite_LoggedOut", testShowInvite_LoggedOut),
    ("testShowInvite_LoggedIn_NonSubscriber", testShowInvite_LoggedIn_NonSubscriber),
    ("testShowInvite_LoggedIn_Subscriber", testShowInvite_LoggedIn_Subscriber),
    ("testResendInvite_HappyPath", testResendInvite_HappyPath),
    ("testResendInvite_CurrentUserIsNotInviter", testResendInvite_CurrentUserIsNotInviter),
    ("testRevokeInvite_HappyPath", testRevokeInvite_HappyPath),
    ("testRevokeInvite_CurrentUserIsNotInviter", testRevokeInvite_CurrentUserIsNotInviter),
    ("testAcceptInvitation_HappyPath", testAcceptInvitation_HappyPath),
    ("testAcceptInvitation_InviterIsNotSubscriber", testAcceptInvitation_InviterIsNotSubscriber),
    ("testAcceptInvitation_InviterHasInactiveStripeSubscription", testAcceptInvitation_InviterHasInactiveStripeSubscription),
    ("testAcceptInvitation_InviterHasCancelingStripeSubscription", testAcceptInvitation_InviterHasCancelingStripeSubscription)
  ]
}
extension InvoicesTests {
  static var allTests: [(String, (InvoicesTests) -> () throws -> Void)] = [
    ("testInvoices", testInvoices),
    ("testInvoice", testInvoice),
    ("testInvoiceWithDiscount", testInvoiceWithDiscount)
  ]
}
extension MetaLayoutTests {
  static var allTests: [(String, (MetaLayoutTests) -> () throws -> Void)] = [
    ("testMetaTagsWithStyleTag", testMetaTagsWithStyleTag)
  ]
}
extension MinimalNavViewTests {
  static var allTests: [(String, (MinimalNavViewTests) -> () throws -> Void)] = [
    ("testNav_Html", testNav_Html),
    ("testNav_Screenshots", testNav_Screenshots)
  ]
}
extension NewBlogPostEmailTests {
  static var allTests: [(String, (NewBlogPostEmailTests) -> () throws -> Void)] = [
    ("testNewBlogPostEmail_NoAnnouncements_Subscriber", testNewBlogPostEmail_NoAnnouncements_Subscriber),
    ("testNewBlogPostEmail_NoAnnouncements_NonSubscriber", testNewBlogPostEmail_NoAnnouncements_NonSubscriber),
    ("testNewBlogPostEmail_Announcements_Subscriber", testNewBlogPostEmail_Announcements_Subscriber),
    ("testNewBlogPostEmail_Announcements_NonSubscriber", testNewBlogPostEmail_Announcements_NonSubscriber),
    ("testNewBlogPostRoute", testNewBlogPostRoute),
    ("testNewBlogPostEmail_NoCoverImage", testNewBlogPostEmail_NoCoverImage)
  ]
}
extension NewEpisodeEmailTests {
  static var allTests: [(String, (NewEpisodeEmailTests) -> () throws -> Void)] = [
    ("testNewEpisodeEmail_Subscriber", testNewEpisodeEmail_Subscriber),
    ("testNewEpisodeEmail_FreeEpisode_NonSubscriber", testNewEpisodeEmail_FreeEpisode_NonSubscriber),
    ("testNewEpisodeEmail_Announcement_NonSubscriber", testNewEpisodeEmail_Announcement_NonSubscriber),
    ("testNewEpisodeEmail_Announcement_Subscriber", testNewEpisodeEmail_Announcement_Subscriber)
  ]
}
extension NewslettersTests {
  static var allTests: [(String, (NewslettersTests) -> () throws -> Void)] = [
    ("testExpressUnsubscribe", testExpressUnsubscribe),
    ("testExpressUnsubscribeReply", testExpressUnsubscribeReply),
    ("testExpressUnsubscribeReply_IncorrectSignature", testExpressUnsubscribeReply_IncorrectSignature),
    ("testExpressUnsubscribeReply_UnknownNewsletter", testExpressUnsubscribeReply_UnknownNewsletter)
  ]
}
extension NotFoundMiddlewareTests {
  static var allTests: [(String, (NotFoundMiddlewareTests) -> () throws -> Void)] = [
    ("testNotFound", testNotFound),
    ("testNotFound_LoggedIn", testNotFound_LoggedIn)
  ]
}
extension PaymentInfoTests {
  static var allTests: [(String, (PaymentInfoTests) -> () throws -> Void)] = [
    ("testRender", testRender)
  ]
}
extension PricingTests {
  static var allTests: [(String, (PricingTests) -> () throws -> Void)] = [
    ("testPricing", testPricing),
    ("testDiscount", testDiscount),
    ("testInvalidDiscount", testInvalidDiscount),
    ("testPricingLoggedIn_NonSubscriber", testPricingLoggedIn_NonSubscriber),
    ("testPricingLoggedIn_NonSubscriber_Expanded", testPricingLoggedIn_NonSubscriber_Expanded),
    ("testPricingLoggedIn_Subscriber", testPricingLoggedIn_Subscriber),
    ("testPricingLoggedIn_CanceledSubscriber", testPricingLoggedIn_CanceledSubscriber),
    ("testPricingLoggedIn_PastDueSubscriber", testPricingLoggedIn_PastDueSubscriber)
  ]
}
extension PrivacyTests {
  static var allTests: [(String, (PrivacyTests) -> () throws -> Void)] = [
    ("testPrivacy", testPrivacy)
  ]
}
extension PrivateRssTests {
  static var allTests: [(String, (PrivateRssTests) -> () throws -> Void)] = [
    ("testFeed_Authenticated_Subscriber_Monthly", testFeed_Authenticated_Subscriber_Monthly),
    ("testFeed_Authenticated_Subscriber_Yearly", testFeed_Authenticated_Subscriber_Yearly),
    ("testFeed_Authenticated_NonSubscriber", testFeed_Authenticated_NonSubscriber),
    ("testFeed_Authenticated_InActiveSubscriber", testFeed_Authenticated_InActiveSubscriber),
    ("testFeed_BadSalt", testFeed_BadSalt)
  ]
}
extension RegistrationEmailTests {
  static var allTests: [(String, (RegistrationEmailTests) -> () throws -> Void)] = [
    ("testRegistrationEmail", testRegistrationEmail)
  ]
}
extension SiteMiddlewareTests {
  static var allTests: [(String, (SiteMiddlewareTests) -> () throws -> Void)] = [
    ("testWithoutWWW", testWithoutWWW),
    ("testWithoutHeroku", testWithoutHeroku),
    ("testWithWWW", testWithWWW),
    ("testWithHttps", testWithHttps)
  ]
}
extension StripeTests {
  static var allTests: [(String, (StripeTests) -> () throws -> Void)] = [
    ("testDecodingCustomer", testDecodingCustomer),
    ("testDecodingCustomer_Metadata", testDecodingCustomer_Metadata),
    ("testDecodingSubscriptionWithDiscount", testDecodingSubscriptionWithDiscount),
    ("testDecodingDiscountJson", testDecodingDiscountJson),
    ("testRequests", testRequests)
  ]
}
extension StripeWebhooksTests {
  static var allTests: [(String, (StripeWebhooksTests) -> () throws -> Void)] = [
    ("testDecoding", testDecoding),
    ("testValidHook", testValidHook),
    ("testStaleHook", testStaleHook),
    ("testInvalidHook", testInvalidHook),
    ("testPastDueEmail", testPastDueEmail)
  ]
}
extension StyleguideTests {
  static var allTests: [(String, (StyleguideTests) -> () throws -> Void)] = [
    ("testStyleguide", testStyleguide),
    ("testDesignSystem", testDesignSystem),
    ("testPointFreeStyles", testPointFreeStyles)
  ]
}
extension SubscribeTests {
  static var allTests: [(String, (SubscribeTests) -> () throws -> Void)] = [
    ("testNotLoggedIn_IndividualMonthly", testNotLoggedIn_IndividualMonthly),
    ("testCoupon_Individual", testCoupon_Individual),
    ("testCoupon_Team", testCoupon_Team),
    ("testNotLoggedIn_IndividualYearly", testNotLoggedIn_IndividualYearly),
    ("testNotLoggedIn_Team", testNotLoggedIn_Team),
    ("testCurrentSubscribers", testCurrentSubscribers),
    ("testInvalidQuantity", testInvalidQuantity),
    ("testHappyPath", testHappyPath),
    ("testCreateCustomerFailure", testCreateCustomerFailure),
    ("testCreateStripeSubscriptionFailure", testCreateStripeSubscriptionFailure),
    ("testCreateDatabaseSubscriptionFailure", testCreateDatabaseSubscriptionFailure)
  ]
}
extension TeamEmailsTests {
  static var allTests: [(String, (TeamEmailsTests) -> () throws -> Void)] = [
    ("testYouHaveBeenRemovedEmailView", testYouHaveBeenRemovedEmailView),
    ("testTeammateRemovedEmailView", testTeammateRemovedEmailView)
  ]
}
extension UpdateProfileTests {
  static var allTests: [(String, (UpdateProfileTests) -> () throws -> Void)] = [
    ("testUpdateNameAndEmail", testUpdateNameAndEmail),
    ("testUpdateEmailSettings", testUpdateEmailSettings),
    ("testUpdateExtraInvoiceInfo", testUpdateExtraInvoiceInfo)
  ]
}
extension WelcomeEmailTests {
  static var allTests: [(String, (WelcomeEmailTests) -> () throws -> Void)] = [
    ("testWelcomeEmail1", testWelcomeEmail1),
    ("testWelcomeEmail2", testWelcomeEmail2),
    ("testWelcomeEmail3", testWelcomeEmail3),
    ("testIncrementEpisodeCredits", testIncrementEpisodeCredits),
    ("testEpisodeEmails", testEpisodeEmails)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AboutTests.allTests),
  testCase(AccountTests.allTests),
  testCase(AppleDeveloperMerchantIdDomainAssociationTests.allTests),
  testCase(AtomFeedTests.allTests),
  testCase(AuthTests.allTests),
  testCase(BlogTests.allTests),
  testCase(CancelTests.allTests),
  testCase(ChangeEmailConfirmationTests.allTests),
  testCase(ChangeTests.allTests),
  testCase(DatabaseTests.allTests),
  testCase(DiscountsTests.allTests),
  testCase(EitherIOTests.allTests),
  testCase(EmailInviteTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EnvironmentTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(FreeEpisodeEmailTests.allTests),
  testCase(GitHubTests.allTests),
  testCase(HomeTests.allTests),
  testCase(HtmlCssInlinerTests.allTests),
  testCase(InviteTests.allTests),
  testCase(InvoicesTests.allTests),
  testCase(MetaLayoutTests.allTests),
  testCase(MinimalNavViewTests.allTests),
  testCase(NewBlogPostEmailTests.allTests),
  testCase(NewEpisodeEmailTests.allTests),
  testCase(NewslettersTests.allTests),
  testCase(NotFoundMiddlewareTests.allTests),
  testCase(PaymentInfoTests.allTests),
  testCase(PricingTests.allTests),
  testCase(PrivacyTests.allTests),
  testCase(PrivateRssTests.allTests),
  testCase(RegistrationEmailTests.allTests),
  testCase(SiteMiddlewareTests.allTests),
  testCase(StripeTests.allTests),
  testCase(StripeWebhooksTests.allTests),
  testCase(StyleguideTests.allTests),
  testCase(SubscribeTests.allTests),
  testCase(TeamEmailsTests.allTests),
  testCase(UpdateProfileTests.allTests),
  testCase(WelcomeEmailTests.allTests),
])
// swiftlint:enable trailing_comma
