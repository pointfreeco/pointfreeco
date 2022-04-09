import ApplicativeRouter
import Foundation
import Parsing
import Prelude
import _URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum TwitterRoute: String {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

private let twitterRouter = Path {
  Parse(.string.representing(TwitterRoute.self))
}

public func twitterUrl(to route: TwitterRoute) -> String {
  (
    try? twitterRouter
      .baseURL("https://www.twitter.com")
      .print(route)
  )
  .flatMap(URLRequest.init(data:))?.url?.absoluteString
  ?? ""
}
