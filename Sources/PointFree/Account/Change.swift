import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple

// MARK: Middleware

let subscriptionChangeMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple2<User?, Pricing?>,
  Data
  > =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(require2 >>> pure, or: invalidSubscriptionErrorMiddleware)
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireValidSeating
    <| changeSubscription(
      error: subscriptionModificationErrorMiddleware,
      success: redirect(
        to: .account(.index),
        headersMiddleware: flash(.notice, "We’ve modified your subscription.")
      )
)

func changeSubscription(
  error: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>,
  success: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>
  ) -> (Conn<StatusLineOpen, (Stripe.Subscription, Pricing)>)
  -> IO<Conn<ResponseEnded, Data>> {

    return { conn in
      let (currentSubscription, newPricing) = conn.data

      let newPrice = defaultPricing(for: newPricing).map { $0 * newPricing.quantity }
      let currentPrice = currentSubscription.plan.amount(for: currentSubscription.quantity)

      let shouldProrate = newPrice > currentPrice
      let shouldInvoice = newPricing.plan == currentSubscription.plan.id
        && newPricing.quantity > currentSubscription.quantity
        || shouldProrate
        && newPricing.interval == currentSubscription.plan.interval

      return Current.stripe
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
        .flatMap(
          either(
            const(error(conn.map(const(unit)))),
            const(success(conn.map(const(unit))))
          )
      )
    }
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

func subscriptionModificationErrorMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<ResponseEnded, Data>> {

  return conn |> redirect(
    to: .account(.index),
    headersMiddleware: flash(
      .error,
      """
      We couldn’t modify your subscription at this time. Please try again or contact
      <support@pointfree.co>.
      """
    )
  )
}

private func requireValidSeating(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (Stripe.Subscription, Pricing), Data>
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
      <| map(lower)
      >>> map({ subscription, _, _, pricing in (subscription, pricing) })
      >>> middleware
}

private func seatsAvailable(_ data: Tuple4<Stripe.Subscription, User, Int, Pricing>) -> Bool {
  let (_, _, seatsTaken, pricing) = lower(data)

  return pricing.quantity >= seatsTaken
}

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

private func defaultPricing(for pricing: Pricing) -> Cents<Int> {
  switch (pricing.lane, pricing.billing) {
  case (.personal, .monthly):
    return 18_00
  case (.personal, .yearly):
    return 168_00
  case (.team, .monthly):
    return 16_00
  case (.team, .yearly):
    return 144_00
  }
}
