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
import Tuple

let cancelMiddleware = requireUserAndStripeSubscription(cancelResponse)

let reactivateMiddleware = requireUserAndStripeSubscription(reactivateResponse)

// MARK: Middleware

private func cancelResponse(
  _ conn: Conn<StatusLineOpen, (User, Stripe.Subscription)>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.fireAndForget) var fireAndForget
  @Dependency(\.stripe) var stripe

  do {
    let (user, stripeSubscription) = conn.data
    guard stripeSubscription.isRenewing
    else {
      return conn.redirect(to: .account()) {
        $0.flash(.error, "Your subscription is already canceled!")
      }
    }
    _ =
      try await stripe
      .cancelSubscription(stripeSubscription.id, stripeSubscription.status == .pastDue)
    await fireAndForget {
      try await sendCancelEmail(to: user, for: stripeSubscription)
    }
    return conn.redirect(to: .account()) {
      $0.flash(.notice, "We’ve canceled your subscription.")
    }
  } catch {
    return conn.redirect(to: .account()) {
      $0.flash(.error, "We couldn’t cancel your subscription at this time.")
    }
  }
}

private func reactivateResponse(
  _ conn: Conn<StatusLineOpen, (User, Stripe.Subscription)>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.stripe) var stripe

  do {
    let (user, stripeSubscription) = conn.data
    guard stripeSubscription.isCanceling
    else {
      return conn.redirect(to: .account()) {
        $0.flash(.error, "Your subscription can’t be reactivated!")
      }
    }
    guard let item = stripeSubscription.items.data.first
    else {
      return conn.redirect(to: .account()) { $0.flash(.error, genericSubscriptionError) }
    }
    _ = try await stripe.updateSubscription(stripeSubscription, item.plan.id, item.quantity)
    Task { try await sendReactivateEmail(to: user, for: stripeSubscription) }
    return conn.redirect(to: .account()) {
      $0.flash(.notice, "We’ve reactivated your subscription.")
    }
  } catch {
    return conn.redirect(to: .account()) {
      $0.flash(
        .error,
        """
        We were unable to reactivate your subscription at this time. Please contact \
        <support@pointfree.co> or subscribe from our pricing page.
        """
      )
    }
  }
}

private func requireUserAndStripeSubscription(
  _ middleware: @escaping (Conn<StatusLineOpen, (User, Stripe.Subscription)>) async -> Conn<
    ResponseEnded, Data
  >
) -> (Conn<StatusLineOpen, User?>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  return { conn in
    guard let user = conn.data
    else { return conn.loginAndRedirect() }

    guard let subscription = try? await database.fetchSubscriptionByOwnerId(user.id)
    else {
      return conn.redirect(to: .account()) {
        $0.flash(.error, "Doesn’t look like you’re subscribed yet!")
      }
    }

    guard
      let stripeSubscription =
        try? await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
    else {
      return conn.redirect(to: .account()) {
        $0.flash(.error, genericSubscriptionError)
      }
    }

    return await middleware(conn.map { _ in (user, stripeSubscription) })
  }
}

let genericSubscriptionError = """
  We were unable to locate all of your subscription information. Please contact \
  <support@pointfree.co> and let us know how we can help!
  """

// MARK: - Emails

@discardableResult
private func sendCancelEmail(
  to owner: User, for subscription: Stripe.Subscription
) async throws -> SendEmailResponse {
  try await sendEmail(
    to: [owner.email],
    subject: "Your subscription has been canceled",
    content: inj2(cancelEmailView((owner, subscription)))
  )
}

let cancelEmailView =
  simpleEmailLayout(cancelEmailBodyView) <<< { owner, subscription in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription has been canceled",
      preheader: """
        Your \(subscription.plan.description) subscription has been canceled and will remain active through
        \(monthDayYearFormatter.string(from: subscription.currentPeriodEnd)).
        """,
      template: .default(),
      data: (owner, subscription)
    )
  }

private func cancelEmailBodyView(user: User, subscription: Stripe.Subscription) -> Node {
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
            "Subscription canceled"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "Your ",
            .strong(.text(subscription.plan.description)),
            " subscription has been canceled and will remain active through ",
            .text(monthDayYearFormatter.string(from: subscription.currentPeriodEnd)),
            ". If you change your mind before then, you can reactivate from ",
            .a(attributes: [.href(siteRouter.url(for: .account()))], "your account page"),
            "."
          )
        )
      )
    )
  )
}

@discardableResult
private func sendReactivateEmail(
  to owner: User, for subscription: Stripe.Subscription
) async throws -> SendEmailResponse {
  try await sendEmail(
    to: [owner.email],
    subject: "Your subscription has been reactivated",
    content: inj2(reactivateEmailView((owner, subscription)))
  )
}

let reactivateEmailView =
  simpleEmailLayout(reactivateEmailBodyView) <<< { owner, subscription in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription has been reactivated",
      preheader:
        "Your \(subscription.plan.description) subscription has been reactivated and will renew on \(monthDayYearFormatter.string(from: subscription.currentPeriodEnd)).",
      template: .default(),
      data: (owner, subscription)
    )
  }

private func reactivateEmailBodyView(user: User, subscription: Stripe.Subscription) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])],
            "Subscription reactivated"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "Thanks for sticking with us! Your ",
            .strong(.text(subscription.plan.description)),
            " subscription has been reactivated and will renew on ",
            .text(monthDayYearFormatter.string(from: subscription.currentPeriodEnd)),
            "."
          )
        )
      )
    )
  )
}
