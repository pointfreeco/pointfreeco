import EmailAddress
import Foundation
import Stripe
import Tagged

public struct Gift: Decodable {
  public var deliverAt: Date?
  public var fromEmail: EmailAddress
  public var fromName: String
  public var id: Id
  public var message: String
  public var monthsFree: Int
  public var stripePaymentIntentId: PaymentIntent.Id
  public var stripeSubscriptionId: Stripe.Subscription.Id?
  public var toEmail: EmailAddress
  public var toName: String

  public init(
    deliverAt: Date?,
    fromEmail: EmailAddress,
    fromName: String,
    id: Id,
    message: String,
    monthsFree: Int,
    stripePaymentIntentId: PaymentIntent.Id,
    stripeSubscriptionId: Stripe.Subscription.Id?,
    toEmail: EmailAddress,
    toName: String
  ) {
    self.fromEmail = fromEmail
    self.fromName = fromName
    self.deliverAt = deliverAt
    self.id = id
    self.message = message
    self.monthsFree = monthsFree
    self.stripePaymentIntentId = stripePaymentIntentId
    self.stripeSubscriptionId = stripeSubscriptionId
    self.toEmail = toEmail
    self.toName = toName
  }

  public typealias Id = Tagged<Self, UUID>
}
