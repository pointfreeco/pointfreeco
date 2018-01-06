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

let confirmChangeSeatsResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireTeamYearlySubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmChangeSeatsView,
      layoutData: { subscription, currentUser, seatsTaken in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (subscription, currentUser, seatsTaken),
          title: "Add or remove seats?"
        )
    }
)

let changeSeatsMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.subscription(.changeSeats(.show))),
        headersMiddleware: flash(.error, "Couldn’t change the number of seats on your subscription.")
      )
    )
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireTeamYearlySubscription
    <<< requireValidSeating
    <| changeSeats
    >-> redirect(
      to: .account(.index),
      headersMiddleware: flash(.notice, "We’ve changed the number of seats on your subscription.")
)

// MARK: -

private func changeSeats(_ conn: Conn<StatusLineOpen, Tuple4<Stripe.Subscription, Database.User, Int, Int>>)
  -> IO<Conn<StatusLineOpen, Prelude.Unit>> {

    let (subscription, _, seatsTaken, quantity) = lower(conn.data)

    // TODO: send emails
    return  AppEnvironment.current.stripe.updateSubscription(subscription, .teamYearly, quantity)
      .flatMap { sub -> EitherIO<Prelude.Unit, Stripe.Subscription> in
        if sub.quantity > subscription.quantity {
          parallel(AppEnvironment.current.stripe.invoiceCustomer(sub.customer).run)
            .run({ _ in })
        }

        return pure(sub)
      }
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

private func fetchSeatsTaken<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.User, Int, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return { conn -> IO<Conn<ResponseEnded, Data>> in
      let user = conn.data.first

      let invitesAndTeammates = sequence([
        parallel(AppEnvironment.current.database.fetchTeamInvites(user.id).run)
          .map { $0.right?.count ?? 0 },
        parallel(AppEnvironment.current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run)
          .map { $0.right?.count ?? 0 }
        ])

      return invitesAndTeammates
        .sequential
        .flatMap { middleware(conn.map(const(user .*. $0.reduce(0, +) .*. conn.data.second))) }
    }
}

private func requireValidSeating(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, Database.User, Int, Int>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, Database.User, Int, Int>, Data> {

    return filter(
      seatsAvailable,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "Can’t reduce number of seats that low.")
      )
      )
      <| middleware
}

private func seatsAvailable(_ data: Tuple4<Stripe.Subscription, Database.User, Int, Int>) -> Bool {
  let (_, _, seatsTaken, quantity) = lower(data)

  return quantity >= seatsTaken
}

// MARK: - Views

let confirmChangeSeatsView = View<(Stripe.Subscription, Database.User, Int)> { subscription, currentUser, seatsTaken in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView.view(unit)
          <> formRowView.view((subscription, seatsTaken))
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

private let formRowView = View<(Stripe.Subscription, Int)> { subscription, seatsTaken in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      p([
        "You are currently using ", text(String(seatsTaken)), " of ",
        text(String(subscription.quantity)), " seats available."
        ]),
      form([action(path(to: .account(.subscription(.changeSeats(.update(nil)))))), method(.post)], [
        input([
          type(.number),
          min(seatsTaken),
          max(Pricing.validTeamQuantities.upperBound),
          name("quantity"),
          step(1),
          value(clamp(Pricing.validTeamQuantities) <| subscription.quantity),
          `class`([numberSpinner, Class.pf.colors.fg.purple])
          ]),
        div([
          button(
            [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
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
    ])
}
