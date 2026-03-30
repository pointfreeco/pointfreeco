import Css
import Dependencies
import Either
import Foundation
import FunctionalCss
import GitHub
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
import Views

func stripeSubscriptionsWebhookMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  event: Event<Either<Invoice, Stripe.Subscription>>
) async -> Conn<ResponseEnded, Data> {
  if let failure = validateStripeSignature(conn) { return failure }
  guard
    extraSubscriptionId(fromEvent: event) == nil
      || event.data.object.either({ $0.number != nil }, { _ in true })
  else {
    return conn.writeStatus(.ok).respond(text: "OK")
  }
  guard let subscriptionID = extraSubscriptionId(fromEvent: event) else {
    return stripeHookFailure(
      conn,
      subject: "[PointFree Error] Stripe Hook Failed!",
      body: "Couldn't extract subscription id from event payload."
    )
  }
  return await handleFailedPayment(conn, subscriptionID: subscriptionID)
}

private func handleFailedPayment(
  _ conn: Conn<StatusLineOpen, Void>,
  subscriptionID: Stripe.Subscription.ID
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.date.now) var now
  @Dependency(\.stripe) var stripe

  do {
    let stripeSubscription = try await stripe.fetchSubscription(subscriptionID)
    guard !stripeSubscription.status.isIncomplete else { return conn.head(.ok) }

    let subscription = try await database.updateStripeSubscription(stripeSubscription)

    if subscription.stripeSubscriptionStatus == .canceled
      || subscription.stripeSubscriptionStatus == .pastDue
    {
      await fireAndForget {
        await removeBetaAccess(for: subscription)
      }
    }

    if subscription.stripeSubscriptionStatus == .pastDue {
      let user = try await database.fetchUser(id: subscription.userId)

      await fireAndForget {
        try await sendPastDueEmail(to: user)
      }

      if stripeSubscription.quantity >= 3 {
        await fireAndForget {
          try await sendEmail(
            to: adminEmails,
            subject: "[PointFree Warning] Churning Membership",
            content: inj1(
              """
              An important membership is churning:

              - Owner: \(user.email.description)
              - Seats: \(stripeSubscription.quantity)
              - Member since: \(stripeSubscription.created)
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

func removeBetaAccess(for subscription: Models.Subscription) async {
  @Dependency(\.database) var database
  @Dependency(\.envVars.gitHub.betaPreviewsAccessToken) var gitHubAccessToken
  @Dependency(\.gitHub) var gitHub

  await withErrorReporting("Remove beta access") {
    let owner = try await database.fetchUser(id: subscription.userId)
    var users = [owner]
    if let teammates = try? await database.fetchSubscriptionTeammatesByOwnerId(owner.id) {
      users.append(contentsOf: teammates)
    }
    for user in users {
      guard
        let gitHubUser = try? await gitHub.fetchUserByUserID(user.gitHubUserId, gitHubAccessToken)
      else { continue }
      for beta in Beta.all {
        await withErrorReporting("Could not remove '\(user.gitHubUserId)' from '\(beta.repo)'") {
          try await gitHub.removeRepoCollaborator(
            owner: "pointfreeco",
            repo: beta.repo,
            username: gitHubUser.login,
            token: gitHubAccessToken
          )
        }
      }
    }
  }
}

private func sendPastDueEmail(to owner: User) async throws {
  try await sendEmail(
    to: [owner.email],
    subject: "Your membership is past-due",
    content: inj2(pastDueEmailView(unit))
  )
}

let pastDueEmailView =
  simpleEmailLayout(pastDueEmailBodyView) <<< { unit in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your membership is past-due",
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
            Your most recent membership payment was declined. This could be due to a change in your card
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
