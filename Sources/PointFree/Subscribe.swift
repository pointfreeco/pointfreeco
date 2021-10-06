import Either
import Foundation
import HttpPipeline
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Tuple
import Views

let subscribeMiddleware
  = validateUser
    <<< validateSubscribeData
    <| subscribe

private let validateUser
  : MT<Tuple2<User?, SubscribeData?>, Tuple2<User, SubscribeData?>>
  = redirectActiveSubscribers(user: get1)
    <<< filterMap(require1 >>> pure, or: loginAndRedirectToPricing)

private let validateSubscribeData
  : MT<Tuple2<User, SubscribeData?>, Tuple3<User, SubscribeData, Referrer?>>
  = requireSubscribeData
    <<< validateQuantity
    <<< validateCoupon
    <<< validateReferrer

private func subscribe(
  _ conn: Conn<StatusLineOpen, Tuple3<User, SubscribeData, Referrer?>>
) -> IO<Conn<ResponseEnded, Data>> {

  let (user, subscribeData, referrer) = lower(conn.data)
  let referrerDiscount: Cents<Int> =
    referrer?.stripeSubscription.discount?.coupon.id == Current.envVars.regionalDiscountCouponId
      ? -9_00
      : -18_00
  let referredDiscount: Cents<Int> = subscribeData.useRegionalDiscount
    ? -9_00
    : -18_00

  let stripeSubscription = Current.stripe.createCustomer(
    subscribeData.token,
    user.id.rawValue.uuidString,
    user.email,
    nil,
    subscribeData.pricing.interval == .year ? referrer.map(const(referredDiscount)) : nil
  )
    .flatMap { customer -> EitherIO<Error, Stripe.Subscription> in
      let country = customer.sources?.data.first?.left?.country

      guard country != nil || !subscribeData.useRegionalDiscount else {
        return throwE(
          StripeErrorEnvelope(
            error: .init(
              message: """
                Couldn't verify issue country on credit card. Please try another credit card.
                """
            )
          )
        )
      }

      guard !subscribeData.useRegionalDiscount
        || DiscountCountry.all.contains(where: { $0.countryCode == country })
        else {
          return throwE(
            StripeErrorEnvelope(
              error: .init(
                message: """
                  The issuing country of your credit card is not on the list of countries that
                  qualify for a regional discount. Please use a different credit card, or subscribe
                  without the discount.
                  """
              )
            )
          )
      }

      let regionalDiscountCouponId = subscribeData.useRegionalDiscount
        ? Current.envVars.regionalDiscountCouponId
        : nil

      return Current.stripe.createSubscription(
        customer.id,
        subscribeData.pricing.plan,
        subscribeData.pricing.quantity,
        subscribeData.coupon ?? regionalDiscountCouponId
      )
  }

  func runTasksFor(stripeSubscription: Stripe.Subscription) -> EitherIO<Error, Prelude.Unit> {
    let sendEmails = sendInviteEmails(inviter: user, subscribeData: subscribeData)
      .run.parallel

    let updateReferrerBalance = referrer
      .map {
        Current.stripe
          .updateCustomerBalance(
            $0.stripeSubscription.customer.either(id, ^\.id),
            ($0.stripeSubscription.customer.right?.balance ?? 0) + referrerDiscount
        )
          .flatMap(const(sendReferralEmail(to: $0.user)))
          .map(const(unit))
          .run.parallel
      }
      ?? pure(.right(unit))

    let updateReferredBalance =
      referrer != nil && subscribeData.pricing.interval == .month
        ? Current.stripe
          .updateCustomerBalance(stripeSubscription.customer.either(id, ^\.id), referredDiscount)
          .map(const(unit))
          .run.parallel
        : pure(.right(unit))

    let results = sequence([sendEmails, updateReferrerBalance, updateReferredBalance])

    // TODO: Log errors?
    return lift(results.sequential).map(const(unit))
  }

  let databaseSubscription = stripeSubscription
    .flatMap { stripeSubscription -> EitherIO<Error, Models.Subscription> in
      Current.database
        .createSubscription(
          stripeSubscription,
          user.id,
          subscribeData.isOwnerTakingSeat,
          referrer?.user.id
      )
        .mapExcept(requireSome)
        .flatMap { subscription in
          runTasksFor(stripeSubscription: stripeSubscription)
            .map(const(subscription))
      }
  }

  return databaseSubscription.run.flatMap(
    either(
      { error in
        let errorMessage = (error as? StripeErrorEnvelope)?.error.message
          ?? """
        Error creating subscription! If you believe you have been charged in error, please contact \
        <support@pointfree.co>.
        """
        return conn
          |> redirect(
            to: subscribeConfirmationWithSubscribeData(subscribeData),
            headersMiddleware: flash(.error, errorMessage)
        )
    },
      const(
        conn
          |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "You are now subscribed to Point-Free!")
        )
      )
    )
  )
}

