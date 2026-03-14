import Stripe
import TaggedMoney

public struct Pricing: Equatable {
  public var billing: Billing
  public var plan: Plan
  public var quantity: Int

  public init(plan: Plan = .pro, billing: Billing, quantity: Int) {
    self.billing = billing
    self.plan = plan
    self.quantity = quantity
  }

  public static let `default` = Pricing(plan: .pro, billing: .monthly, quantity: 1)

  public static let validTeamQuantities = 2..<100

  public enum Billing: String, CaseIterable, Codable {
    case monthly
    case yearly

    public var plan: Stripe.Plan.ID {
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

  public enum Plan: String, CaseIterable, Codable {
    case max
    case pro
  }

  private enum CodingKeys: String, CodingKey {
    case billing
    case lane
    case plan
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

  public var isPro: Bool {
    self.plan == .pro
  }

  public var isTeam: Bool {
    return self.lane == .team
  }

  public var isYearlyOnly: Bool {
    self.plan == .max
  }

  public var lane: Lane {
    return self.quantity == 1
      ? .personal
      : .team
  }

  public var defaultPricing: Cents<Int> {
    self.modernPricing ?? self.legacyPricing
  }

  public var legacyPricing: Cents<Int> {
    switch (self.plan, self.lane, self.billing) {
    case (.max, .personal, .yearly):
      return 349_00
    case (.max, .team, .yearly):
      return 329_00
    case (.max, _, .monthly):
      return self.lane == .personal ? 349_00 : 329_00
    case (.pro, .personal, .monthly):
      return 18_00
    case (.pro, .personal, .yearly):
      return 168_00
    case (.pro, .team, .monthly):
      return 16_00
    case (.pro, .team, .yearly):
      return 144_00
    }
  }

  public var modernPricing: Cents<Int>? {
    switch (self.plan, self.lane, self.billing) {
    case (.max, .personal, .monthly), (.max, .team, .monthly):
      return nil
    case (.max, .personal, .yearly):
      return 349_00
    case (.max, .team, .yearly):
      return 329_00
    case (.pro, .personal, .monthly):
      return 24_00
    case (.pro, .personal, .yearly):
      return 216_00
    case (.pro, .team, .monthly):
      return nil
    case (.pro, .team, .yearly):
      return 192_00
    }
  }
}

extension Pricing: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let lane = try container.decodeIfPresent(Lane.self, forKey: .lane)
    let billing = try container.decode(Billing.self, forKey: .billing)
    let plan = try container.decodeIfPresent(Plan.self, forKey: .plan) ?? .pro
    if lane == .some(.personal) {
      self.init(plan: plan, billing: billing, quantity: 1)
    } else {
      let quantity = try container.decode(Int.self, forKey: .quantity)
      self.init(plan: plan, billing: billing, quantity: quantity)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.lane, forKey: .lane)
    try container.encode(self.billing, forKey: .billing)
    try container.encode(self.plan, forKey: .plan)
    try container.encode(self.quantity, forKey: .quantity)
  }
}

public extension Pricing {
  static let proTeamSavingsFeature = "Save 25% per member"
  static let maxTeamSavingsFeature = "Save $20 per member"

  static let maxExtraFeatures: [String] = [
    "Early access to beta tools, features, and new projects",
    "Attend office hours and private livestreams",
    "Help support the Point-Free ecosystem",
  ]

  static func proFeaturesMarkdown(
    allVideosCount: Int,
    theWayPath: String,
    livestreamsPath: String,
    regionalDiscountPath: String,
    educationalDiscountPath: String,
    includeDiscounts: Bool = true
  ) -> [String] {
    var features: [String] = [
      "Access to \"[The Point-Free Way](\(theWayPath))\"",
      "All \(allVideosCount) videos with transcripts",
      "Private podcast feed for offline viewing",
      "Past [livestreams](\(livestreamsPath)) on demand",
    ]

    if includeDiscounts {
      features.append(
        "[Regional](\(regionalDiscountPath)) and [educational](\(educationalDiscountPath)) discounts available"
      )
    }

    return features
  }

  static func maxFeaturesMarkdown(
    allVideosCount: Int,
    theWayPath: String,
    livestreamsPath: String,
    regionalDiscountPath: String,
    educationalDiscountPath: String,
    includeDiscounts: Bool = true
  ) -> [String] {
    proFeaturesMarkdown(
      allVideosCount: allVideosCount,
      theWayPath: theWayPath,
      livestreamsPath: livestreamsPath,
      regionalDiscountPath: regionalDiscountPath,
      educationalDiscountPath: educationalDiscountPath,
      includeDiscounts: includeDiscounts
    ) + maxExtraFeatures
  }
}
