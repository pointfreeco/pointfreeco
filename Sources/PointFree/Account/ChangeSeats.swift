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

let confirmChangeSeatsResponse =
  requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireTeamYearlySubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmChangeSeatsView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (subscription, currentUser),
          title: "Add or remove seats?"
        )
    }
)

let changeSeatsMiddleware =
  filterMap(
    require2 >>> pure,
    or: redirect(
      to: .account(.subscription(.changeSeats(.show))),
      headersMiddleware: flash(.error, "Couldn’t change the number of seats on your subscription.")
    )
    )
    // TODO: Get min/max number of seats
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireTeamYearlySubscription
    <| changeSeats
    >-> redirect(
      to: .account(.index),
      headersMiddleware: flash(.notice, "We’ve changed the number of seats on your subscription.")
)

// MARK: -

private func changeSeats(_ conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription, Database.User, Int>>)
  -> IO<Conn<StatusLineOpen, Prelude.Unit>> {

    // TODO: send emails
    return AppEnvironment.current.stripe.updateSubscription(get1(conn.data), .teamYearly, get3(conn.data))
      .run
      .map(const(conn.map(const(unit))))
}

private func reactivate(_ conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription.Item, Stripe.Subscription, Database.User>>)
  -> IO<Conn<StatusLineOpen, Prelude.Unit>> {

    let (item, subscription, _) = lower(conn.data)

    // TODO: send emails
    return AppEnvironment.current.stripe.updateSubscription(subscription, item.plan.id, item.quantity)
      .run
      .map(const(conn.map(const(unit))))
}

// MARK: - Transformers

private func requireTeamYearlySubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.plan.id.unwrap == Stripe.Plan.Id.teamYearly.unwrap),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "You aren’t enrolled in a team subscription.")
      )
      )
      <| middleware
}

// MARK: - Views

let confirmChangeSeatsView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
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
        h1([`class`([Class.pf.type.title2])], ["Add or remove seats?"])
        ])
      ])
    ])
}

private let formRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      form([action(path(to: .account(.subscription(.changeSeats(.update(nil)))))), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
          ["Change number of seats"]
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
