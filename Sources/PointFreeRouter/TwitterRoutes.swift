import Prelude
import URLRouting

public enum TwitterRoute: String, CaseIterable {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

public let twitterRouter = Path {
  TwitterRoute.parser()
}
.baseURL("https://www.twitter.com")
