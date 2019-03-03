import PointFreeRouter

public func path(to route: Route) -> String {
  return pointFreeRouter.absoluteString(for: route) ?? "/"
}

public func url(to route: Route) -> String {
  return pointFreeRouter.url(for: route, base: Current.envVars.baseUrl)?.absoluteString ?? ""
}
