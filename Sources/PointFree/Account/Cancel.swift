import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple
import View

// MARK: Middleware

let cancelMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filter(
      get1 >>> ^\.isRenewing,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Your subscription is already canceled!")
      )
    )
    <| map(lower)
    >>> cancel

let reactivateMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filter(
      get1 >>> ^\.isCanceling,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Your subscription can’t be reactivated!")
      )
    )
    <<< requireSubscriptionItem
    <| map(lower)
    >>> reactivate

// MARK: -

private func cancel(_ conn: Conn<StatusLineOpen, (Stripe.Subscription, Database.User)>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, user) = conn.data
    return Current.stripe.cancelSubscription(subscription.id)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.error, "We couldn’t cancel your subscription at this time.")
            )
          )
        ) { _ in
          parallel(sendCancelEmail(to: user, for: subscription).run)
            .run { _ in }

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "We’ve canceled your subscription.")
          )
        }
    )
}

private func reactivate(_ conn: Conn<StatusLineOpen, (Stripe.Subscription.Item, Stripe.Subscription, Database.User)>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (item, subscription, user) = conn.data
    return Current.stripe.updateSubscription(subscription, item.plan.id, item.quantity, nil)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.index),
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

          return conn |> redirect(
            to: .account(.index),
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
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription.Item, Stripe.Subscription, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return filterMap(
      { data in pure(data.first.items.data.first.map { $0 .*. data }) },
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, genericSubscriptionError))
      )
      <| middleware
}

func requireStripeSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return requireSubscriptionAndOwner
      <<< fetchStripeSubscription
      <<< filterMap(
        require1 >>> pure,
        or: redirect(
          to: .account(.index),
          headersMiddleware: flash(.error, genericSubscriptionError)
        )
      )
      <| middleware
}

private func requireSubscriptionAndOwner<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return fetchSubscription
      <<< filterMap(
        require1 >>> pure,
        or: redirect(
          to: .pricing(nil, expand: nil),
          headersMiddleware: flash(.error, "Doesn’t look like you’re subscribed yet!")
        )
      )
      <<< filter(
        isSubscriptionOwner,
        or: redirect(
          to: .account(.index),
          headersMiddleware: flash(.error, "Only subscription owners can make subscription changes.")
        )
      )
      <| middleware
}

func fetchSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription?, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return { conn in
      let subscription = Current.database.fetchSubscriptionByOwnerId(get1(conn.data).id)
        .mapExcept(requireSome)
        .run
        .map(^\.right)

      return subscription.flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
    }
}

private func isSubscriptionOwner<A>(_ subscriptionAndUser: T3<Database.Subscription, Database.User, A>)
  -> Bool {

    return get1(subscriptionAndUser).userId == get2(subscriptionAndUser).id
}

private func fetchStripeSubscription<A>(
  _ middleware: (@escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription?, A>, Data>)
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.Subscription, A>, Data> {

    return { conn in
      Current.stripe.fetchSubscription(conn.data.first.stripeSubscriptionId)
        .run
        .map(^\.right)
        .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
    }
}

// MARK: - Emails

private func sendCancelEmail(to owner: Database.User, for subscription: Stripe.Subscription)
  -> EitherIO<Error, Mailgun.SendEmailResponse> {

    return sendEmail(
      to: [owner.email],
      subject: "Your subscription has been canceled",
      content: inj2(cancelEmailView.view((owner, subscription)))
    )
}

let cancelEmailView = simpleEmailLayout(cancelEmailBodyView)
  .contramap { owner, subscription in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription has been canceled",
      preheader: """
      Your \(subscription.plan.name) subscription has been canceled and will remain active through
      \(dateFormatter.string(from: subscription.currentPeriodEnd)).
      """,
      template: .default,
      data: (owner, subscription)
    )
}

private let cancelEmailBodyView = View<(Database.User, Stripe.Subscription)> { user, subscription in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Subscription canceled"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Your ",
            strong([.text(subscription.plan.name)]),
            " subscription has been canceled and will remain active through ",
            .text(dateFormatter.string(from: subscription.currentPeriodEnd)),
            ". If you change your mind before then, you can reactivate from ",
            a([href(url(to: .account(.index)))], ["your account page"]),
            "."
            ])
          ])
        ])
      ])
    ])
}

private func sendReactivateEmail(to owner: Database.User, for subscription: Stripe.Subscription)
  -> EitherIO<Error, Mailgun.SendEmailResponse> {

    return sendEmail(
      to: [owner.email],
      subject: "Your subscription has been reactivated",
      content: inj2(reactivateEmailView.view((owner, subscription)))
    )
}

let reactivateEmailView = simpleEmailLayout(reactivateEmailBodyView)
  .contramap { owner, subscription in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Your subscription has been reactivated",
      preheader: "Your \(subscription.plan.name) subscription has been reactivated and will renew on \(dateFormatter.string(from: subscription.currentPeriodEnd)).",
      template: .default,
      data: (owner, subscription)
    )
}

private let reactivateEmailBodyView = View<(Database.User, Stripe.Subscription)> { user, subscription in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Subscription reactivated"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Thanks for sticking with us! Your ",
            strong([.text(subscription.plan.name)]),
            " subscription has been reactivated and will renew on ",
            .text(dateFormatter.string(from: subscription.currentPeriodEnd)),
            "."
            ])
          ])
        ])
      ])
    ])
}
