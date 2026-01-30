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
      User.ID(UUID(uuidString: "9ff00f24-d9c0-11f0-bb79-d73cc3064961")!),
      User.ID(UUID(uuidString: "ac304ee4-5fe0-11ea-ae26-e3f8e399ce4c")!),
      User.ID(UUID(uuidString: "2347fcfa-bdb0-11ec-bd05-b3b2c488b20d")!),
      User.ID(UUID(uuidString: "08dd5072-0dab-11e8-83de-9f8353501afe")!),
      User.ID(UUID(uuidString: "063e9360-580e-11ec-9969-5b55c44cd640")!),
      User.ID(UUID(uuidString: "d7b81f78-11e0-11ee-bc8b-0b030200c51e")!),
      User.ID(UUID(uuidString: "5faa16dc-29d3-11f0-ac95-279975d486a8")!),
      User.ID(UUID(uuidString: "c98f888c-6efc-11ed-b33d-1fa93ac38cc2")!),
      User.ID(UUID(uuidString: "a74a8e68-60b6-11ef-be12-0787a3b2d863")!),
      User.ID(UUID(uuidString: "8a215a4a-a4f6-11ea-98e5-938249406274")!),
      User.ID(UUID(uuidString: "3e1d70b0-69da-11ed-ae1a-47e20c59b19d")!),
      User.ID(UUID(uuidString: "6e02afea-105f-11ed-a012-2f6994a95148")!),
      User.ID(UUID(uuidString: "06be3c8e-da4e-11eb-a823-73f6c3028978")!),
      User.ID(UUID(uuidString: "ae961c78-e865-11ea-9551-0bb28fdfc231")!),
      User.ID(UUID(uuidString: "e922c710-e3ec-11ef-b814-ef3e9c41a44b")!),
      User.ID(UUID(uuidString: "51dbaef6-2390-11eb-8637-17a5e330ee3d")!),
      User.ID(UUID(uuidString: "e4b8063c-8587-11ee-a3aa-674cf723ef7a")!),
      User.ID(UUID(uuidString: "7b1c2512-8365-11ec-a948-bbd028d539e0")!),
      User.ID(UUID(uuidString: "e92c0730-7108-11ec-ae70-abfeb3cbdf5d")!),
      User.ID(UUID(uuidString: "4a7a42cc-89fd-11ee-9c8a-f7b0e31aef58")!),
      User.ID(UUID(uuidString: "ecb5cff4-23fc-11ef-baea-23bdc0f38251")!),
      User.ID(UUID(uuidString: "920128a6-6337-11e8-81ff-8bd9d1e77bf9")!),
      User.ID(UUID(uuidString: "362dc660-8af5-11ee-9fae-cfbcfa9eaab2")!),
      User.ID(UUID(uuidString: "2122a286-5a94-11e9-89d4-0f4283fb9c4d")!),
      User.ID(UUID(uuidString: "042eb83a-4eae-11eb-a88a-9383c5d5f3b5")!),
      User.ID(UUID(uuidString: "7770b374-e39f-11e8-b9cc-4fdd1cba197f")!),
      User.ID(UUID(uuidString: "978e4592-e53c-11e8-b0bc-6faf19e8f90a")!),
      User.ID(UUID(uuidString: "4791deea-0a1d-11e9-877b-97414fdb8cb5")!),
      User.ID(UUID(uuidString: "657e21f6-1735-11e8-845d-6f77d6237693")!),
      User.ID(UUID(uuidString: "c9de16da-a7f4-11eb-921f-1f68eee73443")!),
      User.ID(UUID(uuidString: "d5013cb2-05a5-11e8-8a63-776d9e66bd3e")!),
      User.ID(UUID(uuidString: "25d8a120-47c3-11e8-981a-575334991ad5")!),
      User.ID(UUID(uuidString: "a0bf19d0-2c38-11eb-9b97-ff3374f551b1")!),
      User.ID(UUID(uuidString: "a3214c12-9a7e-11ea-96e9-2ba1e2a409b5")!),
      User.ID(UUID(uuidString: "f46b5938-6245-11ec-bc65-4b12b5f2e0e0")!),
      User.ID(UUID(uuidString: "f0bdb706-66bb-11e8-b945-9b6d35d26330")!),
      User.ID(UUID(uuidString: "e3f09a6c-c0a4-11ea-8f6c-6f01521f4f9d")!),
      User.ID(UUID(uuidString: "4e0fd2d6-fd2c-11f0-bd6d-c350433744ab")!),
      User.ID(UUID(uuidString: "e8bd197a-0603-11e8-adfc-e3fd7610d0b9")!),
      User.ID(UUID(uuidString: "74cde1ea-16a9-11e9-a342-b371e410d804")!),
      User.ID(UUID(uuidString: "afa775e0-fd58-11f0-869d-cb5f1a7760c8")!),
      User.ID(UUID(uuidString: "ecdaa8a8-75a0-11ed-ac08-7f50b3d58ee9")!),
      User.ID(UUID(uuidString: "0cefdad2-cfd0-11eb-b297-2b6433b214ca")!),
      User.ID(UUID(uuidString: "8d0b4db0-3843-11ec-8fc2-a33b275538ff")!),
      User.ID(UUID(uuidString: "3f168038-d2be-11eb-a424-4f8714a23d98")!),
      User.ID(UUID(uuidString: "698c1848-c1b9-11f0-8732-e74c17d6580b")!),
      User.ID(UUID(uuidString: "8b2ec756-4c9c-11e8-bba7-1f093bf7758f")!),
      User.ID(UUID(uuidString: "9f63b616-9830-11ed-b804-2f91c110e1c9")!),
      User.ID(UUID(uuidString: "476b14b0-f965-11eb-97b8-23212e8f2aba")!),
      User.ID(UUID(uuidString: "fe619a78-77be-11eb-b1f7-bfcbcf5660f4")!),
      User.ID(UUID(uuidString: "9ecad6b4-5251-11ed-950a-e75767fdb1af")!),
      User.ID(UUID(uuidString: "6a0e5142-22f6-11ed-ae03-137c26560b1e")!),
      User.ID(UUID(uuidString: "4c23791a-0fce-11eb-8cd3-ffc3e5230b12")!),
      User.ID(UUID(uuidString: "39101a0c-878a-11eb-b06e-27c67aba460e")!),
      User.ID(UUID(uuidString: "f4274778-438b-11ef-877a-77a7a10d0a03")!),
      User.ID(UUID(uuidString: "b90264f2-8287-11f0-9f2b-87a2ed786627")!),
      User.ID(UUID(uuidString: "a91720d0-da9f-11f0-a131-3fdd7ef76ad1")!),
      User.ID(UUID(uuidString: "83568ebe-be37-11eb-9d94-63f8a6450bc7")!),
      User.ID(UUID(uuidString: "73427b92-68d1-11ec-b1b6-a3875f65256f")!),
      User.ID(UUID(uuidString: "58f4df28-083d-11eb-8675-af95317e3440")!),
      User.ID(UUID(uuidString: "354eadd8-361b-11ee-82c4-b375bfc51051")!),
      User.ID(UUID(uuidString: "e9099162-ebdb-11f0-9415-6701a9ffd9e9")!),
      User.ID(UUID(uuidString: "22a871f4-f005-11eb-a688-eb31fa35ceab")!),
      User.ID(UUID(uuidString: "7d39162e-b48d-11e9-8aa5-9728a03c5375")!),
      User.ID(UUID(uuidString: "93bf3fe4-0936-11e8-8c5e-03a56bc42ac9")!),
      User.ID(UUID(uuidString: "baa0a898-8db7-11ea-b349-87d00ef66ffb")!),
      User.ID(UUID(uuidString: "22dd1f26-6a40-11eb-a991-5747c1f16742")!),
      User.ID(UUID(uuidString: "257bd8f0-1ac5-11eb-ae27-efa77d36b54c")!),
      User.ID(UUID(uuidString: "bbbd214a-2ffe-11f0-9a4e-2fb2dba183d2")!),
      User.ID(UUID(uuidString: "f3b26b30-2703-11ec-b2e2-8b134759b7ff")!),
      User.ID(UUID(uuidString: "2a52be86-07a2-11e8-9f69-cfa86c14dca0")!),
      User.ID(UUID(uuidString: "57d9f0c8-ff5b-11ea-8f10-2b5c4e284bc0")!),
      User.ID(UUID(uuidString: "9b75d2d8-0fc4-11eb-92d8-df35352c56ba")!),
      User.ID(UUID(uuidString: "cbe5ff42-e114-11ec-8026-5b39bfb68a71")!),
      User.ID(UUID(uuidString: "3a23c544-9834-11ed-85c2-77eb5cba431f")!),
      User.ID(UUID(uuidString: "3d028828-eec6-11ea-92d9-7324af79e11d")!),
      User.ID(UUID(uuidString: "db145a42-f9d3-11ea-9af5-e74ee93340c2")!),
      User.ID(UUID(uuidString: "4c23791a-0fce-11eb-8cd3-ffc3e5230b12")!),
      User.ID(UUID(uuidString: "0f699fa0-1e6c-11ed-bb1f-5fea1f8c7398")!),
      User.ID(UUID(uuidString: "35654bd8-94c5-11ea-92bb-dfd312a6243a")!),
      User.ID(UUID(uuidString: "8178659e-df58-11eb-8477-eba0672f82c9")!),
      User.ID(UUID(uuidString: "22dd1f26-6a40-11eb-a991-5747c1f16742")!),
      User.ID(UUID(uuidString: "257bd8f0-1ac5-11eb-ae27-efa77d36b54c")!),
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
