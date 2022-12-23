import Css
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
  <| handleFailedPayment

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
)
  -> IO<Conn<ResponseEnded, Data>>
{

  return Current.stripe.fetchSubscription(conn.data)
    .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find stripe subscription."))
    .flatMap { stripeSubscription in
      EitherIO { try await Current.database.updateStripeSubscription(stripeSubscription) }
    }
    .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find updated subscription."))
    .flatMap { subscription in
      EitherIO { try await Current.database.fetchUserById(subscription.userId) }
        .withExcept(notifyError(subject: "Stripe Hook failed: Couldn't find user."))
        .map { ($0, subscription) }
    }
    .withExcept(notifyError(subject: "Stripe Hook failed for \(conn.data)"))
    .run
    .flatMap(
      either(const(conn |> writeStatus(.badRequest) >=> end)) { user, subscription in
        if subscription.stripeSubscriptionStatus == .pastDue {
          parallel(sendPastDueEmail(to: user).run)
            .run { _ in }
        }

        return conn |> writeStatus(.ok) >=> end
      }
    )
}

private func sendPastDueEmail(to owner: User)
  -> EitherIO<Error, SendEmailResponse>
{

  return sendEmail(
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
