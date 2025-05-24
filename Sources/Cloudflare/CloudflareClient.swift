import AsyncHTTPClient
import DecodableRequest
import Dependencies
import DependenciesMacros
import Foundation
import FoundationPrelude

@DependencyClient
public struct CloudflareClient: Sendable {
  public var copy: @Sendable (String) async throws -> DirectUploadEnvelope
  public var editVideo: @Sendable (EditArguments) async throws -> VideoEnvelope
  public var video: @Sendable (Cloudflare.Video.ID) async throws -> VideoEnvelope
  public var videos: @Sendable () async throws -> VideosEnvelope

  public struct EditArguments: Codable {
    public var videoID: Cloudflare.Video.ID
    public var allowedOrigins: [String]
    public var meta: [String: String]
    public var publicDetails: Video.PublicDetails
    public var thumbnailTimestampPct: Double
    public init(
      videoID: Cloudflare.Video.ID,
      allowedOrigins: [String],
      meta: [String : String],
      publicDetails: Video.PublicDetails,
      thumbnailTimestampPct: Double
    ) {
      self.videoID = videoID
      self.allowedOrigins = allowedOrigins
      self.meta = meta
      self.publicDetails = publicDetails
      self.thumbnailTimestampPct = thumbnailTimestampPct
    }
  }
  public struct DirectUploadEnvelope: Codable {
    public var result: Result
    public struct Result: Codable {
      public var uid: Cloudflare.Video.ID
    }
  }
}

extension CloudflareClient: TestDependencyKey {
  private struct SomeError: Error {}
  public static let testValue = Self()
}

extension CloudflareClient {
  public static func live(accountID: String, apiToken: String) -> Self {
    Self(
      copy: { url in
        try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/copy",
          method: .postData(JSONEncoder().encode(["url": url]))
        )
      },
      editVideo: { arguments in
        let existingMetadata = try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/\(arguments.videoID)",
          as: VideoEnvelope.self
        )
          .result.meta
        var arguments = arguments
        arguments.meta = existingMetadata.merging(arguments.meta, uniquingKeysWith: { $1 })
        return try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/\(arguments.videoID)",
          method: .postData(JSONEncoder().encode(arguments))
        )
      },
      video: { videoID in
        try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/\(videoID)"
        )
      },
      videos: {
        try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream",
          method: .get([
            "asc": false
          ])
        )
      }
    )
  }
}

private func cloudflareRequest<A: Decodable>(
  accountID: String,
  apiToken: String,
  path: String,
  method: FoundationPrelude.Method = .get([:]),
  as: A.Type = A.self
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
