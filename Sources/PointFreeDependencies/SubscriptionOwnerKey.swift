import Dependencies
import Models

private enum SubscriptionOwnerKey: DependencyKey {
  static let liveValue: Models.User? = nil
  static let testValue: Models.User? = nil
}
extension DependencyValues {
  public var subscriptionOwner: Models.User? {
    get { self[SubscriptionOwnerKey.self] }
    set { self[SubscriptionOwnerKey.self] = newValue }
  }
}
