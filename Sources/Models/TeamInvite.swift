import Foundation
import PointFreePrelude
import Tagged

public struct TeamInvite: Decodable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Id
  public var inviterUserId: User.Id

  public typealias Id = Tagged<TeamInvite, UUID>

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case email
    case id
    case inviterUserId = "inviter_user_id"
  }
}
