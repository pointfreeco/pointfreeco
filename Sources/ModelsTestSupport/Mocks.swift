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
}

fileprivate extension Date {
  static let mock = Date(timeIntervalSince1970: 1517356800)
}
