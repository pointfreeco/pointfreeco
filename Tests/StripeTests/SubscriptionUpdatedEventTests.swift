import Either
import Foundation
import PointFreeTestSupport
import StripeTestSupport
import XCTest

@testable import Stripe

final class SubscriptionUpdatedEventTests: TestCase {
  func testDecodesCustomerSubscriptionUpdatedEvent() throws {
    // Start with an existing event type so the fixture still decodes on the old model
    // except for the newly supported wire-format event name.
    var subscription = Stripe.Subscription.mock
    subscription.plan = .modernMaxYearly
    subscription.items.data[0].plan = .modernMaxYearly
    let event = Event<Either<Invoice, Stripe.Subscription>>(
      data: .init(object: .right(subscription)),
      id: "evt_membership_updated",
      type: .customerSubscriptionDeleted
    )
    let encoded = try Stripe.jsonEncoder.encode(event)
    var payload = try XCTUnwrap(
      JSONSerialization.jsonObject(with: encoded) as? [String: Any]
    )
    payload["type"] = "customer.subscription.updated"
    let decoded = try Stripe.jsonDecoder.decode(
      Event<Either<Invoice, Stripe.Subscription>>.self,
      from: JSONSerialization.data(withJSONObject: payload)
    )

    XCTAssertEqual(decoded.id, "evt_membership_updated")
    XCTAssertEqual(decoded.type, .customerSubscriptionUpdated)
    guard case let .right(decodedSubscription) = decoded.data.object else {
      return XCTFail("Expected a subscription payload")
    }
    XCTAssertEqual(decodedSubscription, subscription)
  }
}
