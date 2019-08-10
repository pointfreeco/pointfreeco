import Models

public struct Feature: Equatable {
  public var isAdminEnabled: Bool
  public var isEnabled: Bool
  public var name: String

  static let podcastRss = Feature(isAdminEnabled: true, isEnabled: true, name: "podcast-rss")
}

extension Array where Element == Feature {
  static let allFeatures: Array = [
    .podcastRss
  ]

  func hasAccess(to feature: Feature, for user: User?) -> Bool {
    return self
      .first(where: { $0.name == feature.name })
      .map {
        $0.isEnabled
          || ($0.isAdminEnabled && user?.isAdmin == .some(true))
      }
      ?? false
  }
}
