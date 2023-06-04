import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe
import StripeTestSupport

extension EmailSetting {
  public static let mock = EmailSetting(
    newsletter: .newEpisode,
    userId: .init(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!
  )
}

extension EnterpriseAccount {
  public static let mock = EnterpriseAccount(
    companyName: "Blob Inc.",
    domain: "blob.biz",
    id: .init(uuidString: "b10b17c1-b10b-17c1-b10b-17c1b10b17c1")!,
    subscriptionId: .init(uuidString: "00000000-0000-0000-0000-000000000000")!
  )
}

extension EnterpriseEmail {
  public static let mock = EnterpriseEmail(
    id: .init(uuidString: "48a7cdde-9cfd-4703-816b-dcf4d9c1ef9c")!,
    email: "blob@pointfree.co",
    userId: .init(uuidString: "b10b17c1-b10b-17c1-b10b-17c1b10b17c1")!
  )
}

extension EpisodeCredit {
  public static let mock = EpisodeCredit(
    episodeSequence: 1,
    userId: User.mock.id
  )
}

extension Gift {
  public static let unfulfilled = Self(
    deliverAt: nil,
    delivered: false,
    fromEmail: "blob.sr@pointfree.co",
    fromName: "Blob Sr.",
    id: .init(rawValue: .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!),
    message: "Happy birthday, junior!",
    monthsFree: 3,
    stripePaymentIntentId: "pi_test",
    stripePaymentIntentStatus: .requiresPaymentMethod,
    stripeSubscriptionId: nil,
    toEmail: "blob.jr@pointfree.co",
    toName: "Blob Jr."
  )

  public static let fulfilled = update(unfulfilled) {
    $0.delivered = true
    $0.stripePaymentIntentStatus = .succeeded
    $0.stripeSubscriptionId = "sub_test"
  }
}

extension Models.Subscription {
  public static let mock = Subscription(
    deactivated: false,
    id: .init(uuidString: "00000000-0000-0000-0000-000000000000")!,
    isTeamInviteCodeEnabled: true,
    stripeSubscriptionId: Stripe.Subscription.mock.id,
    stripeSubscriptionStatus: .active,
    teamInviteCode: "cafed00d",
    userId: User.mock.id
  )

  public static let canceled = update(mock) {
    $0.stripeSubscriptionStatus = .canceled
  }

  public static let pastDue = update(mock) {
    $0.stripeSubscriptionStatus = .pastDue
  }
}

extension TeamInvite {
  public static let mock = TeamInvite(
    createdAt: .mock,
    email: "blob@pointfree.co",
    id: .init(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!,
    inviterUserId: .init(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!
  )
}

extension Models.User {
  public static let mock = Models.User(
    email: "hello@pointfree.co",
    episodeCreditCount: 0,
    gitHubUserId: 1,
    gitHubAccessToken: "deadbeef",
    id: .init(uuidString: "00000000-0000-0000-0000-000000000000")!,
    isAdmin: false,
    name: "Blob",
    referralCode: "deadbeef",
    referrerId: nil,
    rssSalt: .init(rawValue: "00000000-5A17-0000-0000-000000000000"),
    subscriptionId: .init(uuidString: "00000000-0000-0000-0000-000000000000")!
  )

  public static let newUser = update(mock) {
    $0.episodeCreditCount = 1
    $0.subscriptionId = nil
  }

  public static let owner = mock

  public static let teammate = update(mock) {
    $0.id = .init(uuidString: "11111111-1111-1111-1111-111111111111")!
  }

  public static let nonSubscriber = update(mock) {
    $0.subscriptionId = nil
  }

  public static let admin = update(mock) {
    $0.isAdmin = true
    $0.id = .init(uuidString: "12121212-1212-1212-1212-121212121212")!
  }
}

extension Date {
  fileprivate static let mock = Date(timeIntervalSince1970: 1_517_356_800)
}
