import Either
import Foundation
import Optics
import Prelude

public typealias AirtableCreateRow = (_ email: EmailAddress) -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit>
public typealias SendEmail = (_ email: Email) -> EitherIO<Prelude.Unit, SendEmailResponse>

public struct Environment {
  public private(set) var airtableStuff: AirtableCreateRow
  public private(set) var database: Database
  public private(set) var envVars: EnvVars
  public private(set) var gitHub: GitHub
  public private(set) var logger: Logger
  public private(set) var sendEmail: SendEmail
  public private(set) var stripe: Stripe

  init(
    airtableStuff: @escaping AirtableCreateRow = createRow,
    database: PointFree.Database = .live,
    envVars: EnvVars = EnvVars(),
    gitHub: GitHub = .live,
    logger: Logger = Logger(),
    sendEmail: @escaping SendEmail = PointFree.mailgunSend,
    stripe: Stripe = .live) {

    self.airtableStuff = airtableStuff
    self.database = database
    self.envVars = envVars
    self.gitHub = gitHub
    self.logger = logger
    self.sendEmail = sendEmail
    self.stripe = stripe
  }
}

public struct AppEnvironment {
  private static var stack: [Environment] = [Environment()]
  public static var current: Environment { return stack.last! }

  public static func push(_ env: Environment) {
    self.stack.append(env)
  }

  public static func with(_ env: (Environment) -> Environment, _ block: () -> Void) {
    self.push(AppEnvironment.current |> env)
    block()
    self.pop()
  }

  public static func pop() {
    _ = self.stack.popLast()
  }
}
