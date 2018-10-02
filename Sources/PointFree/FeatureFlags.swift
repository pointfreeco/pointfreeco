public struct Feature: Equatable {
  fileprivate let isAdminEnabled: Bool
  fileprivate let isEnabled: Bool
  fileprivate let name: String

  static let podcastRss = Feature(isAdminEnabled: true, isEnabled: false, name: "podcast-rss")
}

extension Array where Element == Feature {
  static let allFeatures: Array = [
    .podcastRss
  ]

  func hasAccess(to feature: Feature, for user: Database.User?) -> Bool {

    return
      feature.isEnabled
        || (feature.isAdminEnabled && user?.isAdmin == .some(true))
  }
}
