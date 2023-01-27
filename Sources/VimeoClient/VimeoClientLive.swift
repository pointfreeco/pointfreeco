import AsyncHTTPClient
import DecodableRequest
import Dependencies
import Foundation
import FoundationPrelude
import Logging
import Tagged

extension VimeoClient {
  public static func live(bearer: String) -> Self {
    return Self(
      video: { videoID in
        try await dataTask(bearer: bearer, path: "videos/\(videoID)")
      }
    )
  }
}

private func dataTask<A: Decodable>(
  bearer: String,
  path: String
) async throws -> A {
  var request = HTTPClientRequest(url: "https://api.vimeo.com/\(path)")
  request.headers.add(name: "accept", value: "application/vnd.vimeo.*+json;version=3.4")
  request.headers.add(name: "content-type", value: "application/json")
  request.headers.add(name: "authorization", value: "bearer \(bearer)")
  return try await jsonDataTask(
    with: DecodableHTTPClientRequest<A>(rawValue: request).rawValue,
    decoder: jsonDecoder
  )
}

private let jsonDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()

