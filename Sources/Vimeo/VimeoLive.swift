import AsyncHTTPClient
import DecodableRequest
import Dependencies
import Foundation
import FoundationPrelude
import Logging
import Tagged

extension VimeoClient {
  public static func live(bearer: String, userId: String) -> Self {
    return Self(
      video: { try await dataTask(bearer: bearer, path: "videos/\($0)") },
      videos: {
        try await dataTask(
          bearer: bearer,
          path: "users/\(userId)/videos",
          method: .get(["page": $0, "per_page": $1].compactMapValues(\.self))
        )
      }
    )
  }
}

private func dataTask<R: Decodable>(
  bearer: String,
  path: String,
  method: FoundationPrelude.Method = .get([:])
) async throws -> R {
  var components = URLComponents(
    url: URL(string: "https://api.vimeo.com/\(path)")!, resolvingAgainstBaseURL: false
  )!
  if case let .get(params) = method {
    components.queryItems = params.map { key, value in
      URLQueryItem(name: key, value: "\(value)")
    }
  }
  var request = HTTPClientRequest(url: components.url!.absoluteString)
  request.headers.add(name: "accept", value: "application/vnd.vimeo.*+json;version=3.4")
  request.headers.add(name: "content-type", value: "application/json")
  request.headers.add(name: "authorization", value: "bearer \(bearer)")
  return try await jsonDataTask(
    with: DecodableHTTPClientRequest<R>(rawValue: request).rawValue,
    decoder: jsonDecoder
  )
}

private let jsonDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()
