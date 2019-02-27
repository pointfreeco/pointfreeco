import Models

extension SubscribeData {
  public static let individualMonthly = SubscribeData(
    coupon: nil,
    pricing: .init(billing: .monthly, quantity: 1),
    token: "stripe-deadbeef",
    vatNumber: ""
  )

  public static let individualYearly = SubscribeData(
    coupon: nil,
    pricing: .init(billing: .yearly, quantity: 1),
    token: "stripe-deadbeef",
    vatNumber: ""
  )

  public static func teamYearly(quantity: Int) -> SubscribeData {
    return .init(
      coupon: nil,
      pricing: .init(billing: .yearly, quantity: quantity),
      token: "stripe-deadbeef",
      vatNumber: ""
    )
  }
}
