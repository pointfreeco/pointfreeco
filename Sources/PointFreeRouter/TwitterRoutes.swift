import ApplicativeRouter
import Foundation
import Prelude

public enum TwitterRoute {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

public let twitterRouter: Router<TwitterRoute> = [
  .case(const(.mbrandonw))
    <¢> get %> lit("mbrandonw") <% end,

  .case(const(.pointfreeco))
    <¢> get %> lit("pointfreeco") <% end,

  .case(const(.stephencelis))
    <¢> get %> lit("stephencelis") <% end,
  ]
  .reduce(.empty, <|>)

public func twitterUrl(to route: TwitterRoute) -> String {
  return twitterRouter.url(for: route, base: twitterBaseUrl)?.absoluteString ?? ""
}

private let twitterBaseUrl = URL(string: "https://www.twitter.com")!
