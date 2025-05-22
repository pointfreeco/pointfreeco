import AsyncHTTPClient
import DecodableRequest
import Dependencies
import DependenciesMacros
import Foundation
import FoundationPrelude

@DependencyClient
public struct CloudflareClient: Sendable {
  public let updateDetails:
    @Sendable (
      _ videoID: String,
      _ publicDetails: Video.PublicDetails
    ) async throws -> Video.PublicDetails
  public let videos: @Sendable () async throws -> [Video]
}

extension CloudflareClient: TestDependencyKey {
  private struct SomeError: Error {}
  // TODO: why isn't @DependencyClient working?
  public static let testValue = Self(
    updateDetails: { _, _ in throw SomeError() },
    videos: { throw SomeError() }
  )
}

extension CloudflareClient {
  public static func live(accountID: String, apiToken: String) -> Self {
    Self(
      updateDetails: { videoID, publicDetails in
        (try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/\(videoID)",
          method: .postData(
            JSONEncoder().encode(["publicDetails": publicDetails])
          )
        ) as VideoEnvelope)
        .result
        .publicDetails
      },
      videos: {
        (try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream"
        ) as VideosEnvelope)
        .result
      }
    )
  }
}

private func cloudflareRequest<A: Decodable>(
  accountID: String,
  apiToken: String,
  path: String,
  method: FoundationPrelude.Method = .get([:])
) async throws -> A {
  var components = URLComponents(url: URL(string: path)!, resolvingAgainstBaseURL: false)!
  if case let .get(params) = method {
    components.queryItems = params.map { key, value in
      URLQueryItem(name: key, value: "\(value)")
    }
  }
  var request = HTTPClientRequest(
    url:
      components
      .url(
        relativeTo: URL(string: "https://api.cloudflare.com/client/v4/accounts/\(accountID)/")
      )!
      .absoluteString
  )
  request.attach(method: method)
  request.headers.add(name: "Authorization", value: "Bearer \(apiToken)")

  @Dependency(\.httpClient) var httpClient
  return try await jsonDataTask(with: request)
}
