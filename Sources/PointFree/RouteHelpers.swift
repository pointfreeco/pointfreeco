import PointFreeRouter

public func path(to route: Route) -> String {
  return _pointFreeRouter.path(to: route) // pointFreeRouter.absoluteString(for: route) ?? "/"
}

public func url(to route: Route) -> String {
  return _pointFreeRouter.url(to: route) //pointFreeRouter.url(for: route, base: Current.envVars.baseUrl)?.absoluteString ?? ""
}
