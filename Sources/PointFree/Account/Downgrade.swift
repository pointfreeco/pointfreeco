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

let confirmDowngradeResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualYearlySubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmDowngradeView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentSubscriptionStatus: subscription.status,
          currentUser: currentUser,
          data: (subscription, currentUser),
          title: "Downgrade to monthly billing?"
        )
    }
)

let downgradeMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualYearlySubscription
    <| downgrade

// MARK: -

private func downgrade(_ conn: Conn<StatusLineOpen, Tuple2<Stripe.Subscription, Database.User>>)
  -> IO<Conn<ResponseEnded, Data>> {

    // TODO: send emails
    return AppEnvironment.current.stripe.updateSubscription(get1(conn.data), .individualMonthly, 1)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.downgrade(.show))),
              headersMiddleware: flash(.error, "We couldn’t change your subscription at this time.")
            )
          ),
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(.notice, "We’ll start billing you monthly!")
            )
          )
        )
    )
}

// MARK: - Transformers

func requireActiveSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.status == .active),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "You don’t have an active subscription!")
      )
      )
      <| middleware
}

private func requireIndividualYearlySubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.plan.id.unwrap == Stripe.Plan.Id.individualYearly.unwrap),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Your subscription can’t be downgraded.")
      )
      )
      <| middleware
}

// MARK: - Views

let confirmDowngradeView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
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
        h1([`class`([Class.pf.type.title2])], ["Downgrade Subscription?"])
        ])
      ])
    ])
}

private let formRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      p([
        "You are currently enrolled in the ", text(subscription.plan.name), " plan. If you choose to ",
        "downgrade your subscription, you will begin to be billed monthly at the end of the current billing ",
        "cycle", text(subscription.currentPeriodEnd.map { ": " + dateFormatter.string(from: $0) } ?? ""),
        "."
        ]),
      form([action(path(to: .account(.subscription(.downgrade(.update))))), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
          ["Bill me monthly"]
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
