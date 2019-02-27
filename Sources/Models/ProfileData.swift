import PointFreePrelude

// NB: remove this `Encodable` to get a runtime crash
public struct ProfileData: Codable, Equatable {
  public let email: EmailAddress
  public let extraInvoiceInfo: String?
  public let emailSettings: [String: String]
  public let name: String?

  public init(
    email: EmailAddress,
    extraInvoiceInfo: String?,
    emailSettings: [String: String],
    name: String?) {
    self.email = email
    self.extraInvoiceInfo = extraInvoiceInfo
    self.emailSettings = emailSettings
    self.name = name
  }

  public enum CodingKeys: String, CodingKey {
    case email
    case extraInvoiceInfo
    case emailSettings
    case name
  }
}
