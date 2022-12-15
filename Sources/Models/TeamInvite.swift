import EmailAddress
import Foundation
import Tagged

public struct TeamInvite: Decodable, Equatable, Identifiable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Tagged<Self, UUID>
  public var inviterUserId: User.ID

  public init(
    createdAt: Date,
    email: EmailAddress,
    id: ID,
    inviterUserId: User.ID
  ) {
    self.createdAt = createdAt
    self.email = email
    self.id = id
    self.inviterUserId = inviterUserId
  }
}
