import Dependencies
import Models

private enum SubscriberStateKey: DependencyKey {
  static let liveValue: SubscriberState = .nonSubscriber
  static let testValue: SubscriberState = .nonSubscriber
}
extension DependencyValues {
  public var subscriberState: SubscriberState {
    get { self[SubscriberStateKey.self] }
    set { self[SubscriberStateKey.self] = newValue }
  }
}
