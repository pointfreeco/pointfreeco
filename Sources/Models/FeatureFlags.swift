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
      User.ID(UUID(uuidString: "bc88cde0-c759-11ee-8c7f-8f084de78206")!),
      User.ID(UUID(uuidString: "7822cc8c-6cc9-11ed-90d8-eb7e5175716e")!),
      User.ID(UUID(uuidString: "ee27d506-3a10-11ea-997a-172b648c5091")!),
      User.ID(UUID(uuidString: "9fa41dfa-a7c3-11eb-8d65-d78408d36af9")!),
      User.ID(UUID(uuidString: "361b362a-eb4f-11e9-8d3d-7f88b35dfbce")!),
      User.ID(UUID(uuidString: "7adff68c-9b47-11ed-8d39-73f08d337396")!),
      User.ID(UUID(uuidString: "89ca7b46-beca-11eb-bd0d-678f9ef29924")!),
      User.ID(UUID(uuidString: "22b45ea0-056c-11e9-a62b-5f142be457af")!),
      User.ID(UUID(uuidString: "d1b390d0-8ee0-11ee-a240-4be4a370fca0")!),
      User.ID(UUID(uuidString: "a838e766-a7da-11ed-b294-ff3545d70436")!),
      User.ID(UUID(uuidString: "180ed2b2-fb23-11e8-be4a-835f068ce119")!),
      User.ID(UUID(uuidString: "014e8ca0-9b0d-11ed-a08c-6b2dc3bba4ca")!),
      User.ID(UUID(uuidString: "09d247e6-cac6-11ea-b1cc-eb8e4b43be71")!),
      User.ID(UUID(uuidString: "240451b0-312e-11e8-b46d-373ffce510e4")!),
      User.ID(UUID(uuidString: "6dcaf30e-fe43-11eb-ab13-a334d7b669eb")!),
      User.ID(UUID(uuidString: "24753094-05a8-11e8-9dc6-33b6dc67c236")!),
      User.ID(UUID(uuidString: "4aaac6ee-61d3-11ec-9dac-4f0a9c20e911")!),
      User.ID(UUID(uuidString: "0aac0e96-f2b5-11f0-8520-6bd6698c29e9")!),
      User.ID(UUID(uuidString: "9a4f3206-3359-11eb-ac27-db5c0d9fc498")!),
      User.ID(UUID(uuidString: "e5c054ae-0134-11ed-b849-3f36ba17201e")!),
      User.ID(UUID(uuidString: "7a127996-b421-11f0-b193-9fd44d4d2f75")!),
      User.ID(UUID(uuidString: "be8bbabc-54a8-11ea-aa74-ef280414a2b5")!),
      User.ID(UUID(uuidString: "984fda7a-0a65-11e8-a376-63c1aab57317")!),
      User.ID(UUID(uuidString: "7d0669e0-74b0-11ed-a803-27418fd97ec5")!),
      User.ID(UUID(uuidString: "1093680a-5eb0-11ed-b501-0b22517606c1")!),
      User.ID(UUID(uuidString: "4f836892-602e-11ed-b0b4-f73c13c15e81")!),
      User.ID(UUID(uuidString: "4f943652-0414-11ed-ba9a-334f3b8a7a00")!),
      User.ID(UUID(uuidString: "8771bece-034b-11ed-821f-d77b59b2420a")!),
      User.ID(UUID(uuidString: "ecf70e94-3f0e-11ed-b52d-6fcf7dfdb26b")!),
      User.ID(UUID(uuidString: "e623383e-9645-11ed-9b3a-eb89e3cd39cf")!),
      User.ID(UUID(uuidString: "5bad31ba-fb8b-11f0-ae2b-3ffee711bf89")!),
      User.ID(UUID(uuidString: "f7daa11c-fb8b-11f0-9678-b7ae2611c905")!),
      User.ID(UUID(uuidString: "0b79ca6e-95e8-11ef-9996-b38511a38cda")!),
      User.ID(UUID(uuidString: "c505fc66-7cc7-11f0-b2e8-bb09d7ee8fcb")!),
      User.ID(UUID(uuidString: "9f83896c-2d04-11f0-bb81-fb5fc6c309e9")!),
      User.ID(UUID(uuidString: "c227bb2c-4b35-11ed-a8fb-9715ef17b720")!),
      User.ID(UUID(uuidString: "8e630384-ec4e-11ea-8ee3-efeeb1013502")!),
      User.ID(UUID(uuidString: "e000e08e-96e6-11ea-b235-4b1161fe2b69")!),
      User.ID(UUID(uuidString: "a8f5bc66-722b-11ea-937b-c733be10a726")!),
      User.ID(UUID(uuidString: "8b2821c2-d0ac-11e9-b001-5f2f8c7df0fb")!),
      User.ID(UUID(uuidString: "81f0fd8e-33ec-11e9-a5d7-cfcb5b4b89bd")!),
      User.ID(UUID(uuidString: "82c28d40-924a-11eb-b7cb-f33422b55691")!),
      User.ID(UUID(uuidString: "994eca5c-7e11-11ec-b689-bf3534de97c9")!),
      User.ID(UUID(uuidString: "ef9f8534-5c9d-11e8-852d-3358c525a455")!),
      User.ID(UUID(uuidString: "73a5470e-06b5-11e8-a798-bbcda733be60")!),
      User.ID(UUID(uuidString: "01339252-9b96-11ea-bfd3-df8374694ebf")!),
      User.ID(UUID(uuidString: "03d850dc-8037-11ed-9c06-6379eca31e0a")!),
      User.ID(UUID(uuidString: "303fef8e-7cce-11ed-88c7-17fa7b0f94d7")!),
      User.ID(UUID(uuidString: "bc593cb6-f019-11f0-bccf-0bfb8031e0ff")!),
      User.ID(UUID(uuidString: "c78ec2e6-d7c9-11e9-a35b-f71efbc33092")!),
      User.ID(UUID(uuidString: "d0f5a0ce-1a48-11ed-8490-1b01ab06094c")!),
      User.ID(UUID(uuidString: "797f0bd2-163f-11eb-9095-274e0f019fca")!),
      User.ID(UUID(uuidString: "f8ce29bc-cc2f-11f0-9f86-d351ba187b01")!),
      User.ID(UUID(uuidString: "f862845e-e1b2-11ea-b3d0-6b7f2373540c")!),
      User.ID(UUID(uuidString: "7de8746e-9508-11ea-8901-17342fb7f370")!),
      User.ID(UUID(uuidString: "8c73904e-6d88-11e8-ae0e-bbde32063ae1")!),
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
