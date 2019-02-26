import Foundation
import PointFreePrelude
import Tagged

public struct TeamInvite: Decodable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Id
  public var inviterUserId: User.Id

  public init(
    createdAt: Date,
    email: EmailAddress,
    id: Id,
    inviterUserId: User.Id
    ) {
    self.createdAt = createdAt
    self.email = email
    self.id = id
    self.inviterUserId = inviterUserId
  }

  public typealias Id = Tagged<TeamInvite, UUID>

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case email
    case id
    case inviterUserId = "inviter_user_id"
  }
}
