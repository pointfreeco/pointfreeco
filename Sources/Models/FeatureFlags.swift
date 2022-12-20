import Dependencies

public struct Feature: Equatable {
  public var isAdminEnabled: Bool
  public var isEnabled: Bool
  public var name: String

  public static let allFeatures: [Self] = []
}

extension Array where Element == Feature {
  public func hasAccess(to feature: Feature, for user: User?) -> Bool {
    return
      self
      .first(where: { $0.name == feature.name })
      .map {
        $0.isEnabled
          || ($0.isAdminEnabled && user?.isAdmin == .some(true))
      }
      ?? false
  }
}

extension Feature: DependencyKey {
  public static let liveValue = Feature.allFeatures
  public static let testValue = Feature.allFeatures
}

extension DependencyValues {
  public var features: [Feature] {
    get { self[Feature.self] }
    set { self[Feature.self] = newValue }
  }
}
