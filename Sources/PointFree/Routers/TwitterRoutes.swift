import ApplicativeRouter
import Foundation
import Prelude

public enum TwitterRoute: DerivePartialIsos {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

let twitterRouter = [

  TwitterRoute.iso.mbrandonw
    <¢> get %> lit("mbrandonw") <% end,

  TwitterRoute.iso.pointfreeco
    <¢> get %> lit("pointfreeco") <% end,

  TwitterRoute.iso.stephencelis
    <¢> get %> lit("stephencelis") <% end,

  ]
  .reduce(.empty, <|>)

private let twitterBaseUrl = URL(string: "https://www.twitter.com")!

func twitterUrl(to route: TwitterRoute) -> String {
  return twitterRouter.url(for: route, base: twitterBaseUrl)?.absoluteString ?? ""
}
