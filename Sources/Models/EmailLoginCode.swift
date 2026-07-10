import EmailAddress
import Foundation
import Tagged

public struct EmailLoginCode: Decodable, Equatable, Identifiable {
  public var code: Code
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Tagged<Self, UUID>

  public init(
    code: Code,
    createdAt: Date,
    email: EmailAddress,
    id: ID
  ) {
    self.code = code
    self.createdAt = createdAt
    self.email = email
    self.id = id
  }

  public typealias Code = Tagged<(Self, code: ()), String>

  public static let lifetime: TimeInterval = 60 * 60
  public static let resendInterval: TimeInterval = 60
}
