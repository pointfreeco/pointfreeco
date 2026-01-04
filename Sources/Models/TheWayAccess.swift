import Foundation
import Tagged

public struct TheWayAccess: Codable, Hashable {
  public let id: ID
  public let machine: UUID
  public let whoami: String
  public let createdAt: Date
  public let updatedAt: Date?

  public typealias ID = Tagged<Self, UUID>

  public init(
    id: ID,
    machine: UUID,
    whoami: String,
    createdAt: Date,
    updatedAt: Date?
  ) {
    self.id = id
    self.machine = machine
    self.whoami = whoami
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
