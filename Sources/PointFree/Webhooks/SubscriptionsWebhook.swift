import Css
import Dependencies
import Either
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide

let stripeSubscriptionsWebhookMiddleware =
  validateStripeSignature
  <<< filterInvalidInvoices
  <<< requireSubscriptionId
  <| { conn in IO { await handleFailedPayment(conn) } }

private let filterInvalidInvoices:
  MT<Event<Either<Invoice, Stripe.Subscription>>, Event<Either<Invoice, Stripe.Subscription>>> =
    filter(
      {
        extraSubscriptionId(fromEvent: $0) == nil
          || $0.data.object.either({ $0.number != nil }, const(true))
      },
      or: writeStatus(.ok) >=> respond(text: "OK")
    )

private let requireSubscriptionId:
  MT<Event<Either<Invoice, Stripe.Subscription>>, Stripe.Subscription.ID> = filterMap(
    extraSubscriptionId(fromEvent:) >>> pure,
    or: stripeHookFailure(
      subject: "[PointFree Error] Stripe Hook Failed!",
      body: "Couldn't extract subscription id from event payload."
    )
  )

private func handleFailedPayment(
  _ conn: Conn<StatusLineOpen, Stripe.Subscription.ID>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.date.now) var now
  @Dependency(\.stripe) var stripe

  do {
    let stripeSubscription = try await stripe.fetchSubscription(conn.data)
    guard !stripeSubscription.status.isIncomplete else { return conn.head(.ok) }

    let subscription = try await database.updateStripeSubscription(stripeSubscription)

    if subscription.stripeSubscriptionStatus == .pastDue {
      let user = try await database.fetchUser(id: subscription.userId)

      await fireAndForget {
        try await sendPastDueEmail(to: user)
      }

      if stripeSubscription.quantity >= 3 {
        await fireAndForget {
          try await sendEmail(
            to: adminEmails,
            subject: "[PointFree Warning] Churning Subscription",
            content: inj1(
              """
              An important subscription is churning:

              - Owner: \(user.email.description)
              - Seats: \(stripeSubscription.quantity)
              - Subscriber since: \(stripeSubscription.created)
              """
            )
          )
        }
      }
    }
    return conn.head(.ok)
  } catch {
    await fireAndForget {
      try await sendEmail(
        to: adminEmails,
        subject: "[PointFree Error] Stripe Hook failed",
        content: inj1(String(customDumping: error))
      )
    }
    return conn.writeStatus(.badRequest).empty()
  }
}

private func sendPastDueEmail(to owner: User) async throws {
  try await sendEmail(
    to: [owner.email],
    subject: "Your subscription is past-due",
    content: inj2(pastDueEmailView(unit))
  )
}

let pastDueEmailView =
  simpleEmailLayout(pastDueEmailBodyView) <<< { unit in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription is past-due",
      preheader: "Your most recent payment was declined.",
      template: .default(),
      data: unit
    )
  }

private func pastDueEmailBodyView(_: Prelude.Unit) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "Payment failed"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            Your most recent subscription payment was declined. This could be due to a change in your card
            number, your card expiring, cancellation of your credit card, or the card issuer not recognizing
            the payment and therefore taking action to prevent it.
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            """
            Please update your payment info to ensure uninterrupted access to Point-Free!
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(siteRouter.url(for: .account(.paymentInfo()))),
                .class([Class.pf.components.button(color: .purple)]),
              ],
              "Update payment info"
            )
          )
        )
      )
    )
  )
}

private func extraSubscriptionId(
  fromEvent event: Event<Either<Invoice, Stripe.Subscription>>
) -> Stripe.Subscription.ID? {

  switch event.data.object {
  case let .left(invoice):
    return invoice.subscription
      ?? invoice.lines.data.compactMap(\.subscription).first
  case let .right(subscription):
    return subscription.id
  }
}
