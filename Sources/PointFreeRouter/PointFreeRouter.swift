import Foundation
import Parsing
import _URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PointFreeRouter {
  public let baseUrl: URL

  public init(baseUrl: URL = URL(string: "http://localhost:8080")!) {
    self.baseUrl = baseUrl
  }

  public func path(to route: AppRoute) -> String {
    self.request(for: route)?.url?.path ?? ""
  }

  public func url(to route: AppRoute) -> String {
    self.request(for: route)?.url?.absoluteString ?? ""
  }

  public func request(for route: AppRoute) -> URLRequest? {
    do {
      guard
        let request = URLRequest(
          data: try router
            .baseURL(self.baseUrl.absoluteString)
            .print(route)
        )
      else {
        print("error: failed to print \(route)")
        return nil
      }
      return request
    } catch {
      print("error: failed to print \(route): \(error)")
      return nil
    }
  }

  public func match(request: URLRequest) -> AppRoute? {
    guard var data = URLRequestData(request: request)
    else {
      print("error: failed to convert request data \(request)")
      return nil
    }
    do {
      return try router.parse(&data)
    } catch {
      print("error: failed to match route for request \(request): \(error)")
      return nil
    }
  }
}

public var pointFreeRouter = PointFreeRouter()

public func path(to route: AppRoute) -> String {
  return pointFreeRouter.path(to: route)
}

public func url(to route: AppRoute) -> String {
  return pointFreeRouter.url(to: route)
}
