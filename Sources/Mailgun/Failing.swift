import PointFreePrelude
import XCTestDynamicOverlay

extension Client {
  public static let failing = Self(
    appSecret: "deadbeefdeadbeefdeadbeefdeadbeef",
    sendEmail: unimplemented("Mailgun.Client.sendEmail"),
    validate: unimplemented("Mailgun.Client.validate")
  )
}
