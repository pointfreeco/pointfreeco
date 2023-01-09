import Dependencies
import PointFreeRouter

private enum CurrentRouteKey: DependencyKey {
  static let liveValue: SiteRoute = .home
  static let testValue: SiteRoute = .home
}

extension DependencyValues {
  public var currentRoute: SiteRoute {
    get { self[CurrentRouteKey.self] }
    set { self[CurrentRouteKey.self] = newValue }
  }
}
