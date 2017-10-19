import Either
import Optics
import Prelude

public typealias AirtableCreateRow = (_ email: String) -> (_ baseId: String) -> EitherIO<Unit, Unit>
public typealias FetchGitHubUser = (GitHubAccessToken) -> EitherIO<Unit, GitHubUser>
public typealias FetchAuthToken = (_ code: String) -> EitherIO<Prelude.Unit, GitHubAccessToken>

public struct Environment {
  public private(set) var airtableStuff: AirtableCreateRow
  public private(set) var fetchAuthToken: FetchAuthToken
  public private(set) var fetchGitHubUser: FetchGitHubUser

  init(airtableStuff: @escaping AirtableCreateRow = createRow,
       fetchAuthToken: @escaping FetchAuthToken = PointFree.fetchAuthToken,
       fetchGitHubUser: @escaping FetchGitHubUser = PointFree.fetchGitHubUser) {
    self.airtableStuff = airtableStuff
    self.fetchAuthToken = fetchAuthToken
    self.fetchGitHubUser = fetchGitHubUser
  }
}

public struct AppEnvironment {
  private static var stack: [Environment] = [Environment()]
  public static var current: Environment { return stack.last! }

  public static func push(env: Environment) {
    self.stack.append(env)
  }

  public static func with(airtableStuff: @escaping AirtableCreateRow = AppEnvironment.current.airtableStuff,
       fetchAuthToken: @escaping FetchAuthToken = AppEnvironment.current.fetchAuthToken,
       fetchGitHubUser: @escaping FetchGitHubUser = AppEnvironment.current.fetchGitHubUser,
       block: @escaping () -> Void) {

    self.push(
      env: AppEnvironment.current
        |> \.airtableStuff .~ airtableStuff
        |> \.fetchAuthToken .~ fetchAuthToken
        |> \.fetchGitHubUser .~ fetchGitHubUser
    )
    block()
    self.pop()
  }

  public static func pop() {
    _ = self.stack.popLast()
  }
}
