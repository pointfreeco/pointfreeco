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
      },
      //https://api.vimeo.com/users/100830020/projects/15685787/videos?fields=uri,name,description,duration,type,privacy&per_page=100
      videos: { projectID in
        try await dataTask(
          bearer: bearer,
          // TODO: move user ID to secrets?
          path: "users/100830020/projects/\(projectID)/videos",
          fields: videoFields,
          perPage: 100
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
  "privacy",
  "type",
  "uri",
]

struct InvalidPath: Error {
  let path: String
}

struct InvalidURLComponents: Error {}
