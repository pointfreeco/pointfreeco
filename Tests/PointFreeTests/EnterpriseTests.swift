import Database
import Dependencies
import Either
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class EnterpriseTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testLanding_LoggedOut() {
    let account = EnterpriseAccount.mock

    DependencyValues.withValues {
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
    } operation: {
      let req = request(to: .enterprise(account.domain))
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 700)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 700)),
          ]
        )
      }
#endif
    }
  }

  func testLanding_NonExistentEnterpriseAccount() {
    let account = EnterpriseAccount.mock

    DependencyValues.withValues {
      $0.database.fetchEnterpriseAccountForDomain = const(throwE(unit))
    } operation: {
      let req = request(to: .enterprise(account.domain))
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testLanding_AlreadySubscribedToEnterprise() {
    let subscriptionId = Subscription.ID(uuidString: "00000000-0000-0000-0000-012387451903")!
    var account = EnterpriseAccount.mock
    account.subscriptionId = subscriptionId
    var user = User.mock
    user.subscriptionId = subscriptionId

    DependencyValues.withValues {
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
    } operation: {
      let req = request(to: .enterprise(account.domain), session: .loggedIn(as: user))
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_LoggedOut() {
    let account = EnterpriseAccount.mock

    let req = request(
      to: .enterprise(account.domain, .acceptInvite(email: "baddata", userId: "baddata")),
      session: .loggedOut
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAcceptInvitation_BadEmail() {
    var account = EnterpriseAccount.mock
    account.domain = "pointfree.co"
    let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    var loggedInUser = User.mock
    loggedInUser.id = userId
    loggedInUser.subscriptionId = nil

    DependencyValues.withValues {
      $0.database = .mock
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      let req = request(
        to: .enterprise(account.domain, .acceptInvite(email: "baddata", userId: encryptedUserId)),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_BadUserId() {
    var account = EnterpriseAccount.mock
    account.domain = "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
    var loggedInUser = User.mock
    loggedInUser.id = userId
    loggedInUser.subscriptionId = nil

    DependencyValues.withValues {
      $0.database = .mock
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      let req = request(
        to: .enterprise(account.domain, .acceptInvite(email: encryptedEmail, userId: "baddata")),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_EmailDoesntMatchEnterpriseDomain() {
    var account = EnterpriseAccount.mock
    account.domain = "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.biz", with: Current.envVars.appSecret)!
    let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    var loggedInUser = User.mock
    loggedInUser.id = userId
    loggedInUser.subscriptionId = nil

    DependencyValues.withValues {
      $0.database = .mock
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      let req = request(
        to: .enterprise(
          account.domain, .acceptInvite(email: encryptedEmail, userId: encryptedUserId)),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_RequesterUserDoesntMatchAccepterUserId() {
    var account = EnterpriseAccount.mock
    account.domain = "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    var loggedInUser = User.mock
    loggedInUser.id = User.ID(uuidString: "DEADBEEF-0000-0000-0000-123456789012")!

    DependencyValues.withValues {
      $0.database = .mock
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      let req = request(
        to: .enterprise(
          account.domain, .acceptInvite(email: encryptedEmail, userId: encryptedUserId)),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_EnterpriseAccountDoesntExist() {
    DependencyValues.withValues {
      $0.database.fetchEnterpriseAccountForDomain = const(throwE(unit))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      var account = EnterpriseAccount.mock
      account.domain = "pointfree.co"
      let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
      let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
      let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
      var loggedInUser = User.mock
      loggedInUser.id = User.ID(uuidString: "DEADBEEF-0000-0000-0000-123456789012")!
      
      let req = request(
        to: .enterprise(
          account.domain, .acceptInvite(email: encryptedEmail, userId: encryptedUserId)),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAcceptInvitation_HappyPath() {
    var account = EnterpriseAccount.mock
    account.domain = "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.ID(uuidString: "00000000-0000-0000-0000-123456789012")!
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    var loggedInUser = User.mock
    loggedInUser.id = userId
    loggedInUser.subscriptionId = nil

    DependencyValues.withValues {
      $0.database = .mock
      $0.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))
      $0.database.fetchSubscriptionById = const(pure(nil))
    } operation: {
      let req = request(
        to: .enterprise(
          account.domain, .acceptInvite(email: encryptedEmail, userId: encryptedUserId)),
        session: .loggedIn(as: loggedInUser)
      )
      let conn = connection(from: req)
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }

    // todo: more verifications that subscription was linked
  }

  // todo: flow for when user already has sub
  // todo: flow for when user has canceled sub
  // todo: flow for enterprise account that is past due
}
