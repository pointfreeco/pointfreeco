import EmailAddress
import Foundation
import Stripe

public struct GiftFormData: Equatable {
  public var deliverAt: Date?
  public var fromEmail: EmailAddress = ""
  public var fromName = ""
  public var message = ""
  public var monthsFree = 0
  public var stripePaymentIntentId: PaymentIntent.Id?
  public var toEmail: EmailAddress = ""
  public var toName = ""

  public static let empty = Self()
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter
}()

extension GiftFormData: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.deliverAt = (try? container.decode(String.self, forKey: .deliverAt))
      .flatMap(dateFormatter.date(from:))
    self.fromEmail = try container.decode(EmailAddress.self, forKey: .fromEmail)
    self.fromName = try container.decode(String.self, forKey: .fromName)
    self.message = try container.decode(String.self, forKey: .message)
    if let monthsFree = Int(try container.decode(String.self, forKey: .monthsFree)) {
      self.monthsFree = monthsFree
    } else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: container.codingPath,
          debugDescription: "monthsFree decoding failed",
          underlyingError: nil
        )
      )
    }
    self.stripePaymentIntentId =
      try container
      .decodeIfPresent(PaymentIntent.Id.self, forKey: .stripePaymentIntentId)
    self.toEmail = try container.decode(EmailAddress.self, forKey: .toEmail)
    self.toName = try container.decode(String.self, forKey: .toName)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(
      self.deliverAt.map(dateFormatter.string(from:)), forKey: .deliverAt)
    try container.encode(self.fromEmail, forKey: .fromEmail)
    try container.encode(self.fromName, forKey: .fromName)
    try container.encode(self.message, forKey: .message)
    try container.encode(String(self.monthsFree), forKey: .monthsFree)
    try container.encodeIfPresent(self.stripePaymentIntentId, forKey: .stripePaymentIntentId)
    try container.encode(self.toEmail, forKey: .toEmail)
    try container.encode(self.toName, forKey: .toName)
  }

  public enum CodingKeys: String, CodingKey {
    case deliverAt
    case fromEmail
    case fromName
    case message
    case monthsFree
    case stripePaymentIntentId
    case toEmail
    case toName
  }
}
