import Dependencies

public struct Feature: Equatable {
  public var isAdminEnabled: Bool
  public var isEnabled: Bool
  public var allowedUserIDs: [User.ID] = []
  public var name: String

  public static let allFeatures: [Self] = [
    thePointFreeWay
  ]
  public static let thePointFreeWay = Self(
    isAdminEnabled: true,
    isEnabled: {
      #if DEBUG
      return true
      #else
      return false
      #endif
    }(),
    allowedUserIDs: [],
    name: "the-point-free-way"
  )
}

extension Array where Element == Feature {
  public func hasAccess(to feature: Feature, for user: User?) -> Bool {
    return
      self
      .first(where: { $0.name == feature.name })
      .map {
        $0.isEnabled
          || ($0.isAdminEnabled && user?.isAdmin == .some(true))
          || ((user?.id).map { feature.allowedUserIDs.contains($0) } ?? false)
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
