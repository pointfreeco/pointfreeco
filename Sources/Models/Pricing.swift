import Stripe

public struct Pricing: Equatable {
  public var billing: Billing
  public var quantity: Int

  public init(billing: Billing, quantity: Int) {
    self.billing = billing
    self.quantity = quantity
  }

  public static let `default` = Pricing(billing: .monthly, quantity: 1)

  public static let validTeamQuantities = 2..<100

  public enum Billing: String, CaseIterable, Codable {
    case monthly
    case yearly

    public var plan: Stripe.Plan.Id {
      switch self {
      case .monthly:
        return .monthly
      case .yearly:
        return .yearly
      }
    }
  }

  public enum Lane: String, CaseIterable, Codable {
    case personal
    case team
  }

  private enum CodingKeys: String, CodingKey {
    case billing
    case lane
    case quantity
  }

  public var interval: Stripe.Plan.Interval {
    switch self.billing {
    case .monthly:
      return .month
    case .yearly:
      return .year
    }
  }

  public var isPersonal: Bool {
    return self.lane == .personal
  }

  public var isTeam: Bool {
    return self.lane == .team
  }

  public var lane: Lane {
    return self.quantity == 1
      ? .personal
      : .team
  }
}

extension Pricing: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let lane = try container.decodeIfPresent(Lane.self, forKey: .lane)
    let billing = try container.decode(Billing.self, forKey: .billing)
    if lane == .some(.personal) {
      self.init(billing: billing, quantity: 1)
    } else {
      let quantity = try container.decode(Int.self, forKey: .quantity)
      self.init(billing: billing, quantity: quantity)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.lane, forKey: .lane)
    try container.encode(self.billing, forKey: .billing)
    try container.encode(self.quantity, forKey: .quantity)
  }
}
