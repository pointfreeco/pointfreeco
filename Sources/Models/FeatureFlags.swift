import Dependencies
import Foundation

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
    isEnabled: inDebug,
    allowedUserIDs: [
      User.ID(UUID(uuidString: "b0fdb3e8-e2ca-11ec-a019-1fddd3f5ae5a")!),
      User.ID(UUID(uuidString: "ccb77370-a3fa-11ed-b47b-237e7b5f06b0")!),
      User.ID(UUID(uuidString: "06b0c90e-ca1e-11eb-af27-7f31b7cc1207")!),
      User.ID(UUID(uuidString: "98b4aaa8-20d2-11e8-a385-e7e172c6714f")!),
      User.ID(UUID(uuidString: "e99eba9e-71b6-11ea-8f11-ff40cbd34e85")!),
      User.ID(UUID(uuidString: "de637994-77e1-11eb-8b0b-a354cefa5c35")!),
    ],
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
