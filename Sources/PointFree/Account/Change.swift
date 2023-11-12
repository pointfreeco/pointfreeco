import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple

// MARK: Middleware

let subscriptionChangeMiddleware =
  requireUserAndPricingAndSeats
  <<< fetchSeatsTaken
  <<< validateActiveSubscriptionAndSeating
  <| changeSubscription(
    error: subscriptionModificationErrorMiddleware,
    success: redirect(
      to: .account(),
      headersMiddleware: flash(.notice, "We’ve modified your subscription.")
    )
  )

private let requireUserAndPricingAndSeats: MT<Tuple2<User?, Pricing?>, Tuple2<User, Pricing>> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
  <<< filterMap(require2 >>> pure, or: invalidSubscriptionErrorMiddleware)

private let validateActiveSubscriptionAndSeating:
  MT<Tuple3<User, Int, Pricing>, (Stripe.Subscription, Pricing)> =
    requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireValidSeating

func changeSubscription(
  error: @escaping (Error) -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>,
  success: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>
) -> (Conn<StatusLineOpen, (Stripe.Subscription, Pricing)>)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.stripe) var stripe

  return { conn in
    let (currentSubscription, newPricing) = conn.data

    return EitherIO {
      try await stripe
        .update(
          subscription: currentSubscription,
          planID: newPricing.billing.plan,
          quantity: newPricing.quantity
        )
    }
    .run
    .flatMap(
      either(
        { conn.map(const(unit)) |> error($0) },
        const(success(conn.map(const(unit))))
      )
    )
  }
}

func requireActiveSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data>
{

  return filter(
    get1 >>> (\.status == .active),
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

func subscriptionModificationErrorMiddleware<A>(_ error: Error)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{

  return { conn in
    conn
      |> redirect(
        to: .account(),
        headersMiddleware: flash(
          .error,
          """
          We couldn’t modify your subscription at this time. Please try again or contact
          <support@pointfree.co>.
          """
        )
      )
  }
}

private func requireValidSeating(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, (Stripe.Subscription, Pricing), Data
  >
)
  -> Middleware<
    StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, User, Int, Pricing>, Data
  >
{

  return filter(
    seatsAvailable,
    or: redirect(
      to: .account(),
      headersMiddleware: flash(
        .error,
        "We can’t reduce the number of seats below the number that are active."
      )
    )
  )
    <| map { (get1($0), get4($0)) }
    >>> middleware
}

private func seatsAvailable(_ data: Tuple4<Stripe.Subscription, User, Int, Pricing>) -> Bool {
  let (_, _, seatsTaken, pricing) = lower(data)

  return pricing.quantity >= seatsTaken
}

private func fetchSeatsTaken<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<User, Int, A>, Data>
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{
  @Dependency(\.database) var database

  return { conn -> IO<Conn<ResponseEnded, Data>> in
    let user = conn.data.first

    let invitesAndTeammates = IO {
      async let invites = database.fetchTeamInvites(inviterID: user.id).count
      async let teammates = database.fetchSubscriptionTeammatesByOwnerId(user.id).count
      return ((try? await invites) ?? 0) + ((try? await teammates) ?? 0)
    }

    return
      invitesAndTeammates
      .flatMap { middleware(conn.map(const(user .*. $0 .*. conn.data.second))) }
  }
}
