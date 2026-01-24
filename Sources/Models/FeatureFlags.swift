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
      User.ID(UUID(uuidString: "d3c61098-3b25-11ec-bfd0-97d6db0a2301")!),
      User.ID(UUID(uuidString: "0d57f550-21dc-11ec-9956-073104b5ef5b")!),
      User.ID(UUID(uuidString: "e5c054ae-0134-11ed-b849-3f36ba17201e")!),
      User.ID(UUID(uuidString: "2af4be0a-036e-11f0-b76b-f38c2459e71a")!),
      User.ID(UUID(uuidString: "8b9569a2-423e-11ec-b495-a77e09644c4f")!),
      User.ID(UUID(uuidString: "f491e634-8411-11ea-aeac-d39d45ec96d4")!),
      User.ID(UUID(uuidString: "39617982-0c04-11ee-a90f-eb32b115ab73")!),
      User.ID(UUID(uuidString: "0aa03856-d5cc-11eb-ae54-4bae40b2eb13")!),
      User.ID(UUID(uuidString: "6c6d0218-15a1-11ea-9f0b-4703c7b0adda")!),
      User.ID(UUID(uuidString: "a5fbd17e-3ac0-11ee-9cdd-9b79aab1e67f")!),
      User.ID(UUID(uuidString: "4e1db95a-d915-11ef-8b0c-87258605784e")!),
      User.ID(UUID(uuidString: "c36a6bfe-c751-11e8-a472-5f813d0f4c88")!),
      User.ID(UUID(uuidString: "b3f39702-1cc2-11e8-9e9d-e3a39690cd58")!),
      User.ID(UUID(uuidString: "fb8b6cb0-0c64-11e9-8632-3f07d1c8a5d0")!),
      User.ID(UUID(uuidString: "74cb2214-fb99-11e8-aed8-371b841b7554")!),
      User.ID(UUID(uuidString: "24e196da-7063-11ea-98c1-174358a349ae")!),
      User.ID(UUID(uuidString: "d80f28e0-1d53-11e8-b76f-93e1df48c6d3")!),
      User.ID(UUID(uuidString: "19c268e8-8fc0-11ea-acf2-1fe954b9b27c")!),
      User.ID(UUID(uuidString: "5be27b2a-4744-11e9-a2c5-5f4e7d572a16")!),
      User.ID(UUID(uuidString: "8587ce12-4f10-11ed-806a-13c3f1b2649d")!),
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
