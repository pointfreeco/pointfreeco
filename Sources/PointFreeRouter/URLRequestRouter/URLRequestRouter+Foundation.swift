import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequestData {
  public init?(request: URLRequest) {
    guard
      let url = request.url,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }

    self.init(
      method: request.httpMethod,
      path: url.path.split(separator: "/")[...],
      query: components.queryItems?.reduce(into: [:]) { query, item in
        query[item.name, default: []].append(item.value?[...])
      } ?? [:],
      headers: request.allHTTPHeaderFields?.mapValues { $0[...] } ?? [:],
      body: request.httpBody.map { ArraySlice($0) }
    )
  }

  public init?(url: URL) {
    self.init(request: URLRequest(url: url))
  }

  public init?(string: String) {
    guard let url = URL(string: string)
    else { return nil }
    self.init(url: url)
  }
}
