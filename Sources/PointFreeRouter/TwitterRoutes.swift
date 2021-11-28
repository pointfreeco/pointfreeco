import ApplicativeRouter
import Foundation
import Prelude
import URLRouting

public enum TwitterRoute: String {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

private let twitterRouter = Parse {
  Method.get
  Path { String.parser().pipe { TwitterRoute.parser() } }
}

public func twitterUrl(to route: TwitterRoute) -> String {
  guard let path = twitterRouter.print(route).flatMap(URLRequest.init(data:))?.url?.absoluteString
  else { return "" }
  return twitterBaseUrl.absoluteString + path
}

private let twitterBaseUrl = URL(string: "https://www.twitter.com")!

/*
 public let twitterRouter: Router<TwitterRoute> = [
   .case(.mbrandonw)
     <¢> get %> "mbrandonw" <% end,

   .case(.pointfreeco)
     <¢> get %> "pointfreeco" <% end,

   .case(.stephencelis)
     <¢> get %> "stephencelis" <% end,
   ]
   .reduce(.empty, <|>)
 */
