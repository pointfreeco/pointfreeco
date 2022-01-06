import ApplicativeRouter
import Foundation
import Parsing
import URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PointFreeRouter {
  public let baseUrl: URL

  public init(baseUrl: URL = URL(string: "http://localhost:8080")!) {
    self.baseUrl = baseUrl
  }

  public func path(to route: AppRoute) -> String {
    guard let path = router.print(route).flatMap(URLRequest.init(data:))?.url?.absoluteString
    else {
      assertionFailure("Failed to print \(route)")
      return ""
    }
    return "/\(path)"
  }

  public func url(to route: AppRoute) -> String {
    self.request(for: route)?.url?.absoluteString ?? ""
  }

  public func request(for route: AppRoute) -> URLRequest? {
    guard
      var request = router.print(route).flatMap(URLRequest.init(data:)),
      let path = request.url?.absoluteString,
      let url = URL(string: "\(self.baseUrl.absoluteString)/\(path)")
    else {
      assertionFailure("Failed to print \(route)")
      return nil
    }
    request.url = url
    return request
  }

  public func match(request: URLRequest) -> AppRoute? {
    guard var data = URLRequestData(request: request)
    else { return nil }
    return router.parse(&data)
  }
}

public var pointFreeRouter = PointFreeRouter()

public func path(to route: AppRoute) -> String {
  return pointFreeRouter.path(to: route)
}

public func url(to route: AppRoute) -> String {
  return pointFreeRouter.url(to: route)
}
