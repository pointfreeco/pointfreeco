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

let discountedCountryCodes = ["US"]

private func subscribe(
  _ conn: Conn<StatusLineOpen, Tuple3<User, SubscribeData, Referrer?>>
) -> IO<Conn<ResponseEnded, Data>> {

    let referralDiscount: Cents<Int> = -18_00

    let (user, subscribeData, referrer) = lower(conn.data)

    let stripeSubscription = Current.stripe.createCustomer(
      subscribeData.token,
      user.id.rawValue.uuidString,
      user.email,
      nil,
      subscribeData.pricing.interval == .year ? referrer.map(const(referralDiscount)) : nil
    )
      .flatMap { customer -> EitherIO<Error, Stripe.Subscription> in
//        var subscribeData = subscribeData
//        subscribeData.useLocaleCoupon = true
        
        guard let country = customer.sources.data.first?.left?.country else {
          if subscribeData.useLocaleCoupon {
            // TODO: error, trying to use locale coupon but cannot verify country
          }
          //        return customer
          fatalError()
        }

        guard !subscribeData.useLocaleCoupon || discountedCountryCodes.contains(country)
          else {
            // TODO: erroy, trying to use locale coupon but credit card is not in allowed country list

            //        return customer
            fatalError()
        }

        let localeCouponId = subscribeData.useLocaleCoupon
        ? Stripe.Coupon.Id(rawValue: "luze225P")
        : nil

        return Current.stripe.createSubscription(
          customer.id,
          subscribeData.pricing.plan,
          subscribeData.pricing.quantity,
          subscribeData.coupon ?? localeCouponId
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
              ($0.stripeSubscription.customer.right?.balance ?? 0) + referralDiscount
          )
            .flatMap(const(sendReferralEmail(to: $0.user)))
            .map(const(unit))
            .run.parallel
        }
        ?? pure(.right(unit))

      let updateReferredBalance =
        referrer != nil && subscribeData.pricing.interval == .month
          ? Current.stripe
            .updateCustomerBalance(stripeSubscription.customer.either(id, ^\.id), referralDiscount)
            .map(const(unit))
            .run.parallel
          : pure(.right(unit))

      let results = sequence([sendEmails, updateReferrerBalance, updateReferredBalance])

      // TODO: Log errors?
      return lift(results.sequential).map(const(unit))
    }

    let databaseSubscription = stripeSubscription.flatMap { stripeSubscription -> EitherIO<Error, Models.Subscription> in
      Current.database
        .createSubscription(stripeSubscription, user.id, subscribeData.isOwnerTakingSeat, referrer?.user.id)
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
  return subscribeData.coupon == nil || subscribeData.pricing.quantity == 1
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> Route {
  guard let subscribeData = subscribeData else {
    return .subscribeConfirmation(
      lane: .team,
      billing: .yearly,
      isOwnerTakingSeat: true,
      teammates: [""],
      referralCode: nil
    )
  }
  guard let coupon = subscribeData.coupon else {
    return .subscribeConfirmation(
      lane: subscribeData.pricing.isPersonal ? .personal : .team,
      billing: subscribeData.pricing.billing,
      isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
      teammates: subscribeData.teammates,
      referralCode: subscribeData.referralCode
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
  return middleware |> filter(
    get2 >>> validateCoupon(forSubscribeData:),
    or: redirect(
      with: get2 >>> subscribeConfirmationWithSubscribeData,
      headersMiddleware: flash(.error, "Coupons can only be used on individual subscription plans.")
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
          // Alternatively, don't hit Stripe:
//          .flatMap { $0?.stripeSubscriptionStatus == .active ? pure(referrer) : throwE(unit as Error) }
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
