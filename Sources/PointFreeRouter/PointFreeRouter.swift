import ApplicativeRouter
import Foundation

public struct PointFreeRouter {
  public let baseUrl: URL
  public let router: Router<Route>

  public init(baseUrl: URL = URL(string: "http://localhost:8080")!) {
    self.baseUrl = baseUrl
    self.router = routers.reduce(.empty, <|>)
  }

  public init(baseUrl: URL = URL(string: "http://localhost:8080")!, router: Router<Route>) {
    self.baseUrl = baseUrl
    self.router = router
  }

  public func path(to route: Route) -> String {
    return self.router.absoluteString(for: route) ?? "/"
  }

  public func url(to route: Route) -> String {
    return self.router.url(for: route, base: self.baseUrl)?.absoluteString ?? ""
  }

  public func request(for route: Route) -> URLRequest? {
    return self.router.request(for: route, base: self.baseUrl)
  }

  public func match(request: URLRequest) -> Route? {
    return self.router.match(request: request)
  }
}

public var pointFreeRouter = PointFreeRouter()

public func path(to route: Route) -> String {
  return pointFreeRouter.path(to: route)
}

public func url(to route: Route) -> String {
  return pointFreeRouter.url(to: route)
}
