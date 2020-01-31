import Either
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import FoundationPrelude
import Prelude
import Logging
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
