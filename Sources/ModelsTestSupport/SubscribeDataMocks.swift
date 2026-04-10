import Models

extension SubscribeData {
  public static let individualMonthly = SubscribeData(
    coupon: nil,
    isOwnerTakingSeat: true,
    paymentMethodID: "pm_stripe-deadbeef",
    pricing: .init(plan: .pro, billing: .monthly, quantity: 1),
    referralCode: nil,
    subscriptionID: nil,
    teammates: [],
    useRegionalDiscount: false
  )

  public static let individualYearly = SubscribeData(
    coupon: nil,
    isOwnerTakingSeat: true,
    paymentMethodID: "pm_stripe-deadbeef",
    pricing: .init(plan: .pro, billing: .yearly, quantity: 1),
    referralCode: nil,
    subscriptionID: nil,
    teammates: [],
    useRegionalDiscount: false
  )

  public static func teamYearly(quantity: Int) -> SubscribeData {
    return .init(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_stripe-deadbeef",
      pricing: .init(plan: .pro, billing: .yearly, quantity: quantity),
      referralCode: nil,
      subscriptionID: nil,
      teammates: [],
      useRegionalDiscount: false
    )
  }
}
