import Dependencies
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

let subscribeMiddleware =
  validateUser
  <<< validateSubscribeData
  <| map(lower)
  >>> { conn in IO { await subscribe(conn) } }

private let validateUser: MT<Tuple2<User?, SubscribeData?>, Tuple2<User, SubscribeData?>> =
  redirectActiveSubscribers(user: get1)
  <<< filterMap(require1 >>> pure, or: loginAndRedirectToPricing)

private let validateSubscribeData:
  MT<Tuple2<User, SubscribeData?>, Tuple3<User, SubscribeData, Referrer?>> =
    requireSubscribeData
    <<< validateQuantity
    <<< validateCoupon
    <<< validateReferrer

private func subscribe(
  _ conn: Conn<StatusLineOpen, (User, SubscribeData, Referrer?)>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  @Dependency(\.envVars) var envVars
  @Dependency(\.stripe) var stripe

  let (user, subscribeData, referrer) = conn.data
  let referrerDiscount: Cents<Int> =
    referrer?.stripeSubscription.discount?.coupon.id == envVars.regionalDiscountCouponId
    ? -9_00
    : -18_00
  let referredDiscount: Cents<Int> =
    subscribeData.useRegionalDiscount
    ? -9_00
    : -18_00

  do {
    let customer: Stripe.Customer
    let stripeSubscription: Stripe.Subscription

    if let stripeSubscriptionID = subscribeData.subscriptionID {
      stripeSubscription = try await stripe.fetchSubscription(stripeSubscriptionID)
      customer = try await stripe.fetchCustomer(stripeSubscription.customer.id)
    } else {
      customer = try await stripe.createCustomer(
        subscribeData.paymentMethodID,
        user.id.rawValue.uuidString,
        user.email,
        nil,
        subscribeData.pricing.interval == .year ? referrer.map(const(referredDiscount)) : nil
      )

      let paymentMethod = try await stripe.fetchPaymentMethod(subscribeData.paymentMethodID)
      let country = paymentMethod.card?.country
      guard country != nil || !subscribeData.useRegionalDiscount else {
        throw StripeErrorEnvelope(
          error: .init(
            message: """
              Couldn't verify issue country on credit card. Please try another credit card.
              """
          )
        )
      }

      guard
        !subscribeData.useRegionalDiscount
          || DiscountCountry.all.contains(where: { $0.countryCode == country })
      else {
        throw StripeErrorEnvelope(
          error: .init(
            message: """
              The issuing country of your credit card is not on the list of countries that
              qualify for a regional discount. Please use a different credit card, or subscribe
              without the discount.
              """
          )
        )
      }

      let regionalDiscountCouponId =
        subscribeData.useRegionalDiscount
        ? envVars.regionalDiscountCouponId
        : nil

      stripeSubscription = try await stripe.createSubscription(
        customer.id,
        subscribeData.pricing.billing.plan,
        subscribeData.pricing.quantity,
        subscribeData.coupon ?? regionalDiscountCouponId
      )
    }

    async let sendEmails = sendInviteEmails(inviter: user, subscribeData: subscribeData)
      .performAsync()

    if
      stripeSubscription.status == .incomplete,
      let paymentIntent = stripeSubscription.latestInvoice?.right?.paymentIntent?.right,
      paymentIntent.status == .requiresAction
    {
      return try conn.writeStatus(.ok).respond(
        json: [
          "clientSecret": paymentIntent.clientSecret.rawValue,
          "subscriptionID": stripeSubscription.id.rawValue,
          "requiresAction": true,
        ]
      )
    } else {
      _ = try await database.createSubscription(
        stripeSubscription,
        user.id,
        subscribeData.isOwnerTakingSeat,
        referrer?.user.id
      )

      if let referrer {
        async let updateReferrerBalance: Void = {
          _ = try await stripe.updateCustomerBalance(
            referrer.stripeSubscription.customer.id,
            (referrer.stripeSubscription.customer.right?.balance ?? 0) + referrerDiscount
          )
          Task { try await sendReferralEmail(to: referrer.user).performAsync() }
        }()

        async let updateReferredBalance: Void = {
          guard subscribeData.pricing.interval == .month
          else { return }
          _ = try await stripe.updateCustomerBalance(stripeSubscription.customer.id, referredDiscount)
        }()

        // TODO: Log errors?
        _ = try await (sendEmails, updateReferrerBalance, updateReferredBalance)
      }

      if conn.acceptJSON {
        return try conn.writeStatus(.ok).respond(
          json: ["success": true]
        )
      } else {
        return conn.redirect(to: .account()) {
          $0.flash(.notice, "You are now subscribed to Point-Free!")
        }
      }
    }
  } catch {
    let errorMessage =
      (error as? StripeErrorEnvelope)?.error.message
      ?? """
      Error creating subscription! If you believe you have been charged in error, please contact \
      <support@pointfree.co>.
      """

    if conn.acceptJSON {
      return try! conn.writeStatus(.ok).respond(
        json: ["error": errorMessage]
      )
    } else {
      return conn.redirect(to: subscribeConfirmationWithSubscribeData(subscribeData)) {
        $0.flash(.error, errorMessage)
      }
    }
  }
}

