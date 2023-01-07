import Either
import Foundation
import Logging
import UrlFormEncoding

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLRequest {
  public mutating func guaranteeHeaders() {
    self.allHTTPHeaderFields = self.allHTTPHeaderFields ?? [:]
  }

  public mutating func attachBasicAuth(username: String = "", password: String = "") {
    self.guaranteeHeaders()
    self.allHTTPHeaderFields?["Authorization"] =
      "Basic " + Data((username + ":" + password).utf8).base64EncodedString()
  }

  public mutating func setHeader(name: String, value: String?) {
    self.guaranteeHeaders()
    self.allHTTPHeaderFields?[name] = value
  }

  public mutating func attach(formData: [String: Any]) {
    self.httpBody = Data(urlFormEncode(value: formData).utf8)
  }

}

public func dataTask(
  with request: URLRequest,
  logger: Logger?
)
  -> EitherIO<Error, (Data, URLResponse)>
{
  return .init(
    run: .init { callback in

      let startTime = Date().timeIntervalSince1970
      let uuid = UUID().uuidString
      logger?.debug(
        "[Data Task] \(uuid) \(request.url?.absoluteString ?? "nil") \(request.httpMethod ?? "UNKNOWN")"
      )

      let session = URLSession.shared
      var request = request
      request.timeoutInterval = TimeInterval(timeoutInterval)

      session
        .dataTask(with: request) { data, response, error in
          let endTime = Date().timeIntervalSince1970
          let delta = Int((endTime - startTime) * 1000)

          let dataMsg = data.map { _ in "some" } ?? "none"
          let responseMsg = response.map { _ in "some" } ?? "none"
          let errorMsg = error.map(String.init(describing:)) ?? "none"

          logger?.debug(
            """
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

public func jsonDataTask<A>(
  with request: URLRequest,
  decoder: JSONDecoder? = nil,
  logger: Logger?
)
  -> EitherIO<Error, A>
where A: Decodable {

  return dataTask(with: request, logger: logger)
    .map { data, _ in data }
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

public enum JSONError: Error {
  case error(String, Error)
}

let timeoutInterval = 25

public enum Method {
  case get([String: Any])
  case post([String: Any])
  case delete([String: String])
}

extension URLRequest {
  public mutating func attach(method: Method) {
    switch method {
    case .get:
      self.httpMethod = "GET"
    case let .post(params):
      self.httpMethod = "POST"
      self.attach(formData: params)
    case let .delete(params):
      self.httpMethod = "DELETE"
      self.attach(formData: params)
    }
  }
}
