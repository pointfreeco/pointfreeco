public struct Feature: Equatable {
  fileprivate let isAdminEnabled: Bool
  fileprivate let isEnabled: Bool
  fileprivate let name: String

  static let allFeatures: [Feature] = [
  ]
}

extension Array where Element == Feature {
  func hasAccess(to feature: Feature, for user: Database.User?) -> Bool {

    return
      feature.isEnabled
        || (feature.isAdminEnabled && user?.isAdmin == .some(true))
  }
}
