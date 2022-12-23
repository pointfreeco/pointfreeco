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
import Tuple

// MARK: Middleware

let cancelMiddleware =
  requireUserAndStripeSubscription
  <<< filter(
    get1 >>> \.isRenewing,
    or: redirect(
      to: .account(),
      headersMiddleware: flash(.error, "Your subscription is already canceled!")
    )
  )
  <| map(lower)
  >>> cancel

let reactivateMiddleware =
  requireUserAndStripeSubscription
  <<< filter(
    get1 >>> \.isCanceling,
    or: redirect(
      to: .account(),
      headersMiddleware: flash(.error, "Your subscription can’t be reactivated!")
    )
  )
  <<< requireSubscriptionItem
  <| map(lower)
  >>> reactivate

private let requireUserAndStripeSubscription: MT<Tuple1<User?>, Tuple2<Stripe.Subscription, User>> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
  <<< requireStripeSubscription

// MARK: -

private func cancel(_ conn: Conn<StatusLineOpen, (Stripe.Subscription, User)>)
  -> IO<Conn<ResponseEnded, Data>>
{

  let (subscription, user) = conn.data
  return Current.stripe.cancelSubscription(subscription.id, subscription.status == .pastDue)
    .run
    .flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .account(),
              headersMiddleware: flash(.error, "We couldn’t cancel your subscription at this time.")
            )
        )
      ) { _ in
        parallel(sendCancelEmail(to: user, for: subscription).run)
          .run { _ in }

        return conn
          |> redirect(
            to: .account(),
            headersMiddleware: flash(.notice, "We’ve canceled your subscription.")
          )
      }
    )
}

private func reactivate(
  _ conn: Conn<StatusLineOpen, (Stripe.Subscription.Item, Stripe.Subscription, User)>
)
  -> IO<Conn<ResponseEnded, Data>>
{

  let (item, subscription, user) = conn.data
  return Current.stripe.updateSubscription(subscription, item.plan.id, item.quantity)
    .run
    .flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .account(),
              headersMiddleware: flash(
                .error,
                """
                We were unable to reactivate your subscription at this time. Please contact
                <support@pointfree.co> or subscribe from our pricing page.
                """
              )
            )
        )
      ) { _ in
        parallel(sendReactivateEmail(to: user, for: subscription).run)
          .run { _ in }

        return conn
          |> redirect(
            to: .account(),
            headersMiddleware: flash(.notice, "We’ve reactivated your subscription.")
          )
      }
    )
}

// MARK: - Transformers

let genericSubscriptionError = """
  We were unable to locate all of your subscription information. Please contact <support@pointfree.co> and let
  us know how we can help!
  """

func requireSubscriptionItem<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Stripe.Subscription.Item, Stripe.Subscription, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data>
{

  return filterMap(
    { data in pure(data.first.items.data.first.map { $0 .*. data }) },
    or: redirect(to: .account(), headersMiddleware: flash(.error, genericSubscriptionError))
  )
    <| middleware
}

func requireStripeSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return requireSubscriptionAndOwner
    <<< fetchStripeSubscription
    <<< filterMap(
      require1 >>> pure,
      or: redirect(
        to: .account(),
        headersMiddleware: flash(.error, genericSubscriptionError)
      )
    )
    <| middleware
}

private func requireSubscriptionAndOwner<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Models.Subscription, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return fetchSubscription
    <<< filterMap(
      require1 >>> pure,
      or: redirect(
        to: .pricingLanding,
        headersMiddleware: flash(.error, "Doesn’t look like you’re subscribed yet!")
      )
    )
    <<< filter(
      isSubscriptionOwner,
      or: redirect(
        to: .account(),
        headersMiddleware: flash(.error, "Only subscription owners can make subscription changes.")
      )
    )
    <| middleware
}

func fetchSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Models.Subscription?, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return { conn in
    let subscription = IO {
      try? await Current.database.fetchSubscriptionByOwnerId(get1(conn.data).id)
    }

    return subscription.flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
  }
}

private func isSubscriptionOwner<A>(_ subscriptionAndUser: T3<Models.Subscription, User, A>)
  -> Bool
{

  return get1(subscriptionAndUser).userId == get2(subscriptionAndUser).id
}

private func fetchStripeSubscription<A>(
  _ middleware: (
    @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription?, A>, Data>
  )
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Models.Subscription, A>, Data>
{

  return { conn in
    Current.stripe.fetchSubscription(conn.data.first.stripeSubscriptionId)
      .run
      .map(\.right)
      .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
  }
}

// MARK: - Emails

private func sendCancelEmail(to owner: User, for subscription: Stripe.Subscription)
  -> EitherIO<Error, SendEmailResponse>
{
  EitherIO {
    try await sendEmail(
      to: [owner.email],
      subject: "Your subscription has been canceled",
      content: inj2(cancelEmailView((owner, subscription)))
    )
  }
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

private func sendReactivateEmail(to owner: User, for subscription: Stripe.Subscription)
  -> EitherIO<Error, SendEmailResponse>
{
  EitherIO {
    try await sendEmail(
      to: [owner.email],
      subject: "Your subscription has been reactivated",
      content: inj2(reactivateEmailView((owner, subscription)))
    )
  }
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
