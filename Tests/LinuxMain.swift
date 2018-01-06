// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import PointFreeTests; @testable import StyleguideTests;
extension AccountTests {
  static var allTests: [(String, (AccountTests) -> () throws -> Void)] = [
    ("testAccount", testAccount),
    ("testAccountWithFlashNotice", testAccountWithFlashNotice),
    ("testAccountWithFlashWarning", testAccountWithFlashWarning),
    ("testAccountWithFlashError", testAccountWithFlashError),
    ("testAccountCancelingSubscription", testAccountCancelingSubscription),
    ("testAccountCanceledSubscription", testAccountCanceledSubscription)
  ]
}
extension AuthTests {
  static var allTests: [(String, (AuthTests) -> () throws -> Void)] = [
    ("testAuth", testAuth),
    ("testAuth_WithFetchAuthTokenFailure", testAuth_WithFetchAuthTokenFailure),
    ("testAuth_WithFetchUserFailure", testAuth_WithFetchUserFailure),
    ("testLogin", testLogin),
    ("testLoginWithRedirect", testLoginWithRedirect),
    ("testLogout", testLogout),
    ("testSecretHome_LoggedOut", testSecretHome_LoggedOut),
    ("testSecretHome_LoggedIn", testSecretHome_LoggedIn)
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
    ("testCancelCanceledSubscription", testCancelCanceledSubscription)
  ]
}
extension ChangeEmailConfirmationTests {
  static var allTests: [(String, (ChangeEmailConfirmationTests) -> () throws -> Void)] = [
    ("testChangeEmailConfirmationEmail", testChangeEmailConfirmationEmail)
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
    ("testChangeSeatsInvalidSeats", testChangeSeatsInvalidSeats)
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
    ("testDowngradeCanceledSubscription", testDowngradeCanceledSubscription)
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
extension LaunchSignupTests {
  static var allTests: [(String, (LaunchSignupTests) -> () throws -> Void)] = [
    ("testHome", testHome),
    ("testHome_SuccessfulSignup", testHome_SuccessfulSignup),
    ("testSignup", testSignup),
    ("testConfirmationEmail", testConfirmationEmail)
  ]
}
extension MetaLayoutTests {
  static var allTests: [(String, (MetaLayoutTests) -> () throws -> Void)] = [
    ("testMetaTagsWithStyleTag", testMetaTagsWithStyleTag)
  ]
}
extension NavViewTests {
  static var allTests: [(String, (NavViewTests) -> () throws -> Void)] = [
    ("testNav_LoggedOut", testNav_LoggedOut),
    ("testNav_LoggedIn_NonSubscriber", testNav_LoggedIn_NonSubscriber),
    ("testNav_LoggedIn_Subscriber", testNav_LoggedIn_Subscriber)
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
    ("testExpressUnsubscribe", testExpressUnsubscribe)
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
extension StyleguideTests {
  static var allTests: [(String, (StyleguideTests) -> () throws -> Void)] = [
    ("testStyleguide", testStyleguide),
    ("testDesignSystem", testDesignSystem),
    ("testPointFreeStyles", testPointFreeStyles)
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
    ("testUpgradeCanceledSubscription", testUpgradeCanceledSubscription)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AccountTests.allTests),
  testCase(AuthTests.allTests),
  testCase(CancelTests.allTests),
  testCase(ChangeEmailConfirmationTests.allTests),
  testCase(ChangeSeatsTests.allTests),
  testCase(DatabaseTests.allTests),
  testCase(DowngradeTests.allTests),
  testCase(EmailInviteTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(HomeTests.allTests),
  testCase(HtmlCssInlinerTests.allTests),
  testCase(InviteTests.allTests),
  testCase(LaunchEmailTests.allTests),
  testCase(LaunchSignupTests.allTests),
  testCase(MetaLayoutTests.allTests),
  testCase(NavViewTests.allTests),
  testCase(NewEpisodeEmailTests.allTests),
  testCase(NewslettersTests.allTests),
  testCase(PaymentInfoTests.allTests),
  testCase(PricingTests.allTests),
  testCase(RegistrationEmailTests.allTests),
  testCase(SiteMiddlewareTests.allTests),
  testCase(StyleguideTests.allTests),
  testCase(UpdateProfileTests.allTests),
  testCase(UpgradeTests.allTests),
])
// swiftlint:enable trailing_comma
