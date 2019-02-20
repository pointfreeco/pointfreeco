import Either
import Prelude

extension Client {
  internal static let mock = Client(
    fetchAuthToken: const(pure(pure(.mock))),
    fetchEmails: const(pure([.mock])),
    fetchUser: const(pure(.mock))
  )
}

extension AccessToken {
  internal static let mock = AccessToken(
    accessToken: "deadbeef"
  )
}

extension User {
  internal static let mock = User(
    id: 1,
    name: "Blob"
  )
}

extension UserEnvelope {
  internal static let mock = UserEnvelope(
    accessToken: .mock,
    gitHubUser: .mock
  )
}

extension User.Email {
  internal static let mock = User.Email(
    email: "hello@pointfree.co",
    primary: true
  )
}
