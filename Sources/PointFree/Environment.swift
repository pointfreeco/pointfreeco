import Either
import Foundation
import Optics
import Prelude

public typealias AirtableCreateRow = (_ email: String) -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit>
public typealias FetchGitHubUser = (GitHubAccessToken) -> EitherIO<Error, GitHubUser>
public typealias FetchAuthToken = (_ code: String) -> EitherIO<Error, GitHubAccessToken>
public typealias SendEmail = (_ email: Email) -> EitherIO<Prelude.Unit, SendEmailResponse>

public enum Deployment {
  case development
  case staging
  case production
}

public struct Environment {
  public private(set) var airtableStuff: AirtableCreateRow
  public private(set) var baseUrl: URL?
  public private(set) var deployedTo: Deployment
  public private(set) var fetchAuthToken: FetchAuthToken
  public private(set) var fetchGitHubUser: FetchGitHubUser
  public private(set) var sendEmail: SendEmail

  init(
    airtableStuff: @escaping AirtableCreateRow = createRow,
    baseUrl: URL? = EnvVars.baseUrl,
    deployedTo: Deployment = .development,
    fetchAuthToken: @escaping FetchAuthToken = PointFree.fetchAuthToken,
    fetchGitHubUser: @escaping FetchGitHubUser = PointFree.fetchGitHubUser,
    sendEmail: @escaping SendEmail = PointFree.mailgunSend) {

    self.airtableStuff = airtableStuff
    self.baseUrl = baseUrl
    self.deployedTo = deployedTo
    self.fetchAuthToken = fetchAuthToken
    self.fetchGitHubUser = fetchGitHubUser
    self.sendEmail = sendEmail
  }
}

public struct AppEnvironment {
  private static var stack: [Environment] = [Environment()]
  public static var current: Environment { return stack.last! }

  public static func push(env: Environment) {
    self.stack.append(env)
  }

  public static func with(
    airtableStuff: @escaping AirtableCreateRow = AppEnvironment.current.airtableStuff,
    fetchAuthToken: @escaping FetchAuthToken = AppEnvironment.current.fetchAuthToken,
    fetchGitHubUser: @escaping FetchGitHubUser = AppEnvironment.current.fetchGitHubUser,
    sendEmail: @escaping SendEmail = AppEnvironment.current.sendEmail,
    block: @escaping () -> Void) {

    self.push(
      env: AppEnvironment.current
        |> \.airtableStuff .~ airtableStuff
        |> \.fetchAuthToken .~ fetchAuthToken
        |> \.fetchGitHubUser .~ fetchGitHubUser
        |> \.sendEmail .~ sendEmail
    )
    block()
    self.pop()
  }

  public static func pop() {
    _ = self.stack.popLast()
  }
}