private func sendInviteEmails(inviter: User, subscribeData: SubscribeData) -> EitherIO<Error, Prelude.Unit> {
  return lift(
    sequence(
      subscribeData.teammates
        .filter { email in email.rawValue.contains("@") && email != inviter.email }
        .prefix(subscribeData.pricing.quantity - (subscribeData.isOwnerTakingSeat ? 1 : 0))
        .map { email in
          Current.database.insertTeamInvite(email, inviter.id)
            .flatMap { invite in sendInviteEmail(invite: invite, inviter: inviter) }
            .run
            .parallel
    })
      .sequential
  )
    .map(const(unit))
    .catch(const(pure(unit)))
}

private func sendReferralEmail(to referrer: User) -> EitherIO<Error, SendEmailResponse> {

  sendEmail(
    to: [referrer.email],
    subject: "You just got one month free!",
    content: inj2(referralEmailView(unit))
  )
}

private func validateQuantity(_ pricing: Pricing) -> Bool {
  return !pricing.isTeam || Pricing.validTeamQuantities.contains(pricing.quantity)
}

private func loginAndRedirectToPricing<A>(
  _ conn: Conn<StatusLineOpen, A>
)
  -> IO<Conn<ResponseEnded, Data>> {

    return conn
      |> redirect(to: .login(redirect: url(to: .pricingLanding)))
}

private func validateCoupon(forSubscribeData subscribeData: SubscribeData) -> Bool {
  subscribeData.coupon == nil
    // Do not allow using coupons on team subscriptions
    || subscribeData.pricing.quantity == 1
    // Do not allow using regional discount coupon id directly
    && subscribeData.coupon != Current.envVars.regionalDiscountCouponId
}

private func validateCouponAndRegionalDiscount(
  forSubscribeData subscribeData: SubscribeData
) -> Bool {
  // Don't allow using coupon and regional discount at once
  subscribeData.coupon == nil || !subscribeData.useRegionalDiscount
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> Route {
  guard let subscribeData = subscribeData else {
    return .subscribeConfirmation(
      lane: .team,
      billing: .yearly,
      isOwnerTakingSeat: true,
      teammates: [""],
      referralCode: nil,
      useRegionalDiscount: false
    )
  }
  guard let coupon = subscribeData.coupon else {
    return .subscribeConfirmation(
      lane: subscribeData.pricing.isPersonal ? .personal : .team,
      billing: subscribeData.pricing.billing,
      isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
      teammates: subscribeData.teammates,
      referralCode: subscribeData.referralCode,
      useRegionalDiscount: subscribeData.useRegionalDiscount
    )
  }
  return .discounts(code: coupon, subscribeData.pricing.billing)
}

private func requireSubscribeData(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData?>, Data> {
  return middleware |> filterMap(
    require2 >>> pure,
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "Error creating subscription!")
    )
  )
}

private func validateQuantity(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware |> filter(
    get2 >>> ^\.pricing >>> validateQuantity,
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "An invalid subscription quantity was used.")
    )
  )
}

private func validateCoupon(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware
    |> filter(
      get2 >>> validateCoupon(forSubscribeData:),
      or: redirect(
        with: get2 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "Coupons can only be used on individual subscription plans.")
      )
    )
    |> filter(
      get2 >>> validateCouponAndRegionalDiscount(forSubscribeData:),
      or: redirect(
        with: get2 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "Coupons cannot be used with regional discounts.")
      )
  )
}

private func validateReferrer(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple3<User, SubscribeData, Referrer?>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return { conn in
    let (user, subscribeData) = lower(conn.data)

    guard let referralCode = subscribeData.referralCode else {
      return middleware(conn.map(const(user .*. subscribeData .*. nil .*. unit)))
    }

    let isSubscribeDataValidForReferral = subscribeData.pricing.lane == .personal
      && user.referrerId == nil

    let fetchReferrer = isSubscribeDataValidForReferral
      ? Current.database.fetchUserByReferralCode(referralCode)
      : throwE(unit as Error)

    return fetchReferrer
      .mapExcept(requireSome)
      .flatMap { referrer in
        Current.database.fetchSubscriptionByOwnerId(referrer.id)
          .mapExcept(requireSome)
          .flatMap {
            Current.stripe.fetchSubscription($0.stripeSubscriptionId).flatMap {
              $0.isCancellable
                ? pure(Referrer(user: referrer, stripeSubscription: $0))
                : throwE(unit as Error)
            }
        }
    }
    .run
    .flatMap(
      either(
        { _ in
          var subscribeData = subscribeData
          subscribeData.referralCode = nil
          return conn |> redirect(
            to: subscribeConfirmationWithSubscribeData(subscribeData),
            headersMiddleware: flash(.error, "Invalid referral code.")
          )
      },
        { referrer in middleware(conn.map(const(user .*. subscribeData .*. referrer .*. unit))) }
      )
    )
  }
}

struct Referrer {
  var user: Models.User
  var stripeSubscription: Stripe.Subscription
}