private func sendInviteEmails(inviter: User, subscribeData: SubscribeData) -> EitherIO<
  Error, Prelude.Unit
> {
  @Dependency(\.database) var database

  return lift(
    sequence(
      subscribeData.teammates
        .filter { email in email.rawValue.contains("@") && email != inviter.email }
        .prefix(subscribeData.pricing.quantity - (subscribeData.isOwnerTakingSeat ? 1 : 0))
        .map { email in
          EitherIO { try await database.insertTeamInvite(email, inviter.id) }
            .flatMap { invite in sendInviteEmail(invite: invite, inviter: inviter) }
            .run
            .parallel
        }
    )
    .sequential
  )
  .map(const(unit))
  .catch(const(pure(unit)))
}

private func sendReferralEmail(to referrer: User) -> EitherIO<Error, SendEmailResponse> {
  EitherIO {
    try await sendEmail(
      to: [referrer.email],
      subject: "You just got one month free!",
      content: inj2(referralEmailView(unit))
    )
  }
}

private func validateQuantity(_ pricing: Pricing) -> Bool {
  return !pricing.isTeam || Pricing.validTeamQuantities.contains(pricing.quantity)
}

private func loginAndRedirectToPricing<A>(
  _ conn: Conn<StatusLineOpen, A>
)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.siteRouter) var siteRouter

  return conn
    |> redirect(to: .login(redirect: siteRouter.url(for: .pricingLanding)))
}

private func validateCoupon(forSubscribeData subscribeData: SubscribeData) -> Bool {
  @Dependency(\.envVars) var envVars

  return subscribeData.coupon == nil
    // Do not allow using coupons on team subscriptions
    || subscribeData.pricing.quantity == 1
      // Do not allow using regional discount coupon id directly
      && subscribeData.coupon != envVars.regionalDiscountCouponId
}

private func validateCouponAndRegionalDiscount(
  forSubscribeData subscribeData: SubscribeData
) -> Bool {
  // Don't allow using coupon and regional discount at once
  subscribeData.coupon == nil || !subscribeData.useRegionalDiscount
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> SiteRoute {
  guard let subscribeData = subscribeData else {
    return .subscribeConfirmation(
      lane: .team,
      billing: .yearly,
      isOwnerTakingSeat: true,
      teammates: [""],
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
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData?>, Data> {
  return middleware
    |> filterMap(
      require2 >>> pure,
      or: redirect(
        with: get2 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "Error creating subscription!")
      )
    )
}

private func validateQuantity(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware
    |> filter(
      get2 >>> \.pricing >>> validateQuantity,
      or: redirect(
        with: get2 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(.error, "An invalid subscription quantity was used.")
      )
    )
}

private func validateCoupon(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return middleware
    |> filter(
      get2 >>> validateCoupon(forSubscribeData:),
      or: redirect(
        with: get2 >>> subscribeConfirmationWithSubscribeData,
        headersMiddleware: flash(
          .error, "Coupons can only be used on individual subscription plans.")
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
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, Tuple3<User, SubscribeData, Referrer?>, Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Tuple2<User, SubscribeData>, Data> {
  return { conn in
    @Dependency(\.database) var database
    @Dependency(\.stripe) var stripe

    let (user, subscribeData) = lower(conn.data)

    guard let referralCode = subscribeData.referralCode else {
      return middleware(conn.map(const(user .*. subscribeData .*. nil .*. unit)))
    }

    let isSubscribeDataValidForReferral =
      subscribeData.pricing.lane == .personal
      && user.referrerId == nil

    return EitherIO {
      guard isSubscribeDataValidForReferral else { throw unit }
      let referrer = try await database.fetchUserByReferralCode(referralCode)
      let subscription = try await database.fetchSubscriptionByOwnerId(referrer.id)
      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      return Referrer(user: referrer, stripeSubscription: stripeSubscription)
    }
    .run
    .flatMap(
      either(
        { _ in
          var subscribeData = subscribeData
          subscribeData.referralCode = nil
          return conn
            |> redirect(
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

extension Conn {
  var acceptJSON: Bool {
    self.request.value(forHTTPHeaderField: "Accept") == "application/json"
  }
}

extension Conn where Step == HeadersOpen {
  public func respond(json: [String: Any]) throws -> Conn<ResponseEnded, Data> {
    try self.respond(
      json: String(
        decoding: JSONSerialization.data(withJSONObject: json, options: .sortedKeys), as: UTF8.self
      )
    )
  }
}
