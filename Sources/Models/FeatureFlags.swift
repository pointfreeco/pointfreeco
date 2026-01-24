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
      User.ID(UUID(uuidString: "c7a3279c-333d-11eb-bf84-1bf1d1bdb566")!),
      User.ID(UUID(uuidString: "59ae8284-ae47-11ef-ae52-8f4612b3cdc1")!),
      User.ID(UUID(uuidString: "de71e7d4-0e9f-11e9-ab0f-1beca3a7fad2")!),
      User.ID(UUID(uuidString: "e874cb84-45a5-11e8-b3b5-dbd662ddc5f8")!),
      User.ID(UUID(uuidString: "403d0b48-1263-11ea-99c7-3bc094756ff7")!),
      User.ID(UUID(uuidString: "4451295c-3de0-11ed-9acf-2f0e8e34338a")!),
      User.ID(UUID(uuidString: "68b8c3ac-6ab0-11ed-a2c7-338baafdfc00")!),
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
