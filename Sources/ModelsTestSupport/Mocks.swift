import Foundation
import Models
import Optics
import Prelude
import PointFreePrelude
import Stripe
import StripeTestSupport

extension EmailSetting {
  public static let mock = EmailSetting(
    newsletter: .newEpisode,
    userId: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
  )
}

extension EnterpriseAccount {
  public static let mock = EnterpriseAccount(
    companyName: "Blob Inc.",
    domain: "blob.biz",
    id: .init(rawValue: UUID(uuidString: "b10b17c1-b10b-17c1-b10b-17c1b10b17c1")!),
    subscriptionId: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
  )
}

extension EnterpriseEmail {
  public static let mock = EnterpriseEmail(
    id: .init(rawValue: UUID(uuidString: "48a7cdde-9cfd-4703-816b-dcf4d9c1ef9c")!),
    email: "blob@pointfree.co",
    userId: .init(rawValue: UUID(uuidString: "b10b17c1-b10b-17c1-b10b-17c1b10b17c1")!)
  )
}

extension EpisodeCredit {
  public static let mock = EpisodeCredit(
    episodeSequence: 1,
    userId: User.mock.id
  )
}

extension Models.Subscription {
  public static let mock = Subscription(
    id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    stripeSubscriptionId: Stripe.Subscription.mock.id,
    stripeSubscriptionStatus: .active,
    userId: User.mock.id
  )

  public static let canceled = mock
    |> \.stripeSubscriptionStatus .~ .canceled

  public static let pastDue = mock
    |> \.stripeSubscriptionStatus .~ .pastDue
}

extension TeamInvite {
  public static let mock = TeamInvite(
    createdAt: .mock,
    email: "blob@pointfree.co",
    id: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!),
    inviterUserId: .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
  )
}

extension Models.User {
  public static let mock = Models.User(
    email: "hello@pointfree.co",
    episodeCreditCount: 0,
    gitHubUserId: 1,
    gitHubAccessToken: "deadbeef",
    id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
    isAdmin: false,
    name: "Blob",
    rssSalt: .init(rawValue: UUID(uuidString: "00000000-5A17-0000-0000-000000000000")!),
    subscriptionId: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
  )

  public static let newUser = mock
    |> \.episodeCreditCount .~ 1
    |> \.subscriptionId .~ nil

  public static let owner = mock

  public static let teammate = mock
    |> \.id .~ .init(rawValue: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)

  public static let nonSubscriber = mock
    |> \.subscriptionId .~ nil

  public static let admin = mock
    |> \.isAdmin .~ true
    |> \.id .~ .init(rawValue: UUID(uuidString: "12121212-1212-1212-1212-121212121212")!)
}

fileprivate extension Date {
  static let mock = Date(timeIntervalSince1970: 1517356800)
}
