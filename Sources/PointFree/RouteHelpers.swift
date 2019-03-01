import PointFreeRouter

public let router = pointFreeRouter(
  appSecret: Current.envVars.appSecret,
  mailgunApiKey: Current.envVars.mailgun.apiKey
)

public func path(to route: Route) -> String {
  return router.absoluteString(for: route) ?? "/"
}

public func url(to route: Route) -> String {
  return router.url(for: route, base: Current.envVars.baseUrl)?.absoluteString ?? ""
}
