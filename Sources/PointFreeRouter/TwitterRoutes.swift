import ApplicativeRouter
import Foundation
import Parsing
import Prelude
import URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum TwitterRoute: String {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

private let twitterRouter = Path {
  TwitterRoute.parser(rawValue: String.parser())
}

public func twitterUrl(to route: TwitterRoute) -> String {
  guard let path = twitterRouter.print(route).flatMap(URLRequest.init(data:))?.url?.absoluteString
  else { return "" }
  return "\(twitterBaseUrl.absoluteString)/\(path)"
}

private let twitterBaseUrl = URL(string: "https://www.twitter.com")!
