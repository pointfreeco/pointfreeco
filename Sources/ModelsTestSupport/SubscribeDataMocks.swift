import Models

extension SubscribeData {
  public static let individualMonthly = SubscribeData(
    coupon: nil,
    isOwnerTakingSeat: true,
    pricing: .init(billing: .monthly, quantity: 1),
    teammates: [],
    token: "stripe-deadbeef"
  )

  public static let individualYearly = SubscribeData(
    coupon: nil,
    isOwnerTakingSeat: true,
    pricing: .init(billing: .yearly, quantity: 1),
    teammates: [],
    token: "stripe-deadbeef"
  )

  public static func teamYearly(quantity: Int) -> SubscribeData {
    return .init(
      coupon: nil,
      isOwnerTakingSeat: true,
      pricing: .init(billing: .yearly, quantity: quantity),
      teammates: [],
      token: "stripe-deadbeef"
    )
  }
}
