import Either
import GitHub
import Prelude

extension Client {
  public static let mock = Client(
    fetchAuthToken: const(pure(pure(.mock))),
    fetchEmails: const(pure([.mock])),
    fetchUser: const(pure(.mock))
  )
}

extension AccessToken {
  public static let mock = AccessToken(
    accessToken: "deadbeef"
  )
}

extension GitHubUser {
  public static let mock = GitHubUser(
    id: 1,
    name: "Blob"
  )
}

extension GitHubUserEnvelope {
  public static let mock = GitHubUserEnvelope(
    accessToken: .mock,
    gitHubUser: .mock
  )
}

extension GitHubUser.Email {
  public static let mock = GitHubUser.Email(
    email: "hello@pointfree.co",
    primary: true
  )
}
