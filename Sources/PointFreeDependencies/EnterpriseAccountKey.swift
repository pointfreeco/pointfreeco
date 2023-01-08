import Dependencies
import Models

private enum EnterpriseAccountKey: DependencyKey {
  static let liveValue: EnterpriseAccount? = nil
  static let testValue: EnterpriseAccount? = nil
}
extension DependencyValues {
  public var enterpriseAccount: EnterpriseAccount? {
    get { self[EnterpriseAccountKey.self] }
    set { self[EnterpriseAccountKey.self] = newValue }
  }
}
