import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tuple
import View

// MARK: Middleware

let subscriptionChangeMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(
          .error,
          "Invalid subscription data. Please try again or contact <support@pointfree.co>."
        )
      )
    )
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireValidSeating
    <| map(lower)
    >>> subscriptionChange

private func subscriptionChange(_ conn: Conn<StatusLineOpen, (Stripe.Subscription, User, Int, Pricing)>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (currentSubscription, _, _, newPricing) = conn.data

    let newPrice = (defaultPricing(for: newPricing.lane, billing: newPricing.billing) * 100) * newPricing.quantity
    let currentPrice = currentSubscription.plan.amount(for:  currentSubscription.quantity).rawValue

    let shouldProrate = newPrice > currentPrice
    let shouldInvoice = newPricing.plan == currentSubscription.plan.id
      && newPricing.quantity > currentSubscription.quantity
      || shouldProrate
      && newPricing.interval == currentSubscription.plan.interval

    let tmp: IO<Either<Error, Stripe.Subscription>> = Current.stripe
      .updateSubscription(currentSubscription, newPricing.plan, newPricing.quantity, shouldProrate)
      .flatMap { sub -> EitherIO<Error, Stripe.Subscription> in
        if shouldInvoice {
          parallel(
            Current.stripe.invoiceCustomer(sub.customer.either(id, ^\.id))
              .withExcept(notifyError(subject: "Invoice Failed"))
              .run
            )
            .run(const(()))
        }

        return pure(sub)
      }
      .run

    return tmp
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(
                .error,
                """
                We couldn’t modify your subscription at this time. Please try again or contact
                <support@pointfree.co>.
                """
              )
            )
          )
        ) { _ in
          // TODO: Send email?

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "We’ve modified your subscription.")
          )
        }
    )
}

func requireActiveSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return filter(
      get1 >>> (^\.status == .active),
      or: redirect(
        to: .pricingLanding,
        headersMiddleware: flash(
          .error,
          "You don’t have an active subscription. Would you like to subscribe?"
        )
      )
      )
      <| middleware
}

private func requireValidSeating(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, User, Int, Pricing>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, User, Int, Pricing>, Data> {

    return filter(
      seatsAvailable,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(
          .error,
          "We can’t reduce the number of seats below the number that are active."
        )
      )
      )
      <| middleware
}

private func seatsAvailable(_ data: Tuple4<Stripe.Subscription, User, Int, Pricing>) -> Bool {
  let (_, _, seatsTaken, pricing) = lower(data)

  return pricing.quantity >= seatsTaken
}

private let extraStyles =
  ((input & .pseudo(.checked) ~ .star) > .star) % (
    color(Colors.black)
      <> fontWeight(.bold)
    )
    <> extraSpinnerStyles

private func fetchSeatsTaken<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<User, Int, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data> {

    return { conn -> IO<Conn<ResponseEnded, Data>> in
      let user = conn.data.first

      let invitesAndTeammates = sequence([
        parallel(Current.database.fetchTeamInvites(user.id).run)
          .map { $0.right?.count ?? 0 },
        parallel(Current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run)
          .map { $0.right?.count ?? 0 }
        ])

      return invitesAndTeammates
        .sequential
        .flatMap { middleware(conn.map(const(user .*. $0.reduce(0, +) .*. conn.data.second))) }
    }
}

private func defaultPricing(for lane: Pricing.Lane, billing: Pricing.Billing) -> Int {
  switch (lane, billing) {
  case (.personal, .monthly):
    return 18
  case (.personal, .yearly):
    return 168
  case (.team, .monthly):
    return 16
  case (.team, .yearly):
    return 144
  }
}
