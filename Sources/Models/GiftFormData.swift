import EmailAddress
import Foundation
import Stripe

public struct GiftFormData: Equatable {
  public var deliverAt: Date?
  public var fromEmail: EmailAddress = ""
  public var fromName = ""
  public var message = ""
  public var monthsFree = 0
  public var paymentType: PaymentType?
  public var toEmail: EmailAddress = ""
  public var toName = ""

  public enum PaymentType: Equatable {
    case paymentIntentID(PaymentIntent.Id)
    case paymentMethodID(PaymentMethod.ID)
  }

  public static let empty = Self()

  @available(*, deprecated)
  var stripePaymentIntentId: PaymentIntent.Id? {
    guard case let .some(.paymentIntentID(id)) = self.paymentType
    else { return nil }
    return id
  }
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
    do {
      self.paymentType = try .paymentIntentID(
        container.decode(PaymentIntent.Id.self, forKey: .stripePaymentIntentId)
      )
    } catch {
      do {
        self.paymentType = try .paymentMethodID(
          container.decode(PaymentMethod.ID.self, forKey: .paymentMethodID)
        )
      } catch {
        self.paymentType = nil
      }
    }
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
    switch self.paymentType {
    case let .paymentIntentID(paymentIntentID):
      try container.encodeIfPresent(paymentIntentID, forKey: .stripePaymentIntentId)
    case let .paymentMethodID(paymentMethodID):
      try container.encodeIfPresent(paymentMethodID, forKey: .paymentMethodID)
    case .none:
      break
    }
    try container.encode(self.toEmail, forKey: .toEmail)
    try container.encode(self.toName, forKey: .toName)
  }

  public enum CodingKeys: String, CodingKey {
    case deliverAt
    case fromEmail
    case fromName
    case message
    case monthsFree
    case paymentMethodID
    case stripePaymentIntentId
    case toEmail
    case toName
  }
}
