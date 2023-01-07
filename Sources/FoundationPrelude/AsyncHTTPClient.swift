import AsyncHTTPClient
import Dependencies
import Foundation
import NIOCore
import NIODependencies
import Logging
import Tagged

extension DependencyValues {
  public var httpClient: HTTPClient {
    get { self[HTTPClient.self] }
    set { self[HTTPClient.self] = newValue }
  }
}

extension HTTPClient: DependencyKey {
  public static var liveValue: HTTPClient {
    @Dependency(\.mainEventLoopGroup) var eventLoopGroup
    return HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
  }
}

public typealias DecodableHTTPClientRequest<A: Decodable> = Tagged<A, HTTPClientRequest>

public func jsonDataTask<A: Decodable>(
  with request: DecodableHTTPClientRequest<A>,
  decoder: JSONDecoder = JSONDecoder(),
  logger: Logger?
) async throws -> A {
  try await jsonDataTask(with: request.rawValue, decoder: decoder, logger: logger)
}

public func jsonDataTask<A: Decodable>(
  with request: HTTPClientRequest,
  decoder: JSONDecoder = JSONDecoder(),
  logger: Logger?
) async throws -> A {
  let (bytes, _) = try await dataTask(with: request, logger: logger)
  do {
    return try decoder.decode(A.self, from: bytes)
  } catch {
    throw JSONError.error(String(decoding: Array(buffer: bytes), as: UTF8.self), error)
  }
}

public func dataTask(
  with request: HTTPClientRequest,
  logger: Logger?
) async throws -> (ByteBuffer, HTTPClientResponse) {
  @Dependency(\.httpClient) var client
  let response = try await client
    .execute(request, timeout: .seconds(Int64(timeoutInterval)), logger: logger)
  let contentLength = response.headers.first(name: "content-length").flatMap(Int.init)
    ?? 1024 * 1024  // 1MB
  let bytes = try await response.body.collect(upTo: contentLength)
  return (bytes, response)
}
