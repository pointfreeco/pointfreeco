import ApplicativeRouter
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
    guard let path = (try? router.print(route)).flatMap(URLRequest.init(data:))?.url?.absoluteString
    else {
      print("error: failed to print \(route)")
      return ""
    }
    return "/\(path)"
  }

  public func url(to route: AppRoute) -> String {
    self.request(for: route)?.url?.absoluteString ?? ""
  }

  public func request(for route: AppRoute) -> URLRequest? {
    do {
      let data = try router.print(route)
      guard
        var request = URLRequest(data: data),
        let path = request.url?.absoluteString,
        let url = URL(string: "\(self.baseUrl.absoluteString)/\(path)")
      else {
        print("error: failed to print \(route)")
        return nil
      }
      request.url = url
      return request
    } catch {
      print("error: failed to print \(route): \(error)")
      return nil
    }
  }

  public func match(request: URLRequest) -> AppRoute? {
    guard var data = URLRequestData(request: request)
    else { return nil }
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
