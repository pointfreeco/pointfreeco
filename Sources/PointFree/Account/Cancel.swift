import Css
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
  requireStripeSubscription
    <<< filter(
      get1 >>> isActive,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Your subscription is already canceled!"))
    )
    <| writeStatus(.ok)
    >-> respond(confirmCancelView.contramap(lower))

let cancelMiddleware =
  requireStripeSubscription
    <<< filter(
      get1 >>> isActive,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Your subscription is already canceled!"))
    )
    <| cancel
    >-> redirect(to: .account(.index), headersMiddleware: flash(.notice, "We’ve canceled your subscription."))

let reactivateMiddleware =
  requireStripeSubscription
    <<< filter(
      get1 >>> ^\.cancelAtPeriodEnd,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Your subscription can’t be reactivated!"))
    )
    <| reactivate
    >-> redirect(to: .account(.index), headersMiddleware: flash(.notice, "We’ve reactivated your subscription."))

// MARK: -

private func cancel(_ conn: Conn<StatusLineOpen, Tuple2<Stripe.Subscription, Database.User>>)
  -> IO<Conn<StatusLineOpen, Prelude.Unit>> {

    // TODO: send emails
    return AppEnvironment.current.stripe.cancelSubscription(get1(conn.data).id)
      .run
      .map(const(conn.map(const(unit))))
}

private func reactivate(_ conn: Conn<StatusLineOpen, Tuple2<Stripe.Subscription, Database.User>>)
  -> IO<Conn<StatusLineOpen, Prelude.Unit>> {

  // TODO: send emails
  return AppEnvironment.current.stripe.reactivateSubscription(get1(conn.data))
    .run
    .map(const(conn.map(const(unit))))
}

// MARK: - Transformers

func requireStripeSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {
    
    return filterMap(require1 >>> pure, or: loginAndRedirect)
      <<< requireSubscriptionAndOwner
      <<< fetchStripeSubscription
      <<< filterMap(
        require1 >>> pure,
        or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Subscription not found in Stripe!"))
      )
      <| middleware
}

private func isActive(_ subscription: Stripe.Subscription) -> Bool {
  return subscription.status != .canceled && !subscription.cancelAtPeriodEnd
}

private func requireSubscriptionAndOwner<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return fetchSubscription
      <<< filterMap(
        require1 >>> pure,
        or: redirect(to: .account(.index), headersMiddleware: flash(.error, "You don’t have a subscription!"))
      )
      <<< filter(
        isSubscriptionOwner,
        or: redirect(to: .account(.index), headersMiddleware: flash(.error, "You aren’t the subscription owner!"))
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

private func isSubscriptionOwner<A>(_ subscriptionAndUser: T3<Database.Subscription, Database.User, A>) -> Bool {
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
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(render(config: pretty, css: pricingExtraStyles)),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(
        darkNavView.view((currentUser, nil))
          <> [
            gridRow([
              gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
                div(
                  [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
                  titleRowView.view(unit)
                    <> formRowView.view(subscription)
                )
              ])
          ]
          <> footerView.view(nil)
      )
      ])
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
