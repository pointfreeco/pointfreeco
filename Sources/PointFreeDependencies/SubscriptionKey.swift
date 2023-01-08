import Dependencies
import Models

private enum SubscriptionKey: DependencyKey {
  static let liveValue: Models.Subscription? = nil
  static let testValue: Models.Subscription? = nil
}
extension DependencyValues {
  public var subscription: Models.Subscription? {
    get { self[SubscriptionKey.self] }
    set { self[SubscriptionKey.self] = newValue }
  }
}
