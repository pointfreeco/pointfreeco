import EmailAddress
import Foundation

public struct GiftFormData: Codable, Equatable {
  public var deliverAt: Date?
  public var fromEmail: EmailAddress = ""
  public var fromName = ""
  public var message = ""
  public var monthsFree = 0
  public var toEmail: EmailAddress = ""
  public var toName = ""

  public static let empty = Self()

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
