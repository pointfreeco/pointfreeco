import Dependencies
import PointFreeRouter

private enum SiteRouteKey: DependencyKey {
  static let liveValue: SiteRoute = .home
  static let testValue: SiteRoute = .home
}

extension DependencyValues {
  // TODO: rename to currentRoute?
  public var siteRoute: SiteRoute {
    get { self[SiteRouteKey.self] }
    set { self[SiteRouteKey.self] = newValue }
  }
}
