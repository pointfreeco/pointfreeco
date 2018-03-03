import Either
import Foundation
import Optics
import Prelude

public enum CookieTransform: String, Codable {
  case plaintext
  case encrypted
}

public struct Environment {
  public private(set) var cookieTransform: CookieTransform
  public private(set) var database: Database
  public private(set) var date: () -> Date
  public private(set) var envVars: EnvVars
  public private(set) var episodes: () -> [Episode]
  public private(set) var gitHub: GitHub
  public private(set) var logger: Logger
  public private(set) var mailgun: Mailgun
  public private(set) var stripe: Stripe

  init(
    cookieTransform: CookieTransform = .plaintext,
    database: PointFree.Database = .live,
    date: @escaping () -> Date = Date.init,
    envVars: EnvVars = EnvVars(),
    episodes: @escaping () -> [Episode] = { [typeSafeHtml, typeSafeHtml, typeSafeHtml] },
    gitHub: GitHub = .live,
    logger: Logger = Logger(),
    mailgun: Mailgun = .live,
    stripe: Stripe = .live) {

    self.cookieTransform = cookieTransform
    self.database = database
    self.date = date
    self.envVars = envVars
    self.episodes = episodes
    self.gitHub = gitHub
    self.logger = logger
    self.mailgun = mailgun
    self.stripe = stripe
  }
}

public struct AppEnvironment {
  private static var stack: [Environment] = [Environment()]
  public static var current: Environment { return stack.last! }

  public static func push(_ env: (Environment) -> Environment) {
    self.stack.append(self.current |> env)
  }

  public static func with(_ env: (Environment) -> Environment, _ block: () -> Void) {
    self.push(env)
    block()
    self.pop()
  }

  public static func pop() {
    self.stack.removeLast()
  }
}
