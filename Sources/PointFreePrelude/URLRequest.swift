import Either
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import FoundationPrelude
import Prelude
import Logging
import Optics
import Tagged
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

public let attachFormData =
  urlFormEncode(value:)
    >>> ^\.utf8
    >>> Data.init(_:)
    >>> set(\URLRequest.httpBody)

public func logError<A>(
  subject: String,
  logger: Logger,
  file: StaticString = #file,
  line: UInt = #line
  ) -> (Error) -> EitherIO<Error, A> {

  return { error in
    var errorDump = ""
    dump(error, to: &errorDump)
    logger.log(.error, "\(errorDump)", file: "\(file)", line: line)

    return throwE(error)
  }
}

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
