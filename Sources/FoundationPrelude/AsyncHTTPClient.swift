import AsyncHTTPClient
import Dependencies
import Foundation
import Logging
import LoggingDependencies
import NIOCore
import NIODependencies
import NIOFoundationCompat
import Tagged
import UrlFormEncoding

extension DependencyValues {
  public var httpClient: HTTPClient {
    get { self[HTTPClient.self] }
    set { self[HTTPClient.self] = newValue }
  }
}

extension HTTPClient: @retroactive DependencyKey {
  public static var liveValue: HTTPClient {
    @Dependency(\.mainEventLoopGroup) var eventLoopGroup
    return HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
  }
}

public typealias DecodableHTTPClientRequest<A: Decodable> = Tagged<A, HTTPClientRequest>

public func jsonDataTask<A: Decodable>(
  with request: DecodableHTTPClientRequest<A>,
  decoder: JSONDecoder = JSONDecoder()
) async throws -> A {
  try await jsonDataTask(with: request.rawValue, decoder: decoder)
}

public func jsonDataTask<A: Decodable>(
  with request: HTTPClientRequest,
  decoder: JSONDecoder = JSONDecoder()
) async throws -> A {
  let (bytes, _) = try await dataTask(with: request)
  do {
    return try decoder.decode(A.self, from: bytes)
  } catch {
    throw JSONError.error(String(decoding: Array(buffer: bytes), as: UTF8.self), error)
  }
}

public func dataTask(
  with request: HTTPClientRequest
) async throws -> (ByteBuffer, HTTPClientResponse) {
  var request = request
  if !request.headers.contains(name: "user-agent") {
    request.headers.add(name: "user-agent", value: "pointfree.co")
  }

  @Dependency(\.httpClient) var client
  @Dependency(\.logger) var logger
  let response =
    try await client
    .execute(request, timeout: .seconds(Int64(timeoutInterval)), logger: logger)
  let bytes = try await response.body.collect(upTo: 12 * 1024 * 1024)
  return (bytes, response)
}

extension HTTPClientRequest {
  public mutating func attach(method: Method) {
    switch method {
    case .get:
      self.method = .GET
    case .post(let params):
      self.method = .POST
      self.attach(formData: params)
    case .postData(let data, extraHeaders: let extraHeaders):
      self.headers.add(contentsOf: extraHeaders.map { ($0, $1) })
      self.method = .POST
      self.body = .bytes(data, length: .known(Int64(data.count)))
    case let .delete(params):
      self.method = .DELETE
      self.attach(formData: params)
    }
  }

  public mutating func attach(formData: [String: Any]) {
    let data = Data(urlFormEncode(value: formData).utf8)
    self.body = .bytes(data, length: .known(Int64(data.count)))
  }
}
