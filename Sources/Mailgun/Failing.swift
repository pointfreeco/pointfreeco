import PointFreePrelude

extension Client {
  public static let failing = Self(
    appSecret: "deadbeefdeadbeefdeadbeefdeadbeef",
    sendEmail: { _ in .failing("Mailgun.Client.sendEmail") },
    validate: { _ in .failing("Mailgun.Client.validate") }
  )
}
