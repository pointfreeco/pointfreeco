// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import PointFreeTests; @testable import StyleguideTests;
extension AccountTests {
  static var allTests: [(String, (AccountTests) -> () throws -> Void)] = [
    ("testAccount", testAccount)
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
    ("testSecretHome_LoggedIn", testSecretHome_LoggedIn),
    ("testRegistrationEmail", testRegistrationEmail)
  ]
}
extension DatabaseTests {
  static var allTests: [(String, (DatabaseTests) -> () throws -> Void)] = [
    ("testCreate", testCreate)
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
extension PricingTests {
  static var allTests: [(String, (PricingTests) -> () throws -> Void)] = [
    ("testPricing", testPricing),
    ("testPricingLoggedIn", testPricingLoggedIn)
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

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AccountTests.allTests),
  testCase(AuthTests.allTests),
  testCase(DatabaseTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(HomeTests.allTests),
  testCase(LaunchSignupTests.allTests),
  testCase(MetaLayoutTests.allTests),
  testCase(NavViewTests.allTests),
  testCase(PricingTests.allTests),
  testCase(SiteMiddlewareTests.allTests),
  testCase(StyleguideTests.allTests),
])
// swiftlint:enable trailing_comma
