import Either
import Foundation
import Prelude
import Logger
import Optics
import UrlFormEncoding

extension URLRequest {
  public var cookies: [String: String] {
    let pairs = (self.allHTTPHeaderFields?["Cookie"] ?? "")
      .components(separatedBy: "; ")
      .map {
        $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          .map(String.init)
      }
      .compactMap { (pair: [String]) -> (String, String) in
        (pair[0], pair.count == 2 ? pair[1] : "")
    }
    return .init(pairs, uniquingKeysWith: { $1 })
  }
}

private let guaranteeHeaders = \URLRequest.allHTTPHeaderFields %~ {
  $0 ?? [:]
}

public let setHeader = { name, value in
  guaranteeHeaders
    <> (\.allHTTPHeaderFields <<< map <<< \.[name] .~ value)
}

public func attachBasicAuth(username: String = "", password: String = "") -> (URLRequest) -> URLRequest {
  let encoded = Data((username + ":" + password).utf8).base64EncodedString()
  return setHeader("Authorization", "Basic " + encoded)
}

public let attachFormData =
  urlFormEncode(value:)
    >>> ^\.utf8
    >>> Data.init(_:)
    >>> set(\URLRequest.httpBody)

private let sessionConfig = URLSessionConfiguration.default
  |> \.timeoutIntervalForRequest .~ 25
  |> \.timeoutIntervalForResource .~ 25

public func dataTask(
  with request: URLRequest,
  logger: Logger?
  )
  -> EitherIO<Error, (Data, URLResponse)> {
  return .init(
    run: .init { callback in

      let startTime = Date().timeIntervalSince1970
      let uuid = UUID().uuidString
      logger?.debug("[Data Task] \(uuid) \(request.url?.absoluteString ?? "nil") \(request.httpMethod ?? "UNKNOWN")")

      let session = URLSession(configuration: sessionConfig)
      session
        .dataTask(with: request) { data, response, error in
          defer { session.finishTasksAndInvalidate() }

          let endTime = Date().timeIntervalSince1970
          let delta = Int((endTime - startTime) * 1000)

          let dataMsg = data.map { _ in "some" } ?? "none"
          let responseMsg = response.map { _ in "some" } ?? "none"
          let errorMsg = error.map(String.init(describing:)) ?? "none"

          logger?.debug("""
            [Data Task] \(uuid) \(delta)ms, \
            \(request.url?.absoluteString ?? "nil"), \
            (data, response, error) = \
            (\(dataMsg), \(responseMsg), \(errorMsg))
            """
          )

          if let error = error {
            callback(.left(error))
            return
          }
          if let data = data, let response = response {
            callback(.right((data, response)))
            return
          }
        }
        .resume()
    }
  )
}

public func logError<A>(
  subject: String,
  logger: Logger,
  file: StaticString = #file,
  line: UInt = #line
  ) -> (Error) -> EitherIO<Error, A> {

  return { error in
    var errorDump = ""
    dump(error, to: &errorDump)
    logger.log(.error, errorDump, file: file, line: line)

    return throwE(error)
  }
}

public enum JSONError: Error {
  case error(String, Error)
}

public typealias DecodableRequest<A> = Tagged<A, URLRequest> where A: Decodable

public func jsonDataTask<A>(
  with request: URLRequest,
  decoder: JSONDecoder? = nil,
  logger: Logger?
  )
  -> EitherIO<Error, A>
  where A: Decodable {

    return dataTask(with: request, logger: logger)
      .map(first)
      .flatMap { data in
        .wrap {
          do {
            return try (decoder ?? defaultDecoder).decode(A.self, from: data)
          } catch {
            throw JSONError.error(String(decoding: data, as: UTF8.self), error)
          }
        }
    }
}

private let defaultDecoder = JSONDecoder()
