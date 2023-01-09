import Dependencies
import Models

private enum CurrentUserKey: DependencyKey {
  static let liveValue: User? = nil
  static let testValue: User? = nil
}

extension DependencyValues {
  public var currentUser: User? {
    get { self[CurrentUserKey.self] }
    set { self[CurrentUserKey.self] = newValue }
  }
}
