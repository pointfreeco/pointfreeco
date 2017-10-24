import Either
import Foundation
import Optics
import Prelude

public typealias AirtableCreateRow = (_ email: String) -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit>
public typealias CreateUser = (GitHubUserEnvelope) -> EitherIO<Error, Prelude.Unit>
public typealias FetchAuthToken = (_ code: String) -> EitherIO<Prelude.Unit, GitHubAccessToken>
public typealias FetchGitHubUser = (GitHubAccessToken) -> EitherIO<Prelude.Unit, GitHubUser>
public typealias FetchUser = (GitHubAccessToken) -> EitherIO<Error, User?>

public struct Environment {
  public private(set) var airtableStuff: AirtableCreateRow
  public private(set) var baseUrl = URL(string: "http://localhost:8080")
  public private(set) var createUser: CreateUser
  public private(set) var fetchAuthToken: FetchAuthToken
  public private(set) var fetchGitHubUser: FetchGitHubUser
  public private(set) var fetchUser: FetchUser

  init(airtableStuff: @escaping AirtableCreateRow = createRow,
       createUser: @escaping CreateUser = PointFree.createUser,
       fetchAuthToken: @escaping FetchAuthToken = PointFree.fetchAuthToken,
       fetchGitHubUser: @escaping FetchGitHubUser = PointFree.fetchGitHubUser,
       fetchUser: @escaping FetchUser = PointFree.fetchUser) {
    self.airtableStuff = airtableStuff
    self.createUser = createUser
    self.fetchAuthToken = fetchAuthToken
    self.fetchGitHubUser = fetchGitHubUser
    self.fetchUser = fetchUser
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
