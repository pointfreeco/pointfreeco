import AsyncHTTPClient
import DecodableRequest
import Dependencies
import DependenciesMacros
import Foundation
import FoundationPrelude

@DependencyClient
public struct CloudflareClient: Sendable {
  public var copy: @Sendable (String) async throws -> Envelope<DirectUploadResult>
  public var editVideo: @Sendable (EditVideoArguments) async throws -> Envelope<Video>
  public var images:
    @Sendable (_ perPage: Int, _ page: Int) async throws -> Envelope<ImagesEnvelope>
  public var uploadImage:
    @Sendable (_ url: String, _ metadata: [String: String]) async throws -> Envelope<Image>
  public var video: @Sendable (Cloudflare.Video.ID) async throws -> Envelope<Video>
  public var videos: @Sendable () async throws -> Envelope<[Video]>

  public struct EditVideoArguments: Encodable {
    public var videoID: Cloudflare.Video.ID
    public var allowedOrigins: [String]
    public var meta: [String: String]
    public var publicDetails: Video.PublicDetails
    public var thumbnailTimestampPct: Double
    public init(
      videoID: Cloudflare.Video.ID,
      allowedOrigins: [String],
      meta: [String: String],
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
  public struct DirectUploadResult: Decodable {
    public var uid: Cloudflare.Video.ID
  }
  public struct ImagesEnvelope: Decodable {
    public let images: [Image]
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
          as: Envelope<Video>.self
        )
        .result.meta
        var arguments = arguments
        arguments.meta = (existingMetadata ?? [:]).merging(arguments.meta, uniquingKeysWith: { $1 })
        return try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "stream/\(arguments.videoID)",
          method: .postData(JSONEncoder().encode(arguments))
        )
      },
      images: { perPage, page in
        try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "images/v1",
          method: .get([
            "page": page,
            "per_page": perPage,
          ])
        )
      },
      uploadImage: { url, metadata in
        let boundary = "PointFree_\(UUID().uuidString)"
        return try await cloudflareRequest(
          accountID: accountID,
          apiToken: apiToken,
          path: "images/v1",
          method: .postData(
            Data(
              """
              --\(boundary)\r
              Content-Disposition: form-data; name="url"
              Content-Type: text/plain; charset=utf-8\r
              \r
              \(url)\r
              --\(boundary)\r
              Content-Disposition: form-data; name="metadata"\r
              Content-Type: application/json\r
              \r
              \(String(decoding: JSONEncoder().encode(metadata), as: UTF8.self))\r
              --\(boundary)--
              """
              .utf8
            ),
            extraHeaders: [
              "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ]
          )
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
  return try await jsonDataTask(with: request, decoder: jsonDecoder)
}

let jsonDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()
