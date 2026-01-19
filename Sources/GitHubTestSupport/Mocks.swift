import Either
import Foundation
import GitHub
import Prelude
import Tagged

extension Client {
  public static let mock = Client(
    fetchAuthToken: { _ in Client.AuthTokenResponse("deadbeef") },
    fetchBranch: { _, _, _, _ in
      Repo(commit: Repo.Commit(sha: "deadbeef"))
    },
    fetchEmails: { _ in [.mock] },
    fetchUser: { _ in .mock },
    fetchUserByUserID: { _, _ in .mock },
    fetchZipball: { _, _, _, _ in Data() }
  )
}

extension GitHubAccessToken {
  public static let mock = Self(
    rawValue: "deadbeef"
  )
}

extension GitHubUser {
  public static let mock = GitHubUser(
    createdAt: .init(timeIntervalSince1970: 1_234_543_210),
    login: "blob",
    id: 1,
    name: "Blob"
  )
}

extension GitHubUser.Email {
  public static let mock = GitHubUser.Email(
    email: "hello@pointfree.co",
    primary: true
  )
}
