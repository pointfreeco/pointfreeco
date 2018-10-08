public struct Feature: Equatable {
  public private(set) var isAdminEnabled: Bool
  public private(set) var isEnabled: Bool
  public private(set) var name: String

  static let podcastRss = Feature(isAdminEnabled: true, isEnabled: true, name: "podcast-rss")
}

extension Array where Element == Feature {
  static let allFeatures: Array = [
    .podcastRss
  ]

  func hasAccess(to feature: Feature, for user: Database.User?) -> Bool {
    return self
      .first(where: { $0.name == feature.name })
      .map {
        $0.isEnabled
          || ($0.isAdminEnabled && user?.isAdmin == .some(true))
      }
      ?? false
  }
}
