import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
@testable import Tuple

let confirmCancelResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireSubscription
    <<< requireSubscriptionOwner
    <<< requireStripeSubscription(^\.status != .canceled)
    <| writeStatus(.ok)
    >-> respond(confirmCancelView.contramap(lower))

let cancelMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireSubscription
    <<< requireSubscriptionOwner
    <<< requireStripeSubscription(^\.status != .canceled)
    <| map(lower)
    >>> { conn -> IO<Conn<StatusLineOpen, Prelude.Unit>> in
      let (subscription, data) = conn.data

      // TODO: send emails

      return AppEnvironment.current.stripe.cancelSubscription(subscription.id)
        .run
        .map(^\.right)
        .map(const(conn.map(const(unit))))
    }
    >-> redirect(to: .account)

let reactivateMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireSubscription
    <<< requireSubscriptionOwner
    <<< requireStripeSubscription(^\.cancelAtPeriodEnd)
    <| map(lower)
    >>> { conn -> IO<Conn<StatusLineOpen, Prelude.Unit>> in
      let (subscription, data) = conn.data

      // TODO: send emails

      return AppEnvironment.current.stripe.reactivateSubscription(subscription)
        .run
        .map(^\.right)
        .map(const(conn.map(const(unit))))
    }
    >-> redirect(to: .account)

func requireSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return { conn in
      let (currentUser, rest) = (conn.data.first, conn.data.second)
      let subscription = currentUser.subscriptionId
        .map {
          AppEnvironment.current.database.fetchSubscriptionById($0)
            .mapExcept(requireSome)
            .run
            .map(^\.right)
        }
        ?? pure(nil)

      return subscription.flatMap { sub in
        guard let sub = sub else {
          return conn
            |> writeStatus(.notFound)
            >-> respond(text: "Not subscribed :(")
        }
        return conn.map(const(.init(first: sub, second: .init(first: currentUser, second: rest))))
          |> middleware
      }
    }
}

func requireSubscriptionOwner<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data> {

    return { conn in
      guard conn.data.first.userId == conn.data.second.first.id else {
        return conn
          |> writeStatus(.notFound)
          >-> respond(text: "Not the subscription owner :(")
      }

      return conn |> middleware
    }
}

func requireStripeSubscription<A>(_ suchThat: @escaping (Stripe.Subscription) -> Bool)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data> {

    return { middleware in
      { conn in

        let (databaseSub, user, rest) = (conn.data.first, conn.data.second.first, conn.data.second.second)

        return AppEnvironment.current.stripe.fetchSubscription(databaseSub.stripeSubscriptionId)
          .run
          .map(^\.right)
          .flatMap { sub in

            guard let sub = sub, suchThat(sub) else {
              return conn
                |> writeStatus(.notFound)
                >-> respond(text: "Stripe subscription not found :(")
            }

            return conn.map(const(.init(first: sub, second: .init(first: user, second: rest))))
              |> middleware
        }
      }
    }
}

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
          <> footerView.view(unit)
      )
      ])
    ])
  ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
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
      form([action(path(to: .cancel)), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
          ["Cancel My Subscription"])
        ])
      ])
    ])
}
