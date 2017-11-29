// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

@testable import PointFreeTests; @testable import Styleguidetests;
extension AuthTests {
  static var allTests: [(String, (AuthTests) -> () throws -> Void)] = [
    ("testAuth", testAuth),
    ("testAuth_WithFetchAuthTokenFailure", testAuth_WithFetchAuthTokenFailure),
    ("testAuth_WithFetchUserFailure", testAuth_WithFetchUserFailure),
    ("testLogin", testLogin),
    ("testLogout", testLogout),
    ("testSecretHome_LoggedOut", testSecretHome_LoggedOut),
    ("testSecretHome_LoggedIn", testSecretHome_LoggedIn)
  ]
}
extension EnvVarTests {
  static var allTests: [(String, (EnvVarTests) -> () throws -> Void)] = [
    ("testEncoding", testEncoding),
    ("testDecoding", testDecoding)
  ]
}
extension EpisodeTests {
  static var allTests: [(String, (EpisodeTests) -> () throws -> Void)] = [
    ("testEpisodeHtml", testEpisodeHtml)
  ]
}
extension LaunchSignupTests {
  static var allTests: [(String, (LaunchSignupTests) -> () throws -> Void)] = [
    ("testHome", testHome),
    ("testHome_SuccessfulSignup", testHome_SuccessfulSignup),
    ("testSignup", testSignup)
  ]
}
extension MetaLayoutTests {
  static var allTests: [(String, (MetaLayoutTests) -> () throws -> Void)] = [
    ("testMetaTagsWithStyleTag", testMetaTagsWithStyleTag)
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
    ("test_DesignSystem", test_DesignSystem)
  ]
}
extension TestCase {
  static var allTests: [(String, (TestCase) -> () throws -> Void)] = [
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AuthTests.allTests),
  testCase(EnvVarTests.allTests),
  testCase(EpisodeTests.allTests),
  testCase(LaunchSignupTests.allTests),
  testCase(MetaLayoutTests.allTests),
  testCase(SiteMiddlewareTests.allTests),
  testCase(StyleguideTests.allTests),
  testCase(TestCase.allTests),
])
// swiftlint:enable trailing_comma
