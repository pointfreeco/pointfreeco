import Either
import Foundation
import Optics
import Prelude

public enum CookieTransform: String, Codable {
  case plaintext
  case encrypted
}

public typealias AirtableCreateRow = (_ email: EmailAddress) -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit>
public typealias SendEmail = (_ email: Email) -> EitherIO<Prelude.Unit, SendEmailResponse>

public struct Environment {
  public private(set) var airtableStuff: AirtableCreateRow
  public private(set) var cookieTransform: CookieTransform
  public private(set) var database: Database
  public private(set) var date: () -> Date
  public private(set) var envVars: EnvVars
  public private(set) var episodes: () -> [Episode]
  public private(set) var gitHub: GitHub
  public private(set) var logger: Logger
  public private(set) var sendEmail: SendEmail
  public private(set) var stripe: Stripe

  init(
    airtableStuff: @escaping AirtableCreateRow = createRow,
    cookieTransform: CookieTransform = .encrypted,
    database: PointFree.Database = .live,
    date: @escaping () -> Date = Date.init,
    envVars: EnvVars = EnvVars(),
    episodes: @escaping () -> [Episode] = { [typeSafeHtml] },
    gitHub: GitHub = .live,
    logger: Logger = Logger(),
    sendEmail: @escaping SendEmail = PointFree.mailgunSend,
    stripe: Stripe = .live) {

    self.airtableStuff = airtableStuff
    self.cookieTransform = cookieTransform
    self.database = database
    self.date = date
    self.envVars = envVars
    self.episodes = episodes
    self.gitHub = gitHub
    self.logger = logger
    self.sendEmail = sendEmail
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
