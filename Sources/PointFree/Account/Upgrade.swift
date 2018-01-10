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

let confirmUpgradeResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualMonthlySubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmUpgradeView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentSubscriptionStatus: subscription.status,
          currentUser: currentUser,
          data: (subscription, currentUser),
          title: "Upgrade to yearly billing?"
        )
    }
)

let upgradeMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualMonthlySubscription
    <| upgrade

// MARK: -

private func upgrade(_ conn: Conn<StatusLineOpen, Tuple2<Stripe.Subscription, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    // TODO: send emails
    return AppEnvironment.current.stripe.updateSubscription(get1(conn.data), .individualYearly, 1)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.upgrade(.show))),
              headersMiddleware: flash(.error, "We couldn’t change your subscription at this time.")
            )
          ),
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.notice, "We’ll start billing you yearly!")
            )
          )
        )
    )
}

// MARK: - Transformers

private func requireIndividualMonthlySubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.plan.id.unwrap == Stripe.Plan.Id.individualMonthly.unwrap),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Your subscription can’t be upgraded.")
      )
      )
      <| middleware
}

// MARK: - Views

let confirmUpgradeView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
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
        h1([`class`([Class.pf.type.title2])], ["Upgrade Subscription?"])
        ])
      ])
    ])
}

private let formRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      p([
        "You are currently enrolled in the ", text(subscription.plan.name), " plan. If you choose to ",
        "upgrade your subscription, you will begin to be billed yearly at the end of the current billing ",
        "cycle: ", text(dateFormatter.string(from: subscription.currentPeriodEnd)),
        "."
        ]),
      form([action(path(to: .account(.subscription(.upgrade(.update))))), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
          ["Bill me yearly"]
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
