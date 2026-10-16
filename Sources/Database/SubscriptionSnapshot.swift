import Models

/// A short-lived optimistic concurrency token, not a durable subscription identifier.
public struct SubscriptionSnapshot: Decodable {
  public var subscription: Models.Subscription
  public var version: String

  public init(subscription: Models.Subscription, version: String) {
    self.subscription = subscription
    self.version = version
  }

  public init(from decoder: any Decoder) throws {
    self.subscription = try Models.Subscription(from: decoder)
    self.version = try decoder.container(keyedBy: CodingKeys.self)
      .decode(String.self, forKey: .version)
  }

  private enum CodingKeys: String, CodingKey {
    case version
  }
}
