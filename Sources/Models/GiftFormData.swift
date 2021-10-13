import EmailAddress
import Foundation

public struct GiftFormData: Codable, Equatable {
  public let deliverAt: Date?
  public let fromEmail: EmailAddress
  public let fromName: String
  public let message: String
  public let monthsFree: Int
  public let toEmail: EmailAddress
  public let toName: String

  public enum CodingKeys: String, CodingKey {
    case deliverAt
    case fromEmail
    case fromName
    case message
    case monthsFree
    case toEmail
    case toName
  }
}
