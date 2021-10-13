import EmailAddress
import Foundation

public struct GiftFormData: Codable, Equatable {
  public let deliverAt: Date?
  public let message: String
  public let recipientEmail: EmailAddress
  public let recipientName: String
  public let senderEmail: EmailAddress
  public let senderName: String

  public enum CodingKeys: String, CodingKey {
    case deliverAt
    case message
    case recipientEmail
    case recipientName
    case senderEmail
    case senderName
  }
}
