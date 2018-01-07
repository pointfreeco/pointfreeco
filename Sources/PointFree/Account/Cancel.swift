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

// MARK: Middleware

let confirmCancelResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filter(
      get1 >>> ^\.isRenewing,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Your subscription is already canceled!"))
    )
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmCancelView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentSubscriptionStatus: subscription.status,
          currentUser: currentUser,
          data: (subscription, currentUser),
          title: "Cancel your subscription?"
        )
    }
)

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
    <| cancel

let reactivateMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filter(
      get1 >>> ^\.cancelAtPeriodEnd,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Your subscription can’t be reactivated!")
      )
    )
    <<< requireSubscriptionItem
    <| reactivate

// MARK: -

private func cancel(_ conn: Conn<StatusLineOpen, Tuple2<Stripe.Subscription, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    // TODO: send emails
    return AppEnvironment.current.stripe.cancelSubscription(get1(conn.data).id)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.changeSeats(.show))),
              headersMiddleware: flash(.error, "We couldn’t cancel your subscription at this time.")
            )
          ),
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.notice, "We’ve canceled your subscription.")
            )
          )
        )
    )
}

private func reactivate(_ conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription.Item, Stripe.Subscription, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (item, subscription, _) = lower(conn.data)

    // TODO: send emails
    return AppEnvironment.current.stripe.updateSubscription(subscription, item.plan.id, item.quantity, nil)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.changeSeats(.show))),
              headersMiddleware: flash(.error, "We couldn’t reactivate your subscription at this time.")
            )
          ),
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.notice, "We’ve reactivated your subscription.")
            )
          )
        )
    )
}

// MARK: - Transformers

func requireSubscriptionItem<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription.Item, Stripe.Subscription, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return filterMap(
      { data in pure(data.first.items.data.first.map { $0 .*. data }) },
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Invalid subscription."))
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
          headersMiddleware: flash(.error, "Subscription not found in Stripe!")
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
          to: .account(.index),
          headersMiddleware: flash(.error, "You don’t have a subscription!")
        )
      )
      <<< filter(
        isSubscriptionOwner,
        or: redirect(
          to: .account(.index),
          headersMiddleware: flash(.error, "You aren’t the subscription owner!")
        )
      )
      <| middleware
}

private func fetchSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription?, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return { conn in
      let subscription = get1(conn.data).subscriptionId
        .map {
          AppEnvironment.current.database.fetchSubscriptionById($0)
            .mapExcept(requireSome)
            .run
            .map(^\.right)
        }
        ?? pure(nil)

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
      AppEnvironment.current.stripe.fetchSubscription(conn.data.first.stripeSubscriptionId)
        .run
        .map(^\.right)
        .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
    }
}

// MARK: - Views

let confirmCancelView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView.view(unit)
          <> formRowView.view(subscription)
      )
      ])
    ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Cancel Subscription?"])
        ])
      ])
    ])
}

private let formRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      p([
        "Your ", text(subscription.plan.name), " subscription is set to renew",
        text(subscription.currentPeriodEnd.map { " on " + dateFormatter.string(from: $0) } ?? ""),
        """
        . Should you choose to cancel your subscription, you will lose access to Point-Free on this date. You
        will not be billed at the end of the current period. You may reactivate your subscription at any time
        before the current period ends.
        """
        ]),
      form([action(path(to: .account(.subscription(.cancel(.update))))), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
          ["Cancel my subscription"]
        ),
        a(
          [
            href(path(to: .account(.index))),
            `class`([Class.pf.components.button(color: .black, style: .underline)])
          ],
          ["Never mind"]
        )
        ])
      ])
    ])
}
