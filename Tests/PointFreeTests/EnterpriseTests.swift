import Database
import Either
import HttpPipeline
import Models
import ModelsTestSupport
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class EnterpriseTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testLanding_LoggedOut() {
    Current.database = .mock

    let account = EnterpriseAccount.mock

    Current.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))

    let req = request(to: .enterprise(.landing(account.domain)))
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 700)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 700))
        ]
      )
    }
    #endif
  }

  func testLanding_NonExistentEnterpriseAccount() {
    Current.database = .mock

    let account = EnterpriseAccount.mock

    Current.database.fetchEnterpriseAccountForDomain = const(throwE(unit))

    let req = request(to: .enterprise(.landing(account.domain)))
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLanding_AlreadySubscribedToEnterprise() {
    let subscriptionId = Subscription.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-012387451903")!)
    let account = EnterpriseAccount.mock
      |> \.subscriptionId .~ subscriptionId
    let user = User.mock
      |> (\User.subscriptionId) .~ subscriptionId

    Current.database = .mock
    Current.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))

    let req = request(to: .enterprise(.landing(account.domain)), session: .loggedIn(as: user))
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_LoggedOut() {
    Current.database = .mock

    let account = EnterpriseAccount.mock

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: "baddata", userId: "baddata")),
      session: .loggedOut
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_BadEmail() {
    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    let loggedInUser = User.mock
      |> \.id .~ userId
      |> \.subscriptionId .~ nil

    Current.database = .mock
      |> \.fetchEnterpriseAccountForDomain .~ const(pure(.some(account)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: "baddata", userId: encryptedUserId)),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_BadUserId() {
    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let loggedInUser = User.mock
      |> \.id .~ userId
      |> \.subscriptionId .~ nil

    Current.database = .mock
      |> \.fetchEnterpriseAccountForDomain .~ const(pure(.some(account)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: "baddata")),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_EmailDoesntMatchEnterpriseDomain() {
    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.biz", with: Current.envVars.appSecret)!
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    let loggedInUser = User.mock
      |> \.id .~ userId
      |> \.subscriptionId .~ nil

    Current.database = .mock
      |> \.fetchEnterpriseAccountForDomain .~ const(pure(.some(account)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: encryptedUserId)),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_RequesterUserDoesntMatchAccepterUserId() {
    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    let loggedInUser = User.mock
      |> \.id .~ User.Id(rawValue: UUID(uuidString: "DEADBEEF-0000-0000-0000-123456789012")!)

    Current.database = .mock
      |> \.fetchEnterpriseAccountForDomain .~ const(pure(.some(account)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: encryptedUserId)),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_EnterpriseAccountDoesntExist() {
    Current.database = Database.Client.mock
      |> \.fetchEnterpriseAccountForDomain .~ const(throwE(unit))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    let loggedInUser = User.mock
      |> \.id .~ User.Id(rawValue: UUID(uuidString: "DEADBEEF-0000-0000-0000-123456789012")!)

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: encryptedUserId)),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAccceptInvitation_HappyPath() {
    let account = EnterpriseAccount.mock
      |> \.domain .~ "pointfree.co"
    let encryptedEmail = Encrypted("blob@pointfree.co", with: Current.envVars.appSecret)!
    let userId = User.Id(rawValue: UUID(uuidString: "00000000-0000-0000-0000-123456789012")!)
    let encryptedUserId = Encrypted(userId.rawValue.uuidString, with: Current.envVars.appSecret)!
    let loggedInUser = User.mock
      |> \.id .~ userId
      |> \.subscriptionId .~ nil

    Current.database = .mock
      |> \.fetchEnterpriseAccountForDomain .~ const(pure(.some(account)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    let req = request(
      to: .enterprise(.acceptInvite(account.domain, email: encryptedEmail, userId: encryptedUserId)),
      session: .loggedIn(as: loggedInUser)
    )
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    // todo: more verifications that subscription was linked
  }

  // todo: flow for when user already has sub
  // todo: flow for when user has canceled sub
  // todo: flow for enterprise account that is past due
}
