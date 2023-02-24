import Prelude
import URLRouting

public enum TwitterRoute: String, CaseIterable {
  case mbrandonw
  case pointfreeco
  case stephencelis
}

public struct TwitterRouter: ParserPrinter {
  public init() {}

  public var body: some Router<TwitterRoute> {
    Path {
      TwitterRoute.parser()
    }
    .baseURL("https://www.twitter.com")
  }
}
