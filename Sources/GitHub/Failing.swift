import PointFreePrelude

extension Client {
  public static let failing = Self(
    fetchAuthToken: { _ in .failing("GitHub.Client.fetchAuthToken") },
    fetchEmails: { _ in .failing("GitHub.Client.fetchEmails") },
    fetchUser: { _ in .failing("GitHub.Client.fetchUser") }
  )
}
