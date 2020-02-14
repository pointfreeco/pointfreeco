import ApplicativeRouter
import Foundation
import Prelude

public enum TwitterRoute {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

public let twitterRouter: Router<TwitterRoute> = [
  .case(.mbrandonw)
    <¢> get %> "mbrandonw" <% end,

  .case(.pointfreeco)
    <¢> get %> "pointfreeco" <% end,

  .case(.stephencelis)
    <¢> get %> "stephencelis" <% end,
  ]
  .reduce(.empty, <|>)

public func twitterUrl(to route: TwitterRoute) -> String {
  return twitterRouter.url(for: route, base: twitterBaseUrl)?.absoluteString ?? ""
}

private let twitterBaseUrl = URL(string: "https://www.twitter.com")!
