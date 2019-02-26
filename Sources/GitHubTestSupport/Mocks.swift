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

extension User {
  public static let mock = User(
    id: 1,
    name: "Blob"
  )
}

extension UserEnvelope {
  public static let mock = UserEnvelope(
    accessToken: .mock,
    gitHubUser: .mock
  )
}

extension User.Email {
  public static let mock = User.Email(
    email: "hello@pointfree.co",
    primary: true
  )
}
