import Dependencies
import Foundation
import URLRouting

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

  public func url(for route: SiteRoute) -> String {
    self.url(for: route).absoluteString
  }

  public func loginPath(redirect: SiteRoute? = nil) -> String {
    self.path(for: .login(redirect: redirect.map(self.url(for:))))
  }
}

extension PointFreeRouter: TestDependencyKey {
  public static let testValue = PointFreeRouter()
}

extension DependencyValues {
  public var siteRouter: PointFreeRouter {
    get { self[PointFreeRouter.self] }
    set { self[PointFreeRouter.self] = newValue }
  }
}
