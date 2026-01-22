import Foundation
import Tagged

public struct TheWayAccess: Codable, Hashable {
  public let id: ID
  public let userID: User.ID
  public let machine: UUID
  public let whoami: String
  public let createdAt: Date
  public let expiresAt: Date
  public let updatedAt: Date?

  public typealias ID = Tagged<Self, UUID>

  public init(
    id: ID,
    userID: User.ID,
    machine: UUID,
    whoami: String,
    createdAt: Date,
    expiresAt: Date,
    updatedAt: Date?
  ) {
    self.id = id
    self.userID = userID
    self.machine = machine
    self.whoami = whoami
    self.createdAt = createdAt
    self.expiresAt = expiresAt
    self.updatedAt = updatedAt
  }
}
