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
      video: {
        videoID in
        try await dataTask(
          bearer: bearer,
          path: "videos/\(videoID)",
          fields: videoFields
        )
      }
    )
  }
}

private func dataTask<A: Decodable>(
  bearer: String,
  path: String,
  fields: [String]? = nil,
  perPage: Int = 10
) async throws -> A {
  guard var components = URLComponents(string: "https://api.vimeo.com/\(path)")
  else {
    throw InvalidPath(path: path)
  }
  components.queryItems = []
  components.queryItems?.append(
    URLQueryItem(name: "per_page", value: perPage.description)
  )
  if let fields {
    components.queryItems?.append(
      URLQueryItem(name: "fields", value: fields.joined(separator: ","))
    )
  }
  guard let url = components.url
  else {
    throw InvalidURLComponents()
  }
  var request = HTTPClientRequest(url: url.absoluteString)
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

private let videoFields = [
  "created_time",
  "description",
  "duration",
  "name",
  "pictures.base_link",
  "privacy",
  "type",
  "uri",
]

struct InvalidPath: Error {
  let path: String
}

struct InvalidURLComponents: Error {}
