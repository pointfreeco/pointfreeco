import PointFreePrelude
import XCTestDynamicOverlay

extension Client {
  public static let failing = Self(
    fetchAuthToken: unimplemented("GitHub.Client.fetchAuthToken"),
    fetchEmails: unimplemented("GitHub.Client.fetchEmails"),
    fetchUser: unimplemented("GitHub.Client.fetchUser")
  )
}
