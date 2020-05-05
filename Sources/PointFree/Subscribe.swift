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
//      var subscribeData = subscribeData
//      subscribeData.useRegionCoupon = true

      let country = customer.sources.data.first?.left?.country

      guard country != nil || !subscribeData.useRegionCoupon else {
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

      guard !subscribeData.useRegionCoupon
        || discountedCountryCodes.contains(where: { $0.countryCode == country })
        else {
          // TODO: erroy, trying to use locale coupon but credit card is not in allowed country list
          return throwE(
            StripeErrorEnvelope(
              error: .init(
                message: """
                  Your credit card's country is not on the list of countries that qualify for a
                  regional discount. Please use a different credit card, or subscribe without the
                  discount.
                  """
              )
            )
          )
      }

      let localeCouponId = subscribeData.useRegionCoupon
        ? Current.envVars.regionalDiscountCouponId
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
  return subscribeData.coupon == nil
    || subscribeData.pricing.quantity == 1
    && subscribeData.coupon != Current.envVars.regionalDiscountCouponId
}

private func subscribeConfirmationWithSubscribeData(_ subscribeData: SubscribeData?) -> Route {
  guard let subscribeData = subscribeData else {
    return .subscribeConfirmation(
      lane: .team,
      billing: .yearly,
      isOwnerTakingSeat: true,
      teammates: [""],
      referralCode: nil,
      useRegionCoupon: false
    )
  }
  guard let coupon = subscribeData.coupon else {
    return .subscribeConfirmation(
      lane: subscribeData.pricing.isPersonal ? .personal : .team,
      billing: subscribeData.pricing.billing,
      isOwnerTakingSeat: subscribeData.isOwnerTakingSeat,
      teammates: subscribeData.teammates,
      referralCode: subscribeData.referralCode,
      useRegionCoupon: subscribeData.useRegionCoupon
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

struct DiscountCountry {
  var countryCode: String
  var name: String
}

let discountedCountryCodes = [
  DiscountCountry(countryCode: "AF", name: "Afghanistan"),
  DiscountCountry(countryCode: "AL", name: "Albania"),
  DiscountCountry(countryCode: "DZ", name: "Algeria"),
  DiscountCountry(countryCode: "AO", name: "Angola"),
  DiscountCountry(countryCode: "AG", name: "Antigua and Barbuda"),
  DiscountCountry(countryCode: "AR", name: "Argentina"),
  DiscountCountry(countryCode: "BS", name: "Bahamas"),
  DiscountCountry(countryCode: "BD", name: "Bangladesh"),
  DiscountCountry(countryCode: "BB", name: "Barbados"),
  DiscountCountry(countryCode: "BY", name: "Belarus"),
  DiscountCountry(countryCode: "BM", name: "Bermuda"),
  DiscountCountry(countryCode: "BZ", name: "Belize"),
  DiscountCountry(countryCode: "BJ", name: "Benin"),
  DiscountCountry(countryCode: "BO", name: "Bolivia"),
  DiscountCountry(countryCode: "BW", name: "Botswana"),
  DiscountCountry(countryCode: "BR", name: "*Brazil"),
  DiscountCountry(countryCode: "BG", name: "Bulgaria"),
  DiscountCountry(countryCode: "BF", name: "Burkina Faso"),
  DiscountCountry(countryCode: "BI", name: "Burundi"),
  DiscountCountry(countryCode: "CM", name: "Cameroon"),
  DiscountCountry(countryCode: "CV", name: "Cape Verde"),
  DiscountCountry(countryCode: "CF", name: "Central African Republic"),
  DiscountCountry(countryCode: "TD", name: "Chad"),
  DiscountCountry(countryCode: "CL", name: "Chile"),
  DiscountCountry(countryCode: "CO", name: "Colombia"),
  DiscountCountry(countryCode: "KM", name: "Comoros"),
  DiscountCountry(countryCode: "CG", name: "Democratic Republic of Congo"),
  DiscountCountry(countryCode: "CR", name: "Costa Rica"),
  DiscountCountry(countryCode: "HR", name: "Croatia"),
  DiscountCountry(countryCode: "CU", name: "Cuba"),
  DiscountCountry(countryCode: "DJ", name: "Djibouti"),
  DiscountCountry(countryCode: "DM", name: "Dominica"),
  DiscountCountry(countryCode: "DO", name: "Dominican Republic"),
  DiscountCountry(countryCode: "EC", name: "Ecuador"),
  DiscountCountry(countryCode: "EG", name: "Egypt"),
  DiscountCountry(countryCode: "SV", name: "El Salvador"),
  DiscountCountry(countryCode: "GQ", name: "Equatorial Guinea"),
  DiscountCountry(countryCode: "ER", name: "Eritrea"),
  DiscountCountry(countryCode: "ET", name: "Ethiopia"),
  DiscountCountry(countryCode: "FK", name: "Falkland Islands"),
  DiscountCountry(countryCode: "GF", name: "French Guiana"),
  DiscountCountry(countryCode: "GA", name: "Gabon"),
  DiscountCountry(countryCode: "GM", name: "Gambia"),
  DiscountCountry(countryCode: "GH", name: "Ghana"),
  DiscountCountry(countryCode: "GD", name: "Grenada"),
  DiscountCountry(countryCode: "GT", name: "Guatemala"),
  DiscountCountry(countryCode: "GN", name: "Guinea"),
  DiscountCountry(countryCode: "GW", name: "Guinea-Bissau"),
  DiscountCountry(countryCode: "GY", name: "Guyana"),
  DiscountCountry(countryCode: "HT", name: "Haiti"),
  DiscountCountry(countryCode: "HN", name: "Honduras"),
  DiscountCountry(countryCode: "IN", name: "*India"),
  DiscountCountry(countryCode: "ID", name: "Indonesia"),
  DiscountCountry(countryCode: "CI", name: "Ivory Coast"),
  DiscountCountry(countryCode: "JM", name: "Jamaica"),
  DiscountCountry(countryCode: "KE", name: "Kenya"),
  DiscountCountry(countryCode: "LA", name: "Laos"),
  DiscountCountry(countryCode: "LS", name: "Lesotho"),
  DiscountCountry(countryCode: "LR", name: "Liberia"),
  DiscountCountry(countryCode: "LY", name: "Libya"),
  DiscountCountry(countryCode: "MK", name: "Macedonia"),
  DiscountCountry(countryCode: "MG", name: "Madagascar"),
  DiscountCountry(countryCode: "MW", name: "Malawi"),
  DiscountCountry(countryCode: "ML", name: "Mali"),
  DiscountCountry(countryCode: "MR", name: "Mauritania"),
  DiscountCountry(countryCode: "MU", name: "Mauritius"),
  DiscountCountry(countryCode: "MA", name: "Morocco"),
  DiscountCountry(countryCode: "MZ", name: "Mozambique"),
  DiscountCountry(countryCode: "MM", name: "Myanmar"),
  DiscountCountry(countryCode: "NA", name: "Namibia"),
  DiscountCountry(countryCode: "NP", name: "Nepal"),
  DiscountCountry(countryCode: "NI", name: "Nicaragua"),
  DiscountCountry(countryCode: "NE", name: "Niger"),
  DiscountCountry(countryCode: "NG", name: "Nigeria"),
  DiscountCountry(countryCode: "PK", name: "Pakistan"),
  DiscountCountry(countryCode: "PA", name: "Panama"),
  DiscountCountry(countryCode: "PY", name: "Paraguay"),
  DiscountCountry(countryCode: "PE", name: "Peru"),
  DiscountCountry(countryCode: "PH", name: "Philippines"),
  DiscountCountry(countryCode: "PL", name: "Poland"),
  DiscountCountry(countryCode: "RO", name: "*Romania"),
  DiscountCountry(countryCode: "RW", name: "Rwanda"),
  DiscountCountry(countryCode: "SN", name: "Senegal"),
  DiscountCountry(countryCode: "SC", name: "Seychelles"),
  DiscountCountry(countryCode: "SL", name: "Sierra Leone"),
  DiscountCountry(countryCode: "SO", name: "Somalia"),
  DiscountCountry(countryCode: "ZA", name: "*South Africa"),
  DiscountCountry(countryCode: "GS", name: "South Georgia"),
  DiscountCountry(countryCode: "SD", name: "Sudan"),
  DiscountCountry(countryCode: "SR", name: "Suriname"),
  DiscountCountry(countryCode: "SZ", name: "Swaziland"),
  DiscountCountry(countryCode: "TZ", name: "Tanzania"),
  DiscountCountry(countryCode: "TG", name: "Togo"),
  DiscountCountry(countryCode: "TT", name: "Trinidad and Tobago"),
  DiscountCountry(countryCode: "TN", name: "Tunisia"),
  DiscountCountry(countryCode: "UG", name: "Uganda"),
  DiscountCountry(countryCode: "UA", name: "Ukraine"),
  DiscountCountry(countryCode: "UY", name: "Uruguay"),
  DiscountCountry(countryCode: "VE", name: "Venezuela"),
  DiscountCountry(countryCode: "VN", name: "Vietnam"),
  DiscountCountry(countryCode: "EH", name: "Western Sahara"),
  DiscountCountry(countryCode: "YE", name: "Yemen"),
  DiscountCountry(countryCode: "ZM", name: "Zambia"),
  DiscountCountry(countryCode: "ZW", name: "Zimbabwe"),
]
