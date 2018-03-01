// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
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
    ("testAccountWithFlashNotice", testAccountWithFlashNotice),
    ("testAccountWithFlashWarning", testAccountWithFlashWarning),
    ("testAccountWithFlashError", testAccountWithFlashError),
    ("testAccountWithPastDue", testAccountWithPastDue),
    ("testAccountCancelingSubscription", testAccountCancelingSubscription),
    ("testAccountCanceledSubscription", testAccountCanceledSubscription)
  ]
}
extension AppleDeveloperMerchantIdDomainAssociationTests {
  static var allTests: [(String, (AppleDeveloperMerchantIdDomainAssociationTests) -> () throws -> Void)] = [
    ("testNotLoggedIn_IndividualMonthly", testNotLoggedIn_IndividualMonthly)
  ]
}
extension AtomFeedTests {
  static var allTests: [(String, (AtomFeedTests) -> () throws -> Void)] = [
    ("testAtomFeed", testAtomFeed)
  ]
}
extension AuthTests {
  static var allTests: [(String, (AuthTests) -> () throws -> Void)] = [
    ("testAuth", testAuth),
    ("testAuth_WithFetchAuthTokenFailure", testAuth_WithFetchAuthTokenFailure),
    ("testAuth_WithFetchUserFailure", testAuth_WithFetchUserFailure),
    ("testLogin", testLogin),
    ("testLogin_AlreadyLoggedIn", testLogin_AlreadyLoggedIn),
    ("testLoginWithRedirect", testLoginWithRedirect),
    ("testLogout", testLogout),
    ("testHome_LoggedOut", testHome_LoggedOut),
    ("testHome_LoggedIn", testHome_LoggedIn)
  ]
}
extension CancelTests {
  static var allTests: [(String, (CancelTests) -> () throws -> Void)] = [
    ("testConfirmCancel", testConfirmCancel),
    ("testConfirmCancelLoggedOut", testConfirmCancelLoggedOut),
    ("testConfirmCancelNoSubscription", testConfirmCancelNoSubscription),
    ("testConfirmCancelCancelingSubscription", testConfirmCancelCancelingSubscription),
    ("testConfirmCancelCanceledSubscription", testConfirmCancelCanceledSubscription),
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
extension ChangeSeatsTests {
  static var allTests: [(String, (ChangeSeatsTests) -> () throws -> Void)] = [
    ("testConfirmChangeSeats", testConfirmChangeSeats),
    ("testConfirmChangeSeatsLoggedOut", testConfirmChangeSeatsLoggedOut),
    ("testConfirmChangeSeatsNoSubscription", testConfirmChangeSeatsNoSubscription),
    ("testConfirmChangeSeatsCanceledSubscription", testConfirmChangeSeatsCanceledSubscription),
    ("testConfirmChangeSeatsInvalidPlan", testConfirmChangeSeatsInvalidPlan),
    ("testChangeSeats", testChangeSeats),
    ("testChangeSeatsLoggedOut", testChangeSeatsLoggedOut),
    ("testChangeSeatsNoSubscription", testChangeSeatsNoSubscription),
    ("testChangeSeatsCanceledSubscription", testChangeSeatsCanceledSubscription),
    ("testChangeSeatsInvalidPlan", testChangeSeatsInvalidPlan),
    ("testChangeSeatsInvalidSeats", testChangeSeatsInvalidSeats),
    ("testChangeSeatsEmail", testChangeSeatsEmail)
  ]
}
extension DatabaseTests {
  static var allTests: [(String, (DatabaseTests) -> () throws -> Void)] = [
    ("testCreate", testCreate)
  ]
}
extension DowngradeTests {
  static var allTests: [(String, (DowngradeTests) -> () throws -> Void)] = [
    ("testConfirmDowngrade", testConfirmDowngrade),
    ("testConfirmDowngradeLoggedOut", testConfirmDowngradeLoggedOut),
    ("testConfirmDowngradeNoSubscription", testConfirmDowngradeNoSubscription),
    ("testConfirmDowngradeInvalidSubscription", testConfirmDowngradeInvalidSubscription),
    ("testConfirmDowngradeCanceledSubscription", testConfirmDowngradeCanceledSubscription),
    ("testDowngrade", testDowngrade),
    ("testDowngradeLoggedOut", testDowngradeLoggedOut),
    ("testDowngradeNoSubscription", testDowngradeNoSubscription),
    ("testDowngradeInvalidSubscription", testDowngradeInvalidSubscription),
    ("testDowngradeCanceledSubscription", testDowngradeCanceledSubscription),
    ("testDowngradeStripeError", testDowngradeStripeError),
    ("testDowngradeEmail", testDowngradeEmail)
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
extension EpisodeTests {
  static var allTests: [(String, (EpisodeTests) -> () throws -> Void)] = [
    ("testEpisodePage", testEpisodePage),
    ("testEpisodePageSubscriber", testEpisodePageSubscriber),
    ("testFreeEpisodePage", testFreeEpisodePage),
    ("testFreeEpisodePageSubscriber", testFreeEpisodePageSubscriber),
    ("testEpisodeNotFound", testEpisodeNotFound)
  ]
}
extension HomeTests {
  static var allTests: [(String, (HomeTests) -> () throws -> Void)] = [
    ("testHomepage", testHomepage)
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
    ("testAcceptInvitation_CurrentUserIsInviter", testAcceptInvitation_CurrentUserIsInviter)
  ]
}
extension LaunchEmailTests {
  static var allTests: [(String, (LaunchEmailTests) -> () throws -> Void)] = [
    ("testLaunchEmail", testLaunchEmail)
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
extension NewEpisodeEmailTests {
  static var allTests: [(String, (NewEpisodeEmailTests) -> () throws -> Void)] = [
    ("testNewEpisodeEmail_Subscriber", testNewEpisodeEmail_Subscriber),
    ("testNewEpisodeEmail_NonSubscriber", testNewEpisodeEmail_NonSubscriber)
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
    ("testPricingLoggedIn_NonSubscriber", testPricingLoggedIn_NonSubscriber),
    ("testPricingLoggedIn_Subscriber", testPricingLoggedIn_Subscriber)
  ]
}
extension PrivacyTests {
  static var allTests: [(String, (PrivacyTests) -> () throws -> Void)] = [
    ("testPrivacy", testPrivacy)
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
extension StripeHookTests {
  static var allTests: [(String, (StripeHookTests) -> () throws -> Void)] = [
    ("testStripeInvoice", testStripeInvoice),
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
    ("testUpdateEmailSettings", testUpdateEmailSettings)
  ]
}
extension UpgradeTests {
  static var allTests: [(String, (UpgradeTests) -> () throws -> Void)] = [
    ("testConfirmUpgrade", testConfirmUpgrade),
    ("testConfirmUpgradeLoggedOut", testConfirmUpgradeLoggedOut),
    ("testConfirmUpgradeNoSubscription", testConfirmUpgradeNoSubscription),
    ("testConfirmUpgradeInvalidSubscription", testConfirmUpgradeInvalidSubscription),
    ("testConfirmUpgradeCanceledSubscription", testConfirmUpgradeCanceledSubscription),
    ("testUpgrade", testUpgrade),
    ("testUpgradeLoggedOut", testUpgradeLoggedOut),
    ("testUpgradeNoSubscription", testUpgradeNoSubscription),
    ("testUpgradeInvalidSubscription", testUpgradeInvalidSubscription),
    ("testUpgradeCanceledSubscription", testUpgradeCanceledSubscription),
    ("testUpgradeStripeError", testUpgradeStripeError),
    ("testUpgradeEmail", testUpgradeEmail)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AboutTests.allTests),
  testCase(AccountTests.allTests),
  testCase(AppleDeveloperMerchantIdDomainAssociationTests.allTests),
  testCase(AtomFeedTests.allTests),
  testCase(AuthTests.allTests),
  testCase(CancelTests.allTests),
  testCase(ChangeEmailConfirmationTests.allTests),
  testCase(ChangeSeatsTests.allTests),
  testCase(DatabaseTests.allTests),
  testCase(DowngradeTests.allTests),
  testCase(EitherIOTests.allTests),
  testCase(EmailInviteTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(HomeTests.allTests),
  testCase(HtmlCssInlinerTests.allTests),
  testCase(InviteTests.allTests),
  testCase(LaunchEmailTests.allTests),
  testCase(MetaLayoutTests.allTests),
  testCase(MinimalNavViewTests.allTests),
  testCase(NewEpisodeEmailTests.allTests),
  testCase(NewslettersTests.allTests),
  testCase(NotFoundMiddlewareTests.allTests),
  testCase(PaymentInfoTests.allTests),
  testCase(PricingTests.allTests),
  testCase(PrivacyTests.allTests),
  testCase(RegistrationEmailTests.allTests),
  testCase(SiteMiddlewareTests.allTests),
  testCase(StripeHookTests.allTests),
  testCase(StyleguideTests.allTests),
  testCase(SubscribeTests.allTests),
  testCase(TeamEmailsTests.allTests),
  testCase(UpdateProfileTests.allTests),
  testCase(UpgradeTests.allTests),
])
// swiftlint:enable trailing_comma
