import Either
import Foundation
import Logging
import UrlFormEncoding

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
  -> EitherIO<Error, (Data, URLResponse)> {
  return .init(
    run: .init { callback in

      let startTime = Date().timeIntervalSince1970
      let uuid = UUID().uuidString
      logger?.debug("[Data Task] \(uuid) \(request.url?.absoluteString ?? "nil") \(request.httpMethod ?? "UNKNOWN")")

      let session = URLSession.shared
      var request = request
      request.timeoutInterval = timeoutInterval

      session
        .dataTask(with: request) { data, response, error in
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

public enum JSONError: Error {
  case error(String, Error)
}

private let timeoutInterval: TimeInterval = 25
