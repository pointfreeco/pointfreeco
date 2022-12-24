import Either
import GitHub
import Prelude

extension Client {
  public static let mock = Client(
    fetchAuthToken: { _ in .right(.mock) },
    fetchEmails: { _ in [.mock] },
    fetchUser: { _ in .mock }
  )
}

extension AccessToken {
  public static let mock = AccessToken(
    accessToken: "deadbeef"
  )
}

extension GitHubUser {
  public static let mock = GitHubUser(
    createdAt: .init(timeIntervalSince1970: 1_234_543_210),
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
