import Foundation
import Parsing
import _URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PointFreeRouter: ParserPrinter {
  let _baseURL: String

  public init(baseURL: URL = URL(string: "http://localhost:8080")!) {
    self._baseURL = baseURL.absoluteString
  }

  public func parse(_ input: inout URLRequestData) throws -> SiteRoute {
    try router.parse(&input)
  }

  public func print(_ output: SiteRoute, into input: inout URLRequestData) throws {
    try router
      .baseURL(self._baseURL)
      .print(output, into: &input)
  }

  public func url(to route: SiteRoute) -> String {
    self.url(for: route).absoluteString
  }
}

public var pointFreeRouter = PointFreeRouter()

public func path(to route: SiteRoute) -> String {
  pointFreeRouter.path(for: route)
}

public func url(to route: SiteRoute) -> String {
  pointFreeRouter.url(for: route).absoluteString
}
