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
    isEnabled: false && inDebug,
    allowedUserIDs: [],
    name: "the-point-free-way"
  )
}

#if DEBUG
  private let inDebug = true
#else
  private let inDebug = false
#endif

extension User {
  public func hasAccess(to feature: Feature) -> Bool {
    Optional(self).hasAccess(to: feature)
  }
}

extension Optional where Wrapped == User {
  public func hasAccess(to feature: Feature) -> Bool {
    @Dependency(\.features) var features
    guard let feature = features.first(where: { $0.name == feature.name })
    else { return false }
    return feature.isEnabled
      || (feature.isAdminEnabled && self?.isAdmin == .some(true))
      || ((self?.id).map { feature.allowedUserIDs.contains($0) } ?? false)
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
