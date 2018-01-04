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
    ("testConfirmCancel", testConfirmCancel)
  ]
}
extension ChangeEmailConfirmationTests {
  static var allTests: [(String, (ChangeEmailConfirmationTests) -> () throws -> Void)] = [
    ("testChangeEmailConfirmationEmail", testChangeEmailConfirmationEmail)
  ]
}
extension DatabaseTests {
  static var allTests: [(String, (DatabaseTests) -> () throws -> Void)] = [
    ("testCreate", testCreate)
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

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AccountTests.allTests),
  testCase(AuthTests.allTests),
  testCase(CancelTests.allTests),
  testCase(ChangeEmailConfirmationTests.allTests),
  testCase(DatabaseTests.allTests),
  testCase(EmailInviteTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(HomeTests.allTests),
  testCase(HtmlCssInlinerTests.allTests),
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
])
// swiftlint:enable trailing_comma
