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
      headersMiddleware: flash(.notice, "We’ve modified your membership.")
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
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.stripe) var stripe

  return { conn in
    let (currentSubscription, newPricing) = conn.data

    return EitherIO {
      let planID = try await resolvePlanID(
        for: newPricing,
        currentSubscription: currentSubscription
      )
      let updatedSubscription = try await stripe
        .update(
          subscription: currentSubscription,
          planID: planID,
          quantity: newPricing.quantity
        )
      // Refetch authoritative state instead of persisting this mutation's
      // response after a newer concurrent website or Stripe-side change.
      let synchronized: SynchronizedStripeSubscription
      do {
        synchronized = try await synchronizeStripeSubscription(id: updatedSubscription.id)
      } catch {
        throw SubscriptionChangeError.membershipUpdatedButSynchronizationFailed(error)
      }

      switch synchronized.subscription.plan {
      case .max:
        guard newPricing.plan == .max, let currentUser
        else { break }
        await sendWelcomeEmail(to: currentUser, plan: .max)
      case .pro:
        break  // Downgrade cleanup is handled by reconciliation.
      }
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
        "You don’t have an active membership. Would you like to join Point-Free?"
      )
    )
  )
    <| middleware
}

func subscriptionModificationErrorMiddleware<A>(_ error: Error)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{
  let message: String
  switch error {
  case SubscriptionChangeError.membershipUpdatedButSynchronizationFailed:
    message =
      """
      Your membership change was applied, but we couldn’t refresh your account access. \
      Please reload your account or contact <support@pointfree.co>. Do not submit the change again.
      """
  case let PricingResolutionError.missingModernPrice(pricing)
    where pricing.isTeam && pricing.billing == .monthly:
    message = "Team monthly memberships are no longer available."
  case let stripeError as StripeErrorEnvelope:
    message = stripeError.error.message
  default:
    message =
      """
      We couldn’t modify your membership at this time. Please try again or contact
      <support@pointfree.co>.
      """
  }

  return { conn in
    conn
      |> redirect(
        to: .account(),
        headersMiddleware: flash(
          .error, message
        )
      )
  }
}

enum SubscriptionChangeError: Error {
  case membershipUpdatedButSynchronizationFailed(any Error)
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

func sendWelcomeEmail(
  to user: User,
  ownerName: String? = nil,
  plan: Pricing.Plan
) async {
  @Dependency(\.fireAndForget) var fireAndForget

  await fireAndForget {
    switch plan {
    case .max:
      _ = try await send(
        email: prepareEmailV2(
          to: [user.email],
          subject: "Welcome to Point-Free Max!",
          content: MaxWelcomeEmail(user: user, ownerName: ownerName)
        )
      )
    case .pro:
      _ = try await send(
        email: prepareEmailV2(
          to: [user.email],
          subject: "Welcome to Point-Free!",
          content: ProWelcomeEmail(user: user, ownerName: ownerName)
        )
      )
    }
  }
}
